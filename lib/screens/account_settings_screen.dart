import 'package:eeloo/data/data.dart';
import 'package:eeloo/screens/change_password_screen.dart';
import 'package:eeloo/screens/delete_account_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2E2E2E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'impostazioni dell\'account',
          style: GoogleFonts.alata(),
        ),
      ),
      backgroundColor: const Color(0xff121212),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: InkWell(
                  child: Row(
                    children: [
                      Text(
                        'esci',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.alata(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  onTap: () async {
                    // sign-out from Firebase Auth
                    await FirebaseAuth.instance.signOut();

                    // delete locally stored data
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    prefs.remove('email');
                    prefs.remove('password');

                    user['data'] = {};
                    user['chats'] = [];

                    // navigate to InitialScreen
                    Navigator.pushNamed(context, '/initial');
                  },
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
                child: InkWell(
                  child: Row(
                    children: [
                      Text(
                        'cambia password',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.alata(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
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
                child: InkWell(
                  child: Row(
                    children: [
                      Text(
                        'elimina account',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.alata(
                          color: Colors.red,
                          fontSize: 17,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.red,
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeleteAccountScreen(),
                      ),
                    );
                  },
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
            ],
          ),
        ),
      ),
    );
  }
}
