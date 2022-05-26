import 'package:eeloo/screens/account_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2E2E2E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'impostazioni',
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
                      'contatti',
                      style: GoogleFonts.alata(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '\nil tuo parere è importante! usa i contatti '
                      'che trovi qui sotto per segnalare bug, suggerire '
                      'modifiche o per fare una domanda. grazie!\n',
                      style: GoogleFonts.alata(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'filippo.valli@studenti.liceosarpi.bg.it',
                      style: GoogleFonts.alata(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'filippovalli2003@gmail.com\n',
                      style: GoogleFonts.alata(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'oppure scrivimi qua, filippo_valli :)',
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
              Container(
                child: Column(
                  children: [
                    Text(
                      'privacy',
                      style: GoogleFonts.alata(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '\ncon eeloo i tuoi dati sono al sicuro. i pochi dati che'
                      ' raccogliamo sono strettamente necessari per il '
                      'funzionamento dell\'applicazione e le tue informazioni '
                      'private sono conservate nei nostri database. nessuna '
                      'terza parte ha accesso ai database di eeloo. '
                      'i tuoi dati sensibili sono criptati prima di essere '
                      'memorizzati, affinché nemmeno gli sviluppatori possano '
                      'entrarne in possesso.',
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
              Container(
                child: InkWell(
                  child: Row(
                    children: [
                      Text(
                        'EULA e Privacy Policy',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.alata(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  onTap: () =>
                      launchUrl(Uri.parse('https://siliconvallii.github.io')),
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
                        'impostazioni dell\'account',
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
                        builder: (context) => const AccountSettingsScreen(),
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
