import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/fetch_user_data.dart';
import 'package:eeloo/screens/chat_settings_screen.dart';
import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eeloo/providers/fetch_if_friends.dart';
import 'package:eeloo/screens/new_chat_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map profile;
  const ProfileScreen({required this.profile, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _imageSize = MediaQuery.of(context).size.width * 0.3;
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatSettingsScreen(
                    chatData: const {
                      'null': true,
                    },
                    senderData: profile,
                  ),
                ),
              );
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
        child: FutureBuilder(
            future: fetchIfFriends(profile['uid']),
            builder: (context, snapshot) {
              return (snapshot.connectionState == ConnectionState.waiting)
                  // snapshot is waiting
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffBC91F8),
                      ),
                    )
                  : SingleChildScrollView(
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
                                      errorWidget: (BuildContext context,
                                              String url, dynamic error) =>
                                          const Icon(Icons.error),
                                      imageUrl: profile['profile_picture'],
                                      placeholder:
                                          (BuildContext context, String url) =>
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
                                                profile['total_friends']
                                                    .toString(),
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
                                          margin:
                                              const EdgeInsets.only(right: 20),
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
                                          margin:
                                              const EdgeInsets.only(right: 20),
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
                                    user['data']['blocked_users'] != null &&
                                            user['data']['blocked_users']
                                                    [profile['uid']] !=
                                                null
                                        ? ElevatedButton(
                                            child: const Text('sblocca'),
                                            onPressed: () async {
                                              // show loading indicator
                                              showDialog(
                                                barrierDismissible: false,
                                                builder: (context) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Color(0xffBC91F8),
                                                    ),
                                                  );
                                                },
                                                context: context,
                                              );

                                              // instatiate reference of Cloud Firestore
                                              FirebaseFirestore firestore =
                                                  FirebaseFirestore.instance;

                                              // block user in data for user
                                              await firestore
                                                  .collection('uids')
                                                  .doc(user['data']['uid'])
                                                  .update(
                                                {
                                                  'blocked_users.${profile['uid']}':
                                                      FieldValue.delete(),
                                                },
                                              );

                                              // block user in chats for user
                                              await firestore
                                                  .collection('uids')
                                                  .doc(user['data']['uid'])
                                                  .collection('chats')
                                                  .doc(profile['uid'])
                                                  .update(
                                                {
                                                  'blocked_by':
                                                      FieldValue.delete(),
                                                },
                                              );

                                              // block user for other user in chats
                                              await firestore
                                                  .collection('uids')
                                                  .doc(profile['uid'])
                                                  .collection('chats')
                                                  .doc(user['data']['uid'])
                                                  .update(
                                                {
                                                  'blocked_by':
                                                      FieldValue.delete(),
                                                },
                                              );

                                              // update user data
                                              user['data'] =
                                                  await fetchUserData(
                                                      user['data']['uid']);

                                              // pop loading indicator
                                              Navigator.pop(context);

                                              // show successful dialog
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CustomAlertDialog(
                                                    dialogTitle: 'fatto!',
                                                    dialogBody: 'hai sbloccato '
                                                        '${profile['username']}.\n'
                                                        'potrebbe essere necessario'
                                                        ' un po\' di tempo perché '
                                                        'le modifiche siano effettive',
                                                  );
                                                },
                                              );
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                const Color(0xffBC91F8),
                                              ),
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                const Color(0xff121212),
                                              ),
                                              textStyle:
                                                  MaterialStateProperty.all(
                                                GoogleFonts.alata(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          )
                                        : profile['blocked_users'] != null &&
                                                profile['blocked_users']
                                                        [user['data']['uid']] !=
                                                    null
                                            ? ElevatedButton(
                                                child: const Text(
                                                    'ti ha bloccato'),
                                                onPressed: () {},
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                    const Color(0xff2E2E2E),
                                                  ),
                                                  foregroundColor:
                                                      MaterialStateProperty.all(
                                                    Colors.white,
                                                  ),
                                                  textStyle:
                                                      MaterialStateProperty.all(
                                                    GoogleFonts.alata(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : snapshot.data == false
                                                ? ElevatedButton(
                                                    child: const Text(
                                                        'avvia chat'),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              NewChatScreen(
                                                            recipientUsername:
                                                                profile[
                                                                    'username'],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                        const Color(0xffBC91F8),
                                                      ),
                                                      foregroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                        const Color(0xff121212),
                                                      ),
                                                      textStyle:
                                                          MaterialStateProperty
                                                              .all(
                                                        GoogleFonts.alata(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : ElevatedButton(
                                                    child: const Text(
                                                        'siete amici'),
                                                    onPressed: () {},
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                        const Color(0xff2E2E2E),
                                                      ),
                                                      foregroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                        Colors.white,
                                                      ),
                                                      textStyle:
                                                          MaterialStateProperty
                                                              .all(
                                                        GoogleFonts.alata(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        errorWidget: (BuildContext context,
                                                String url, dynamic error) =>
                                            const Icon(Icons.error),
                                        imageUrl: profile['post'],
                                        placeholder: (BuildContext context,
                                                String url) =>
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
                    );
            }),
      ),
    );
  }
}
