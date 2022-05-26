import 'package:eeloo/data/data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2E2E2E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'informazioni',
          style: GoogleFonts.alata(),
        ),
      ),
      backgroundColor: const Color(0xff121212),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Text(
                      'informazioni sulla build',
                      style: GoogleFonts.alata(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      'versione: $localVersion',
                      style: GoogleFonts.alata(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'uid: ${user['data']['uid']}',
                      style: GoogleFonts.alata(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
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
