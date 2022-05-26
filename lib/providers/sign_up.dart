import 'package:eeloo/data/data.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> signUp(String email, String password) async {
  // Fetch email domain
  List<String> emailStrings = email.split('@');
  String emailDomain = emailStrings[1];

  // Check if email domain is allowed
  if (!allowedEmailDomains.contains(emailDomain)) {
    // Email domain is not allowed
    // Throw error
    throw 'email-domain-not-allowed';
  }

  // Fetch UserCredential with email and password with sign-up
  UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // Return user UID
  return userCredential.user!.uid;
}
