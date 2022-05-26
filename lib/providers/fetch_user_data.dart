import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';

Future<Map> fetchUserData(String uuid) async {
  // Check if user's data is already locally stored
  if (users[uuid] != null) {
    // User's data is already locally stored
    // Return locally stored user's data
    return users[uuid];
  }

  // Instaciate Firebase Cloud Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch user's data
  dynamic userData = await firestore.collection('uids').doc(uuid).get().then(
    (DocumentSnapshot value) {
      return value.data();
    },
  );

  // Store user's data locally
  users[uuid] = userData;

  // Return fetched user's data
  return userData;
}
