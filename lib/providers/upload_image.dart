import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

Future<String> uploadImage(File image) async {
  // Generate random image ID
  String imageId = const Uuid().v4();

  // Instanciate reference of Firebase Storage
  Reference reference = FirebaseStorage.instance.ref().child(imageId);

  // Upload image to Firebase Storage
  await reference.putFile(File(image.path));

  // Fetch image URL
  String imageUrl = '';
  await reference.getDownloadURL().then((_imageURL) => imageUrl = _imageURL);

  return imageUrl;
}
