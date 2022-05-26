import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<Map<String, bool>> checkProfileIntegrity(
  Map<String, dynamic> profile,
  Map<String, dynamic> usernameProfile,
  String uid,
  String email,
  String school,
) async {
  Map<String, Object> fixedElements = {};

  // Check if uid is corrupt
  if (profile['uid'] != uid) {
    // Uid is corrupt
    fixedElements['uid'] = uid;
  }

  // Check if FCM token is corrupt
  // Fetch FCM token
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? fcmToken = await messaging.getToken();
  if (profile['fcm_token'] != fcmToken ||
      usernameProfile['fcm_token'] != fcmToken) {
    // FCM token is corrupt
    fixedElements['fcm_token'] = fcmToken!;
  }

  // Check if email is corrupt
  if (profile['email'] != email || usernameProfile['email'] != email) {
    // Email is corrupt
    fixedElements['email'] = email;
  }

  // Check if school is corrupt
  if (profile['school'] != school || usernameProfile['school'] != school) {
    // School is corrupt
    fixedElements['school'] = school;
  }

  // Check if UIDS profile is equal to username profile
  if (profile != usernameProfile) {
    // Instanciate reference of Cloud Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Upload UIDS profile in usernames collection
    await firestore
        .collection('usernames')
        .doc(profile['username'] ?? usernameProfile['username'])
        .update(profile);
  }

  // Check if profile has to be fixed
  if (fixedElements != {}) {
    // Instanciate reference of Cloud Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Update fixes to Cloud Firestore in UIDS collection
    await firestore.collection('uids').doc(uid).update(fixedElements);

    // Update fixes to Cloud Firestore in usernames collection
    await firestore
        .collection('usernames')
        .doc(profile['username'] ?? usernameProfile['username'])
        .update(fixedElements);
  }

  Map<String, bool> elementsToFix = {
    'username': false,
    'full_name': false,
    'bio': false,
    'profile_picture': false,
    'class': false,
    'section': false,
  };

  // Check if something has to be manually fixed
  if (profile['username'] == null) {
    // Username has to be fixed
    elementsToFix['username'] = true;
  }
  if (profile['full_name'] == null) {
    // Full name has to be fixed
    elementsToFix['full_name'] = true;
  }
  if (profile['bio'] == null) {
    // Bio has to be fixed
    elementsToFix['bio'] = true;
  }
  if (profile['profile_picture'] == null) {
    // Profile picture has to be fixed
    elementsToFix['profile_picture'] = true;
  }
  if (profile['class'] == null) {
    // Class has to be fixed
    elementsToFix['class'] = true;
  }
  if (profile['section'] == null) {
    // Section has to be fixed
    elementsToFix['section'] = true;
  }

  return elementsToFix;
}
