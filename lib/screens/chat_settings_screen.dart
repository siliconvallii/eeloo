import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/fetch_user_data.dart';
import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class ChatSettingsScreen extends StatefulWidget {
  final Map chatData;
  final Map senderData;
  const ChatSettingsScreen(
      {required this.chatData, required this.senderData, Key? key})
      : super(key: key);

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2E2E2E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'impostazioni chat',
          style: GoogleFonts.alata(),
        ),
      ),
      backgroundColor: const Color(0xff121212),
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  child: const Text('elimina chat'),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        actions: <TextButton>[
                          TextButton(
                            child: Text(
                              'annulla',
                              style: GoogleFonts.alata(
                                color: const Color(0xffBC91F8),
                                fontSize: 17,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.transparent),
                            ),
                          ),
                          TextButton(
                            child: Text(
                              'elimina chat',
                              style: GoogleFonts.alata(
                                color: Colors.red,
                                fontSize: 17,
                              ),
                            ),
                            onPressed: () async {
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

                              // delete chat

                              // instatiate reference of Cloud Firestore
                              FirebaseFirestore firestore =
                                  FirebaseFirestore.instance;

                              // remove chat for user
                              await firestore
                                  .collection('uids')
                                  .doc(user['data']['uid'])
                                  .collection('chats')
                                  .doc(widget.senderData['uid'])
                                  .delete();

                              // remove friend for user
                              await firestore
                                  .collection('uids')
                                  .doc(user['data']['uid'])
                                  .update(
                                {
                                  'friends.${widget.senderData['uid']}':
                                      FieldValue.delete(),
                                },
                              );

                              // remove chat for other user
                              await firestore
                                  .collection('uids')
                                  .doc(widget.senderData['uid'])
                                  .collection('chats')
                                  .doc(user['data']['uid'])
                                  .delete();

                              // remove friend for other user
                              await firestore
                                  .collection('uids')
                                  .doc(widget.senderData['uid'])
                                  .update(
                                {
                                  'friends.${user['data']['uid']}':
                                      FieldValue.delete(),
                                },
                              );

                              // pop loading indicator
                              Navigator.pop(context);

                              // navigate back to HomeScreen
                              Navigator.pushNamed(context, '/home').then(
                                (value) => setState(() {}),
                              );

                              // show successful dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const CustomAlertDialog(
                                    dialogTitle: 'fatto!',
                                    dialogBody: 'chat eliminata con successo',
                                  );
                                },
                              );
                            },
                          ),
                        ],
                        backgroundColor: const Color(0xff2E2E2E),
                        content: Text(
                          'confermi di voler eliminare la chat'
                          ' con ${widget.senderData['username']}?'
                          '\n\nl\'azione non è reversibile',
                          style: GoogleFonts.alata(
                            color: Colors.grey,
                            fontSize: 17,
                          ),
                        ),
                        title: Text(
                          'elimina chat',
                          style: GoogleFonts.alata(
                            color: Colors.white,
                            fontSize: 21,
                          ),
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.red,
                    ),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    textStyle: MaterialStateProperty.all(
                      GoogleFonts.alata(
                        fontSize: 14,
                      ),
                    ),
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
                Container(
                  child: Column(
                    children: [
                      Text(
                        'segnala ${widget.senderData['username']}',
                        style: GoogleFonts.alata(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      Container(
                        child: TextField(
                          autocorrect: false,
                          controller: _textController,
                          cursorColor: const Color(0xffBC91F8),
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            counterText: '',
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            hintText: 'motivo della segnalazione...',
                            hintStyle: GoogleFonts.alata(
                              color: Colors.grey,
                              fontSize: 17,
                            ),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLength: 500,
                          maxLines: null,
                          style: GoogleFonts.alata(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                        margin: EdgeInsets.only(
                          bottom: _marginSize,
                          left: _marginSize,
                          right: _marginSize,
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
                ElevatedButton(
                  child: const Text('segnala'),
                  onPressed: () async {
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

                    // generate random report id
                    String reportId = const Uuid().v4();

                    // instatiate reference of Cloud Firestore
                    FirebaseFirestore firestore = FirebaseFirestore.instance;

                    // upload report
                    await firestore.collection('reports').doc(reportId).set(
                      {
                        'report_id': reportId,
                        'reported_user': widget.senderData,
                        'reported_chat': widget.chatData,
                        'reported_by': user['data'],
                        'report_reason': _textController.text,
                      },
                    );

                    // pop loading indicator
                    Navigator.pop(context);

                    // navigate back to HomeScreen
                    Navigator.pushNamed(context, '/home').then(
                      (value) => setState(() {}),
                    );

                    // show successful dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const CustomAlertDialog(
                          dialogTitle: 'fatto!',
                          dialogBody: 'segnalazione inviata con successo',
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.red,
                    ),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    textStyle: MaterialStateProperty.all(
                      GoogleFonts.alata(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text('blocca utente'),
                  onPressed: () async {
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

                    // instatiate reference of Cloud Firestore
                    FirebaseFirestore firestore = FirebaseFirestore.instance;

                    // block user in data for user
                    await firestore
                        .collection('uids')
                        .doc(user['data']['uid'])
                        .update(
                      {
                        'blocked_users.${widget.senderData['uid']}':
                            widget.senderData['uid'],
                      },
                    );

                    // block user in chats for user
                    await firestore
                        .collection('uids')
                        .doc(user['data']['uid'])
                        .collection('chats')
                        .doc(widget.senderData['uid'])
                        .update(
                      {
                        'blocked_by': user['data']['uid'],
                      },
                    );

                    // block user for other user in chats
                    await firestore
                        .collection('uids')
                        .doc(widget.senderData['uid'])
                        .collection('chats')
                        .doc(user['data']['uid'])
                        .update(
                      {
                        'blocked_by': user['data']['uid'],
                      },
                    );

                    // update user data
                    user['data'] = await fetchUserData(user['data']['uid']);

                    // pop loading indicator
                    Navigator.pop(context);

                    // navigate back to HomeScreen
                    Navigator.pushNamed(context, '/home').then(
                      (value) => setState(() {}),
                    );

                    // show successful dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomAlertDialog(
                          dialogTitle: 'fatto!',
                          dialogBody:
                              'hai bloccato ${widget.senderData['username']}',
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.red,
                    ),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    textStyle: MaterialStateProperty.all(
                      GoogleFonts.alata(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
      ),
    );
  }
}
