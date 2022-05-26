import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAlertDialog extends StatelessWidget {
  final String dialogTitle;
  final String dialogBody;
  const CustomAlertDialog(
      {required this.dialogTitle, required this.dialogBody, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        dialogTitle,
        style: GoogleFonts.alata(
          color: Colors.white,
          fontSize: 21,
        ),
      ),
      content: Text(
        dialogBody,
        style: GoogleFonts.alata(
          color: Colors.grey,
          fontSize: 17,
        ),
      ),
      actions: <TextButton>[
        TextButton(
          child: Text(
            'ok',
            style: GoogleFonts.alata(
              color: const Color(0xffBC91F8),
              fontSize: 17,
            ),
          ),
          onPressed: () => Navigator.pop(context),
          style: ButtonStyle(
            overlayColor:
                MaterialStateColor.resolveWith((states) => Colors.transparent),
          ),
        ),
      ],
      backgroundColor: const Color(0xff2E2E2E),
    );
  }
}
