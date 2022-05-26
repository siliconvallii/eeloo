import 'package:eeloo/data/data.dart';
import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future emailSignUp(BuildContext context, String email, String password) async {
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

  // fetch email domain
  List<String> emailStrings = email.split('@');
  String emailDomain = emailStrings[1];

  // check if email is allowed
  if (allowedEmailDomains.contains(emailDomain)) {
    // email is allowed
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // pop loading indicator
      Navigator.pop(context);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // password is weak

        // pop loading indicator
        Navigator.pop(context);

        // show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlertDialog(
              dialogTitle: 'errore!',
              dialogBody: 'la password che hai inserito è troppo debole',
            );
          },
        );
      } else if (e.code == 'email-already-in-use') {
        // account already exists

        // pop loading indicator
        Navigator.pop(context);

        // show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomAlertDialog(
              dialogTitle: 'errore!',
              dialogBody:
                  'l\'email che hai inserito è già collegata ad un account',
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
  } else {
    // email isn't allowed

    // pop loading indicator
    Navigator.pop(context);

    // show error dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CustomAlertDialog(
          dialogTitle: 'ops...',
          dialogBody: 'eeloo è riservato ai soli studenti di alcune scuole '
              'selezionate.\n\n'
              'l\'email che hai utilizzato non è autorizzata ad accedere.\n'
              'assicurati di utilizzare la tua email istituzionale.\n\n'
              'puoi verificare se gli studenti della tua scuola possono '
              'accedere a eeloo nella descrizione dell\'applicazione su '
              'App Store e Play Store.',
        );
      },
    );
  }
}
