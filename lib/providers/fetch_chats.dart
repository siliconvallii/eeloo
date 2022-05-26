import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/services/local_notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';

Future<List> fetchChats(bool isRefreshing) async {
  if (user['chats'] != null && isRefreshing == false) {
    // user has chats stored locally

    return user['chats'];
  } else {
    // user has to download chats

    // instatiate reference of Cloud Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    List _chats = [];
    List _expiredChats = [];

    // fetch chats
    await firestore
        .collection('uids')
        .doc(user['data']['uid'])
        .collection('chats')
        .get()
        .then(
      (QuerySnapshot querySnapshot) async {
        Map _tempChats = {};

        for (DocumentSnapshot doc in querySnapshot.docs) {
          _tempChats[doc.id] = doc.data();
        }

        if (_tempChats != {}) {
          for (Map _chat in _tempChats.values) {
            // check if chat is expired
            int hoursSinceLast = DateTime.now()
                .difference(DateTime.parse(await _chat['sent_at']))
                .inHours;

            bool isChatExpired = hoursSinceLast > 24;

            if (isChatExpired) {
              // chat is expired
              String chatKey = '';

              if (_chat['recipient_uid'] == user['data']['uid']) {
                chatKey = _chat['sender_uid'];
              } else {
                chatKey = _chat['recipient_uid'];
              }

              // expire chat for user
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

              // expire chat for other user
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
              _expiredChats.add(_chat);
            } else {
              _chats.add(_chat);
            }
          }
        }
      },
    );

    // sort chats List
    _chats.sort(
      (a, b) {
        if (a['recipient_uid'] == user['data']['uid'] &&
            b['recipient_uid'] == user['data']['uid']) {
          if (DateTime.parse(a['sent_at'])
              .isBefore(DateTime.parse(b['sent_at']))) {
            return -1;
          } else {
            return 1;
          }
        } else if (a['sender_uid'] == user['data']['uid'] &&
            b['sender_uid'] == user['data']['uid']) {
          if (DateTime.parse(a['sent_at'])
              .isBefore(DateTime.parse(b['sent_at']))) {
            return -1;
          } else {
            return 1;
          }
        } else {
          if (b['recipient_uid'] == user['data']['uid']) {
            return 1;
          } else {
            return -1;
          }
        }
      },
    );

    _chats = [..._expiredChats, ..._chats];

    // update total_friends
    if (user['data']['friends'] != null) {
      await firestore.collection('uids').doc(user['data']['uid']).update(
        {
          'total_friends': user['data']['friends'].length,
        },
      );
    } else {
      await firestore.collection('uids').doc(user['data']['uid']).update(
        {
          'total_friends': 0,
        },
      );
    }

    user['chats'] = _chats;

    // schedule expiring chat notifications
    int index = 0;

    for (Map _chat in _chats) {
      // update index of _chats
      index = index + 1;

      // check if user is recipient of chat
      if (_chat['recipient_uid'] == user['data']['uid']) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        int? notificationId = prefs.getInt(_chat['sender_uid']);

        // check if a notification for this chat already exists
        if (notificationId == null) {
          // fetch date for notification
          initializeTimeZones();

          TZDateTime notificationDate =
              TZDateTime.parse(local, _chat['sent_at']).add(
            const Duration(
              minutes: 1380,
            ),
          );

          // check if now is before scheduled notification
          if (DateTime.now().toLocal().isBefore(notificationDate)) {
            // generate uid for notification
            notificationId =
                DateTime.now().millisecondsSinceEpoch ~/ 1000 + index;

            // store notification's uid locally
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setInt(_chat['sender_uid'], notificationId);

            // schedule local notification
            LocalNotificationService.scheduleNotification(
              _chat['sender_username'],
              notificationId,
              notificationDate,
            );
          }
        }
      }
    }

    return _chats;
  }
}
