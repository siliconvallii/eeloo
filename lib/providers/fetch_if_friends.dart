import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';

Future<bool> fetchIfFriends(friendUid) async {
  // instatiate reference of Cloud Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool areFriends = false;

  // fetch user data
  await firestore
      .collection('uids')
      .doc(friendUid)
      .collection('chats')
      .doc(user['data']['uid'])
      .get()
      .then(
    (DocumentSnapshot documentSnapshot) {
      // check if friends
      if (documentSnapshot.exists) {
        areFriends = true;
      }
    },
  );

  return areFriends;
}
