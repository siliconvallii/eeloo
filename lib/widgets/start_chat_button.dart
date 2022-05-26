import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eeloo/screens/new_chat_screen.dart';

class StartChatButton extends StatelessWidget {
  const StartChatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('inizia una nuova chat'),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              const NewChatScreen(recipientUsername: ''),
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          const Color(0xff63D7C6),
        ),
        foregroundColor: MaterialStateProperty.all(const Color(0xff121212)),
        textStyle: MaterialStateProperty.all(
          GoogleFonts.alata(
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
