import 'package:cached_network_image/cached_network_image.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/fetch_user_data.dart';
import 'package:eeloo/screens/chat_screen.dart';
import 'package:eeloo/screens/profile_screen.dart';
import 'package:eeloo/screens/restart_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpiredChatCard extends StatelessWidget {
  final Map chatData;
  const ExpiredChatCard({required this.chatData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: chatData['sender_uid'] == user['data']['uid']
          ? fetchUserData(chatData['recipient_uid'])
          : fetchUserData(chatData['sender_uid']),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return (snapshot.connectionState == ConnectionState.waiting)
            // snapshot is waiting
            ? Container(
                child: Row(
                  children: [
                    const SizedBox(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffBC91F8),
                        ),
                      ),
                      height: 50,
                      width: 50,
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              '',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.alata(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              '',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.alata(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                        margin: const EdgeInsets.only(
                          left: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xff1E1E1E),
                ),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                ),
              )
            : snapshot.data == null || snapshot.data['uid'] == null
                ? Container(
                    child: Row(
                      children: [
                        SizedBox(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Text(
                              '?',
                              style: GoogleFonts.alata(
                                color: Colors.white,
                                fontSize: 27,
                              ),
                            ),
                          ),
                          height: 50,
                          width: 50,
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                Text(
                                  'utente inesistente',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.alata(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  '?',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.alata(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                            margin: const EdgeInsets.only(
                              left: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color(0xff1E1E1E),
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                    ),
                  )
                : Container(
                    child: chatData['blocked_by'] == user['data']['uid']
                        // user has blocked
                        ? Row(
                            children: [
                              InkWell(
                                child: SizedBox(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      errorWidget: (BuildContext context,
                                              String url, dynamic error) =>
                                          const Icon(Icons.error),
                                      imageUrl:
                                          snapshot.data['profile_picture'],
                                      placeholder:
                                          (BuildContext context, String url) =>
                                              const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xffBC91F8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  height: 50,
                                  width: 50,
                                ),
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ProfileScreen(profile: snapshot.data),
                                    ),
                                  );
                                },
                              ),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    children: [
                                      Text(
                                        snapshot.data['username'],
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.alata(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                      Text(
                                        'hai bloccato questo utente',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.alata(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                  ),
                                  margin: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                ),
                              ),
                              SizedBox(
                                child: Container(
                                  child: const Icon(Icons.cancel_outlined),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    color: Colors.grey,
                                  ),
                                ),
                                height: 50,
                                width: 50,
                              ),
                            ],
                          )
                        : chatData['blocked_by'] == snapshot.data['uid']
                            // user is blocked
                            ? Row(
                                children: [
                                  InkWell(
                                    child: SizedBox(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          errorWidget: (BuildContext context,
                                                  String url, dynamic error) =>
                                              const Icon(Icons.error),
                                          imageUrl:
                                              snapshot.data['profile_picture'],
                                          placeholder: (BuildContext context,
                                                  String url) =>
                                              const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xffBC91F8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      height: 50,
                                      width: 50,
                                    ),
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ProfileScreen(
                                                  profile: snapshot.data),
                                        ),
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Text(
                                            snapshot.data['username'],
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.alata(
                                              color: Colors.white,
                                              fontSize: 17,
                                            ),
                                          ),
                                          Text(
                                            'ti ha bloccato',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.alata(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                      ),
                                      margin: const EdgeInsets.only(
                                        left: 10,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    child: Container(
                                      child: const Icon(Icons.cancel_outlined),
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        color: Colors.grey,
                                      ),
                                    ),
                                    height: 50,
                                    width: 50,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  InkWell(
                                    child: SizedBox(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          errorWidget: (BuildContext context,
                                                  String url, dynamic error) =>
                                              const Icon(Icons.error),
                                          imageUrl:
                                              snapshot.data['profile_picture'],
                                          placeholder: (BuildContext context,
                                                  String url) =>
                                              const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xffBC91F8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      height: 50,
                                      width: 50,
                                    ),
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ProfileScreen(
                                            profile: snapshot.data,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Text(
                                              snapshot.data['username'],
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.alata(
                                                color: Colors.white,
                                                fontSize: 17,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  child: Text(
                                                    'X',
                                                    style: GoogleFonts.alata(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                    color: Colors.grey,
                                                  ),
                                                  margin: const EdgeInsets.only(
                                                    right: 6,
                                                    top: 2,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 3,
                                                  ),
                                                ),
                                                Text(
                                                  'hai perso la streak',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.alata(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                            ),
                                          ],
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                        ),
                                        margin: const EdgeInsets.only(
                                          left: 10,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ChatScreen(
                                              chatData: chatData,
                                              senderData: snapshot.data,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  InkWell(
                                    child: SizedBox(
                                      child: Container(
                                        child: const Icon(Icons.arrow_forward),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          color: Color(0xffBC91F8),
                                        ),
                                      ),
                                      height: 50,
                                      width: 50,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              RestartChatScreen(
                                            chatData: chatData,
                                            otherUserData: snapshot.data,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color(0xff1E1E1E),
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                    ),
                  );
      },
    );
  }
}
