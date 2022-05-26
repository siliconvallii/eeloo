import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/providers/check_profile_integrity.dart';
import 'package:eeloo/providers/sign_in.dart';
import 'package:eeloo/providers/sign_up.dart';
import 'package:eeloo/screens/fix_profile_screen.dart';
import 'package:eeloo/screens/home_screen.dart';
import 'package:eeloo/utils/fetch_school.dart';
import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/screens/create_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  void _signUp(String email, String password, BuildContext context) async {
    try {
      // Sign-up user
      await signUp(email, password);

      // Store sign-in data locally
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('email', email);
      preferences.setString('password', password);

      // Send verification email
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      // Show email verification dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('account creato!'),
            content: Text('verifica la tua email'),
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
      if (e.code == 'weak-password') {
        // Password is too weak
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('errore!'),
              content: Text('la password inserita è troppo debole'),
            );
          },
        );
      } else if (e.code == 'email-already-in-use') {
        // Email is already in use
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('errore!'),
              content: Text('l\'email inserita è già stata utilizzata'),
            );
          },
        );
      } else if (e.code == 'invalid-email') {
        // Email is not valid
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
      }
    } catch (e) {
      // An error occurred
      // Check which error occurred
      if (e == 'email-not-valid') {
        // Email is not valid
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
      } else if (e == 'email-domain-not-allowed') {
        // Email domain is not allowed
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('errore!'),
              content: Text(
                'l\'email inserita non è autorizzata per la '
                'creazione di un account su eeloo.',
              ),
            );
          },
        );
      } else {
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
  }

  void _signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      // Authenticate user and fetch UUID
      String uuid = await signIn(email, password);

      // Store sign-in data locally
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('email', email);
      preferences.setString('password', password);

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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Email TextField
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                // Password TextField
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'password',
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
                // Sign-up ElevatedButton
                ElevatedButton(
                  child: const Text('registrati'),
                  onPressed: () {
                    // Sign-up user
                    _signUp(
                      _emailController.text,
                      _passwordController.text,
                      context,
                    );
                  },
                ),
                // Sign-in ElevatedButton
                ElevatedButton(
                  child: const Text('accedi'),
                  onPressed: () {
                    // Sign-in user
                    _signIn(
                      _emailController.text,
                      _passwordController.text,
                      context,
                    );
                  },
                ),
                TextButton(
                  child: Text(
                    'hai dimenticato la password?',
                    style: GoogleFonts.alata(
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          actions: <TextButton>[
                            TextButton(
                              child: Text(
                                'annulla',
                                style: GoogleFonts.alata(
                                  color: const Color(0xffBC91F8),
                                  fontSize: 17,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              style: ButtonStyle(
                                overlayColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.transparent),
                              ),
                            ),
                            TextButton(
                              child: Text(
                                'reimposta password',
                                style: GoogleFonts.alata(
                                  color: const Color(0xffBC91F8),
                                  fontSize: 17,
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  // validate email
                                  bool isEmailValid = EmailValidator.validate(
                                      _resetEmailController.text);

                                  if (isEmailValid) {
                                    // email is valid

                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(
                                      email: _resetEmailController.text,
                                    );

                                    // show error dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const CustomAlertDialog(
                                          dialogTitle: 'fatto!',
                                          dialogBody:
                                              'controlla la tua casella di '
                                              'posta per continuare',
                                        );
                                      },
                                    ).then((value) => Navigator.pop(context));
                                  } else {
                                    // email is not valid

                                    // show error dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const CustomAlertDialog(
                                          dialogTitle: 'errore!',
                                          dialogBody:
                                              'l\'email inserita non è valida',
                                        );
                                      },
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  // unknown error

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
                              },
                              style: ButtonStyle(
                                overlayColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.transparent),
                              ),
                            ),
                          ],
                          backgroundColor: const Color(0xff2E2E2E),
                          content: Column(
                            children: [
                              Text(
                                'se hai dimenticato la tua password, puoi '
                                'crearne una nuova.\ninserisci la tua email: '
                                'riceverai un messeggio con le istruzioni per '
                                'proseguire.',
                                style: GoogleFonts.alata(
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                child: TextField(
                                  autocorrect: false,
                                  controller: _resetEmailController,
                                  cursorColor: const Color(0xffBC91F8),
                                  decoration: InputDecoration(
                                    border: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    counterText: '',
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    hintText: 'email',
                                    hintStyle: GoogleFonts.alata(
                                      color: Colors.grey,
                                      fontSize: 17,
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(' '),
                                  ],
                                  keyboardType: TextInputType.emailAddress,
                                  maxLength: 100,
                                  style: GoogleFonts.alata(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Color(0xff1E1E1E),
                                ),
                                margin: EdgeInsets.only(
                                  top: _marginSize * 2,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ],
                            mainAxisSize: MainAxisSize.min,
                          ),
                          title: Text(
                            'reimposta la tua password',
                            style: GoogleFonts.alata(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent),
                  ),
                ),
              ],
            ),
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
  }
}
