import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPassController = TextEditingController();

  final TextEditingController _firstNewPassController = TextEditingController();
  final TextEditingController _secondNewPassController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2E2E2E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'cambia password',
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
                  child: TextField(
                    autocorrect: false,
                    controller: _oldPassController,
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
                      hintText: 'vecchia password...',
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
                Container(
                  child: TextField(
                    autocorrect: false,
                    controller: _firstNewPassController,
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
                      hintText: 'nuova password...',
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
                Container(
                  child: TextField(
                    autocorrect: false,
                    controller: _secondNewPassController,
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
                      hintText: 'ripeti la nuova password...',
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
                  child: const Text('cambia password'),
                  onPressed: () async {
                    if (_firstNewPassController.text ==
                        _secondNewPassController.text) {
                      // passwords are correct

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

                      User user = FirebaseAuth.instance.currentUser!;

                      // Pass in the password to updatePassword.
                      await user
                          .updatePassword(_firstNewPassController.text)
                          .then(
                        (value) {
                          // password was changed

                          // pop loading indicator
                          Navigator.pop(context);

                          // show success dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const CustomAlertDialog(
                                dialogTitle: 'fatto!',
                                dialogBody: 'hai cambiato la tua password',
                              );
                            },
                          );
                        },
                      ).catchError(
                        (error) {
                          // an error occurred
                          // pop loading indicator
                          Navigator.pop(context);

                          // show error dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const CustomAlertDialog(
                                dialogTitle: 'errore!',
                                dialogBody: 'prova con un\'altra password',
                              );
                            },
                          );
                        },
                      );
                    } else {
                      // passwords are different

                      // show success dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const CustomAlertDialog(
                            dialogTitle: 'errore!',
                            dialogBody: 'le due password non corrispondono',
                          );
                        },
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xff63D7C6),
                    ),
                    foregroundColor:
                        MaterialStateProperty.all(const Color(0xff121212)),
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
