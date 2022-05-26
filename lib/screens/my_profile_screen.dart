import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eeloo/screens/modify_profile_screen.dart';
import 'package:eeloo/screens/settings_screen.dart';

class MyProfileScreen extends StatelessWidget {
  final Map profile;
  const MyProfileScreen({required this.profile, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _imageSize = MediaQuery.of(context).size.width * 0.3;
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            onLongPress: () {
              Navigator.pushNamed(context, '/info');
            },
          ),
        ],
        backgroundColor: const Color(0xff2E2E2E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          profile['username'],
          style: GoogleFonts.alata(),
        ),
      ),
      backgroundColor: const Color(0xff121212),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          errorWidget: (BuildContext context, String url,
                                  dynamic error) =>
                              const Icon(Icons.error),
                          imageUrl: profile['profile_picture'],
                          placeholder: (BuildContext context, String url) =>
                              const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xffBC91F8),
                            ),
                          ),
                        ),
                      ),
                      height: _imageSize,
                      width: _imageSize,
                    ),
                    const Spacer(flex: 2),
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  Text(
                                    profile['total_friends'].toString(),
                                    style: GoogleFonts.alata(
                                      color: Colors.white,
                                      fontSize: 21,
                                    ),
                                  ),
                                  Text(
                                    'amici',
                                    style: GoogleFonts.alata(
                                      color: Colors.grey,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                              margin: const EdgeInsets.only(right: 20),
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Text(
                                    profile['class'],
                                    style: GoogleFonts.alata(
                                      color: Colors.white,
                                      fontSize: 21,
                                    ),
                                  ),
                                  Text(
                                    'classe',
                                    style: GoogleFonts.alata(
                                      color: Colors.grey,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                              margin: const EdgeInsets.only(right: 20),
                            ),
                            Column(
                              children: [
                                Text(
                                  profile['section'],
                                  style: GoogleFonts.alata(
                                    color: Colors.white,
                                    fontSize: 21,
                                  ),
                                ),
                                Text(
                                  'sezione',
                                  style: GoogleFonts.alata(
                                    color: Colors.grey,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          child: const Text('modifica profilo'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ModifyProfileScreen(profile: profile),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              const Color(0xffBC91F8),
                            ),
                            foregroundColor: MaterialStateProperty.all(
                                const Color(0xff121212)),
                            textStyle: MaterialStateProperty.all(
                              GoogleFonts.alata(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    const Spacer(),
                  ],
                ),
                profile['school'] == null
                    ? Container(
                        child: Text(
                          'Liceo P. Sarpi',
                          style: GoogleFonts.alata(
                            color: Colors.grey,
                            fontSize: 17,
                          ),
                        ),
                        margin: EdgeInsets.only(
                          top: _marginSize,
                        ),
                      )
                    : Container(
                        child: Text(
                          profile['school'],
                          style: GoogleFonts.alata(
                            color: Colors.grey,
                            fontSize: 17,
                          ),
                        ),
                        margin: EdgeInsets.only(
                          top: _marginSize,
                        ),
                      ),
                Container(
                  child: Text(
                    profile['username'],
                    style: GoogleFonts.alata(
                      color: Colors.white,
                      fontSize: 19,
                    ),
                  ),
                  margin: EdgeInsets.only(
                    top: _marginSize / 2,
                  ),
                ),
                Container(
                  child: Text(
                    profile['bio'],
                    style: GoogleFonts.alata(
                      color: Colors.grey,
                    ),
                  ),
                  margin: EdgeInsets.only(
                    top: _marginSize / 2,
                  ),
                ),
                Container(
                  child: const Divider(
                    color: Colors.grey,
                  ),
                  margin: EdgeInsets.only(
                    bottom: _marginSize,
                    top: _marginSize,
                  ),
                ),
                profile['post'] == null
                    ? Container()
                    : SizedBox(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            errorWidget: (BuildContext context, String url,
                                    dynamic error) =>
                                const Icon(Icons.error),
                            imageUrl: profile['post'],
                            placeholder: (BuildContext context, String url) =>
                                const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xffBC91F8),
                              ),
                            ),
                          ),
                        ),
                        width: double.infinity,
                      ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: _marginSize,
              vertical: _marginSize,
            ),
          ),
        ),
      ),
    );
  }
}
