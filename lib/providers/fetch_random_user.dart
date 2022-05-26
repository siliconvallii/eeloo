import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';

Future<String> fetchRandomUser() async {
  // instatiate reference of Cloud Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List randomUsersList = [];

  await firestore.collection('usernames').get().then(
    (QuerySnapshot querySnapshot) {
      Map _usernames = {};

      for (DocumentSnapshot doc in querySnapshot.docs) {
        _usernames[doc.id] = doc.data();
      }

      _usernames.forEach(
        (key, value) {
          if (value['uid'] != null && value['uid'] != user['data']['uid']) {
            if (user['chats'].isEmpty) {
              randomUsersList.add(key);
            } else {
              bool _hasAlreadyChat = false;

              for (Map _chat in user['chats']) {
                if (_chat['sender_uid'] == value['uid'] ||
                    _chat['recipient_uid'] == value['uid']) {
                  _hasAlreadyChat = true;
                }
              }

              if (_hasAlreadyChat == false) {
                randomUsersList.add(key);
              }
            }
          }
        },
      );

      // shuffle List
      randomUsersList.shuffle();
    },
  );

  if (randomUsersList.isEmpty) {
    return '';
  } else {
    return randomUsersList[0];
  }
}
