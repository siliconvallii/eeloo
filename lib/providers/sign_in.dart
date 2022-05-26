import 'package:firebase_auth/firebase_auth.dart';

Future<String> signIn(String email, String password) async {
  // Fetch UserCredential with email and password with sign-in
  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  // Return user UID
  return userCredential.user!.uid;
}
