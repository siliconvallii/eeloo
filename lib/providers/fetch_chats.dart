import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/services/local_notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';

Future<List> fetchChats(bool isRefreshing) async {
  // Check if user has chats stored locally
  if (user['chats'] != null && isRefreshing == false) {
    // User has chats stored locally
    // Return locally stored chats

    return user['chats'];
  }

  // Instanciate reference of Cloud Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List _activeChats = [];
  List _expiredChats = [];

  // Fetch chats
  await firestore
      .collection('uids')
      .doc(user['data']['uid'])
      .collection('chats')
      .get()
      .then(
    (QuerySnapshot querySnapshot) async {
      // Temporally store every chat
      Map _tempChats = {};
      for (DocumentSnapshot doc in querySnapshot.docs) {
        _tempChats[doc.id] = doc.data();
      }

      // Check if there are chats
      if (_tempChats != {}) {
        for (Map _chat in _tempChats.values) {
          // Fetch how many hours passed since last message
          int hoursSinceLastMessage = DateTime.now()
              .difference(DateTime.parse(await _chat['sent_at']))
              .inHours;

          // Check if chat is expired
          if (hoursSinceLastMessage > 24) {
            // Chat is expired
            // Check if chat expiration was already handled
            if (_chat['is_chat_expired'] == null) {
              // Fetch chat key
              String chatKey = '';
              if (_chat['recipient_uid'] == user['data']['uid']) {
                chatKey = _chat['sender_uid'];
              } else {
                chatKey = _chat['recipient_uid'];
              }

              // Expire chat for the current user
              await firestore
                  .collection('uids')
                  .doc(user['data']['uid'])
                  .collection('chats')
                  .doc(chatKey)
                  .update(
                {
                  'streak': 0,
                  'is_chat_expired': true,
                },
              );

              // Expire chat for the other user
              await firestore
                  .collection('uids')
                  .doc(chatKey)
                  .collection('chats')
                  .doc(user['data']['uid'])
                  .update(
                {
                  'streak': 0,
                  'is_chat_expired': true,
                },
              );
            }

            // Add chat to expired chats
            _expiredChats.add(_chat);
          } else {
            // Chat is not expired
            // Add chat to active chats
            _activeChats.add(_chat);
          }
        }
      }
    },
  );

  // Sort active chats
  _activeChats.sort(
    (a, b) {
      // Check chats' data
      if (a['recipient_uid'] == user['data']['uid'] &&
          b['recipient_uid'] == user['data']['uid']) {
        // User is recipient of both chats
        // Order chats chronologically
        if (DateTime.parse(a['sent_at'])
            .isBefore(DateTime.parse(b['sent_at']))) {
          return -1;
        } else {
          return 1;
        }
      } else if (a['sender_uid'] == user['data']['uid'] &&
          b['sender_uid'] == user['data']['uid']) {
        // User is sender of both chats
        // Order chats chronologically
        if (DateTime.parse(a['sent_at'])
            .isBefore(DateTime.parse(b['sent_at']))) {
          return -1;
        } else {
          return 1;
        }
      } else {
        // User is both recipient and sender
        // Check of which chat is recipient and give priority
        if (b['recipient_uid'] == user['data']['uid']) {
          return 1;
        } else {
          return -1;
        }
      }
    },
  );

  // Sort expired chats
  _expiredChats.sort(
    ((a, b) {
      // Order chats chronologically
      if (DateTime.parse(a['sent_at']).isBefore(DateTime.parse(b['sent_at']))) {
        return -1;
      } else {
        return 1;
      }
    }),
  );

  // Add expired chats
  List _chats = [..._expiredChats, ..._activeChats];

  // Store chats locally
  user['chats'] = _chats;

  // Update count of total friends
  // Check if user has friends
  if (user['data']['friends'] != null) {
    // User has friends
    await firestore.collection('uids').doc(user['data']['uid']).update(
      {
        'total_friends': user['data']['friends'].length,
      },
    );
  } else {
    // User hasn't friends
    await firestore.collection('uids').doc(user['data']['uid']).update(
      {
        'total_friends': 0,
      },
    );
  }

  // Schedule local notifications for active chats
  int index = 0;
  for (Map _chat in _activeChats) {
    index = index + 1;

    // Check if user is recipient of chat
    if (_chat['recipient_uid'] == user['data']['uid']) {
      // User if recipient of the chat
      // Check if a notification for this chat is already scheduled
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? notificationId = prefs.getInt(_chat['sender_uid']);

      if (notificationId != null) {
        // A notification is already scheduled
        // Shut down function
        return _chats;
      }

      // Fetch date for the notification
      initializeTimeZones();
      TZDateTime notificationDate =
          TZDateTime.parse(local, _chat['sent_at']).add(
        const Duration(
          minutes: 1380,
        ),
      );

      // Check if date of notification already occurred
      if (DateTime.now().toLocal().isAfter(notificationDate)) {
        // Date of notification already occurred
        // Shut down function
        return _chats;
      }

      // Generate a notification's UID
      notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000 + index;

      // Store notification's UID locally
      prefs.setInt(_chat['sender_uid'], notificationId);

      // Schedule local notification
      LocalNotificationService.scheduleNotification(
        _chat['sender_username'],
        notificationId,
        notificationDate,
      );
    }
  }

  return _chats;
}
