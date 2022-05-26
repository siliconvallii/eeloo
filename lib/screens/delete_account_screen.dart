import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eeloo/data/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2E2E2E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'elimina account',
          style: GoogleFonts.alata(),
        ),
      ),
      backgroundColor: const Color(0xff121212),
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Text(
                    'siamo dispiaciuti che tu voglia eliminare il tuo '
                    'account. se hai voglia, contattaci per dirci perché '
                    'te ne stai andando: ci farebbe molto piacere sapere '
                    'la tua opinione su eeloo.\n\n'
                    'ricorda che questa è un\'azione irreversibile, quando '
                    'avrai cancellato il tuo account nessuna informazione '
                    'sarà conservata.\n\n'
                    'per continuare, inserisci l\'email e la password '
                    'collegate al tuo account.',
                    style: GoogleFonts.alata(
                      color: Colors.grey,
                    ),
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff1E1E1E),
                  ),
                  margin: EdgeInsets.only(
                    left: _marginSize,
                    right: _marginSize,
                    top: _marginSize,
                  ),
                  padding: const EdgeInsets.all(10),
                ),
                Container(
                  child: TextField(
                    autocorrect: false,
                    controller: _emailController,
                    cursorColor: const Color(0xffBC91F8),
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      hintText: 'email',
                      hintStyle: GoogleFonts.alata(
                        color: Colors.grey,
                        fontSize: 17,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 50,
                    style: GoogleFonts.alata(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff1E1E1E),
                  ),
                  margin: EdgeInsets.only(
                    left: _marginSize,
                    right: _marginSize,
                    top: _marginSize,
                  ),
                  padding: const EdgeInsets.all(10),
                ),
                Container(
                  child: TextField(
                    autocorrect: false,
                    controller: _passwordController,
                    cursorColor: const Color(0xffBC91F8),
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      hintText: 'password',
                      hintStyle: GoogleFonts.alata(
                        color: Colors.grey,
                        fontSize: 17,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    maxLength: 50,
                    obscureText: true,
                    style: GoogleFonts.alata(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff1E1E1E),
                  ),
                  margin: EdgeInsets.only(
                    left: _marginSize,
                    right: _marginSize,
                    top: _marginSize,
                  ),
                  padding: const EdgeInsets.all(10),
                ),
                ElevatedButton(
                  child: const Text('elimina account'),
                  onPressed: () async {
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

                    // sign-in user
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      // instatiate reference of Cloud Firestore
                      FirebaseFirestore firestore = FirebaseFirestore.instance;

                      // delete user in uids
                      await firestore
                          .collection('uids')
                          .doc(user['data']['uid'])
                          .delete();

                      // delete user in usernames
                      await firestore
                          .collection('usernames')
                          .doc(user['data']['username'])
                          .delete();

                      // delete all chats
                      await firestore.collection('uids').get().then(
                        (QuerySnapshot querySnapshot) async {
                          for (QueryDocumentSnapshot doc
                              in querySnapshot.docs) {
                            String _userUid = doc.id;

                            try {
                              await firestore
                                  .collection('uids')
                                  .doc(_userUid)
                                  .collection('chats')
                                  .doc(user['data']['uid'])
                                  .delete();
                            } catch (e) {
                              null;
                            }
                          }
                        },
                      );

                      // delete user from Firebase Auth
                      await FirebaseAuth.instance.currentUser!.delete();

                      // delete locally stored data
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      prefs.remove('email');
                      prefs.remove('password');

                      user = {};

                      // pop loading indicator
                      Navigator.pop(context);

                      Navigator.pushNamed(context, '/initial');

                      // show success dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const CustomAlertDialog(
                            dialogTitle: 'fatto!',
                            dialogBody: 'hai eliminato il tuo account',
                          );
                        },
                      );
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        // user not found

                        // pop loading indicator
                        Navigator.pop(context);

                        // show error dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const CustomAlertDialog(
                              dialogTitle: 'errore!',
                              dialogBody: 'non esiste un\'account collegato a'
                                  ' questa email',
                            );
                          },
                        );
                      } else if (e.code == 'wrong-password') {
                        // password is wrong

                        // pop loading indicator
                        Navigator.pop(context);

                        // show error dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const CustomAlertDialog(
                              dialogTitle: 'errore!',
                              dialogBody: 'la password inserita è sbagliata',
                            );
                          },
                        );
                      }
                    } catch (e) {
                      // unknown error

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
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    textStyle: MaterialStateProperty.all(
                      GoogleFonts.alata(
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        onTap: () {
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
