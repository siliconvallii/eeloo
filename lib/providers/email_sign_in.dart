import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/screens/create_profile_screen.dart';
import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future emailSignIn(BuildContext context, String email, String password) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // dismiss keyboard
  FocusManager.instance.primaryFocus?.unfocus();

  // show loading indicator
  showDialog(
    barrierDismissible: false,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xffBC91F8),
        ),
      );
    },
    context: context,
  );

  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // check if email is verified
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      // email is verified

      // get fcm token
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? fcmToken = await messaging.getToken();

      // instatiate reference of Cloud Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // set user data in uids collection
      await firestore
          .collection('uids')
          .doc(userCredential.user!.uid)
          .get()
          .then(
        (DocumentSnapshot doc) async {
          dynamic _user = doc.data();

          // check if profile exists
          if (doc.exists && _user['uid'] != null && _user['class'] != null) {
            // profile exists

            // check if fcm token is updated
            if (_user['fcm_token'] != fcmToken) {
              // fcm token isn't updated

              // update fcm token in uids
              await firestore
                  .collection('uids')
                  .doc(userCredential.user!.uid)
                  .update(
                {
                  'fcm_token': fcmToken,
                },
              );
            }

            // store user data and chats locally
            if (_user != null) {
              user['data'] = _user;
            }

            // check if user exists in usernames
            await firestore
                .collection('usernames')
                .doc(user['data']['username'])
                .get()
                .then(
              (DocumentSnapshot _doc) async {
                dynamic _username = _doc.data();

                // check if fcm is updated
                if (!_doc.exists || _username['fcm_token'] != fcmToken) {
                  // fcm token isn't updated

                  // update fcm token in usernames
                  await firestore
                      .collection('usernames')
                      .doc(user['data']['username'])
                      .update(
                    {
                      'fcm_token': fcmToken,
                    },
                  );
                }

                // check if uid is updated
                if (!_doc.exists || _username['uid'] != user['data']['uid']) {
                  // uid isn't updated

                  // update uid in usernames
                  await firestore
                      .collection('usernames')
                      .doc(user['data']['username'])
                      .update(
                    {
                      'uid': user['data']['uid'],
                    },
                  );
                }
              },
            );

            // pop loading indicator
            Navigator.pop(context);

            // navigate to HomeScreen
            Navigator.pushNamed(context, '/home');

            // store sign-in data locally
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();

            prefs.setString('email', email);
            prefs.setString('password', password);
          } else {
            // user is new

            // pop loading indicator
            Navigator.pop(context);

            // navigate to CreateProfileScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateProfileScreen(
                  uid: userCredential.user!.uid,
                  email: email,
                ),
              ),
            );
          }
        },
      );
    } else {
      // email isn't verified

      // pop loading indicator
      Navigator.pop(context);

      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      // show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomAlertDialog(
            dialogTitle: 'errore!',
            dialogBody:
                'devi verificare la tua email per continuare. controlla la tua '
                'casella di posta',
          );
        },
      );
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      // user not found

      // clear data store locally
      prefs.remove('email');
      prefs.remove('password');

      // pop loading indicator
      Navigator.pop(context);

      // show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomAlertDialog(
            dialogTitle: 'errore!',
            dialogBody: 'non esiste un account con questa email',
          );
        },
      );
    } else if (e.code == 'wrong-password') {
      // password is wrong

      // clear data store locally
      prefs.remove('email');
      prefs.remove('password');

      // pop loading indicator
      Navigator.pop(context);

      // show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomAlertDialog(
            dialogTitle: 'errore!',
            dialogBody: 'la password che hai inserito è sbagliata',
          );
        },
      );
    }
  } catch (e) {
    // unknown error

    // clear data store locally
    prefs.remove('email');
    prefs.remove('password');

    // pop loading indicator
    Navigator.pop(context);

    // show error dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          dialogTitle: 'errore sconosciuto!',
          dialogBody: e.toString(),
        );
      },
    );
  }
}
