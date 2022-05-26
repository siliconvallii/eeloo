import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

Future updateProfile(Map<String, dynamic> updatedProfile) async {
  // Instanciate reference of Cloud Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool doesUsernameAlreadyExist = false;

  // Check if username already exists
  if (updatedProfile['username'] != null) {
    await firestore.collection('usernames').get().then(
      (QuerySnapshot querySnapshot) {
        for (QueryDocumentSnapshot _username in querySnapshot.docs) {
          if (_username.id == updatedProfile['username']) {
            doesUsernameAlreadyExist = true;
          }
        }
      },
    );
  }

  if (doesUsernameAlreadyExist) {
    // Username already exists
    // Throw error
    throw 'username-already-exists';
  }

  if (updatedProfile['profile_picture'] != null) {
    // Generate image ID
    String imageId = const Uuid().v4();

    // instatiate reference of Firebase Storage
    Reference reference = FirebaseStorage.instance.ref().child(imageId);

    // Upload image to Firebase Storage
    await reference.putFile(updatedProfile['profile_picture']);

    // Fetch image URL
    String profilePictureUrl = '';
    await reference
        .getDownloadURL()
        .then((String _imageURL) => profilePictureUrl = _imageURL);

    // Store link
    updatedProfile['profile_picture'] = profilePictureUrl;
  }

  // Update user's data to UIDS collection
  await firestore
      .collection('uids')
      .doc(user['data']['uid'])
      .update(updatedProfile);

  // Update user's data to usernames collection
  await firestore
      .collection('usernames')
      .doc(user['data']['username'])
      .update(updatedProfile);

  // Fetch user's updated data
  dynamic userData =
      await firestore.collection('uids').doc(user['data']['uid']).get().then(
    (DocumentSnapshot value) {
      return value.data();
    },
  );

  // Store user's data locally
  user['data'] = userData;
  users[user['data']['uid']] = userData;
}
