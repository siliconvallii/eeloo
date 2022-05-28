import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/upload_image.dart';
import 'package:eeloo/utils/fetch_school.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future createProfile(
  String username,
  String uid,
  File profilePicture,
  String classValue,
  String sectionValue,
  String bio,
  String email,
) async {
  // Instanciate reference of Cloud Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Check if username already exists
  bool doesUsernameAlreadyExist = false;

  await firestore.collection('usernames').get().then(
    (QuerySnapshot querySnapshot) {
      for (QueryDocumentSnapshot _username in querySnapshot.docs) {
        if (_username.id == username) {
          doesUsernameAlreadyExist = true;
        }
      }
    },
  );

  if (doesUsernameAlreadyExist) {
    // Username already exists
    // Throw error
    throw 'username-already-exists';
  }

  // Upload image and fetch image URL
  String profilePictureUrl = await uploadImage(profilePicture);

  // Fetch FCM token
  String? fcmToken = await FirebaseMessaging.instance.getToken();

  // Fetch school
  String school = fetchSchool(email);

  // Update locally stored user's data
  Map<String, dynamic> tempUserData = {
    'username': username,
    'uid': uid,
    'profile_picture': profilePictureUrl,
    'class': classValue,
    'section': sectionValue,
    'bio': bio,
    'total_friends': 0,
    'fcm_token': fcmToken,
    'school': school,
    'created_at': DateTime.now().toString(),
  };

  user['data'] = tempUserData;

  // Upload user's data to UIDS collection
  await firestore.collection('uids').doc(user['data']['uid']).set(tempUserData);

  // Upload user's data to usernames collection
  await firestore
      .collection('usernames')
      .doc(user['data']['username'])
      .set(tempUserData);
}
