import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> fetchData(context) async {
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

  // store locally email & password
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  Map<String, String> data = {};

  String email = prefs.getString('email') ?? '';
  data['email'] = email;

  String password = prefs.getString('password') ?? '';
  data['password'] = password;

  // pop loading indicator
  Navigator.pop(context);

  return data;
}
