import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/check_profile_integrity.dart';
import 'package:eeloo/providers/sign_in.dart';
import 'package:eeloo/screens/create_profile_screen.dart';
import 'package:eeloo/screens/fix_profile_screen.dart';
import 'package:eeloo/screens/home_screen.dart';
import 'package:eeloo/screens/sign_in_screen.dart';
import 'package:eeloo/utils/fetch_school.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({Key? key}) : super(key: key);

  Future _fetchSignInData() async {
    // Instanciate SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch sign-in data
    Map<String, String> signInData = {};
    signInData['email'] = prefs.getString('email') ?? '';
    signInData['password'] = prefs.getString('password') ?? '';

    // Check if there is sign-in data
    if (signInData['email'] == '' || signInData['password'] == '') {
      // There is no sign-in data
      // Shut down function
      return;
    } else {
      // There is sign-in data
      // Return sign-in data
      return signInData;
    }
  }

  void _signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      // Authenticate user and fetch UUID
      String uuid = await signIn(email, password);

      // Check if email is verified
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        // Email is not verified
        // Send verification email
        await FirebaseAuth.instance.currentUser!.sendEmailVerification();

        // Show dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('errore!'),
              content: Text('verifica la tua email per continuare'),
            );
          },
        );

        // Shut down function
        return;
      }

      // Instanciate reference of Cloud Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch profile
      dynamic userData;
      await firestore.collection('uids').doc(uuid).get().then(
        (DocumentSnapshot docSnapshot) {
          // Check if profile exists
          if (!docSnapshot.exists) {
            // Profile doesn't exist
            // Navigate to CreateProfileScreen
            SchedulerBinding.instance.addPostFrameCallback(
              (_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return CreateProfileScreen(
                        email: email,
                        uid: uuid,
                      );
                    },
                  ),
                  (Route route) => false,
                );
              },
            );

            // Shut down function
            return;
          }

          userData = docSnapshot.data();
        },
      );

      // Store user's data locally
      user['data'] = userData;

      // Fetch user's data in usernames collection
      dynamic usernameProfile;
      await firestore
          .collection('usernames')
          .doc(userData['username'])
          .get()
          .then((value) => usernameProfile = value.data());

      // Check if profile is corrupted
      Map<String, bool> elementsToFix = await checkProfileIntegrity(
        userData,
        usernameProfile,
        uuid,
        email,
        fetchSchool(email),
      );

      // Check if there is something to manually fix
      if (elementsToFix.containsValue(true)) {
        // There is something to manually fix
        // Navigate to FixProfileScreen
        SchedulerBinding.instance.addPostFrameCallback(
          (_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return FixProfileScreen(elementsToFix: elementsToFix);
                },
              ),
              (Route route) => false,
            );
          },
        );

        // Shut down function
        return;
      }

      // Navigate to HomeScreen
      SchedulerBinding.instance.addPostFrameCallback(
        (_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const HomeScreen();
              },
            ),
            (Route route) => false,
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      // A FirebaseAuthException occurred
      // Clear sign-in data
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('email');
      prefs.remove('password');

      // Check which exception occurred
      if (e.code == 'invalid-email') {
        // Email is invalid
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('errore!'),
              content: Text('l\'email inserita non è valida'),
            );
          },
        );
      } else if (e.code == 'user-disabled') {
        // User email has been disabled
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('errore!'),
              content: Text('questo account è stato disabilitato'),
            );
          },
        );
      } else if (e.code == 'user-not-found') {
        // Email doesn't belong to any user
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('errore!'),
              content: Text('non esiste un account con questa email'),
            );
          },
        );
      } else if (e.code == 'wrong-password') {
        // Password is wrong
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('errore!'),
              content: Text('la password inserita è sbagliata'),
            );
          },
        );
      } else {
        // Unknown FirebaseAuthException
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('errore!'),
              content: Text(e.message.toString()),
            );
          },
        );
      }
    } catch (e) {
      // An unknown error occurred
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('errore!'),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchSignInData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // Check if Future has completed
        if (snapshot.connectionState == ConnectionState.done) {
          // Future has completed
          // Check if there is sign-in data
          if (snapshot.hasData) {
            // There is sign-in data
            // Silently sign-in user
            _signIn(snapshot.data['email'], snapshot.data['password'], context);
          } else {
            // There is no sign-in data
            // Navigate to SignInScreen
            SchedulerBinding.instance.addPostFrameCallback(
              (_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const SignInScreen();
                    },
                  ),
                  (Route route) => false,
                );
              },
            );
          }
        }
        // Future is loading
        // Show loading indicator
        return Scaffold(
          body: GestureDetector(
            child: const SafeArea(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            onTap: () {
              // Close keyboard if user taps on screen
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
          ),
        );
      },
    );
  }
}
