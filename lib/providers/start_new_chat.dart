import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/upload_image.dart';
import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';

void startNewChat(
  BuildContext context,
  File? image,
  String text,
  String recipientUsername,
  bool isRecipientRandom,
) async {
  // check if there are image and text
  if (image == null) {
    // image is missing
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CustomAlertDialog(
          dialogTitle: 'errore!',
          dialogBody: 'devi inserire un\'immagine per continuare',
        );
      },
    );
  } else if (text == '') {
    // text is missing
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CustomAlertDialog(
          dialogTitle: 'errore!',
          dialogBody: 'devi scrivere un messaggio per continuare',
        );
      },
    );
  } else {
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

    // find user with username
    await firestore.collection('usernames').doc(recipientUsername).get().then(
      (DocumentSnapshot value) async {
        dynamic _tempRecipientData = value.data();

        // check if user was found
        if (_tempRecipientData == null) {
          // user wasn't found

          // pop loading indicator
          Navigator.pop(context);

          // show error
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                dialogTitle: 'errore!',
                dialogBody:
                    'sembra che l\'utente $recipientUsername non esista',
              );
            },
          );
        } else if (_tempRecipientData['uid'] == user['data']['uid']) {
          // user is trying to message himself

          // pop loading indicator
          Navigator.pop(context);

          // show error
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const CustomAlertDialog(
                dialogTitle: 'errore!',
                dialogBody: 'non puoi scrivere a te stesso',
              );
            },
          );
        } else {
          // user was found

          String _recipientUid = _tempRecipientData['uid'];
          String _recipientFcm = _tempRecipientData['fcm_token'];

          // check if chat already exists
          await firestore
              .collection('uids')
              .doc(user['data']['uid'])
              .collection('chats')
              .get()
              .then(
            (QuerySnapshot querySnapshot) async {
              Map _userChats = {};

              for (DocumentSnapshot doc in querySnapshot.docs) {
                _userChats[doc.id] = doc.data();
              }

              if (_userChats != {} && _userChats[_recipientUid] != null) {
                // chat already exists

                // pop loading indicator
                Navigator.pop(context);

                if (_userChats[_recipientUid]['blocked_by'] == _recipientUid) {
                  // sender is blocked by recipient

                  // show error dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomAlertDialog(
                        dialogTitle: 'errore!',
                        dialogBody: '$recipientUsername ti ha bloccato',
                      );
                    },
                  );
                } else {
                  // show error dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomAlertDialog(
                        dialogTitle: 'errore!',
                        dialogBody:
                            'tu e $recipientUsername avete già una chat',
                      );
                    },
                  );
                }
              } else {
                // chat is new

                dynamic _recipientData = {};

                // fetch recipient user
                await firestore
                    .collection('uids')
                    .doc(_recipientUid)
                    .get()
                    .then(
                  (DocumentSnapshot docSnapshot) {
                    _recipientData = docSnapshot.data();
                  },
                );

                // check if user was blocked by recipient
                if (_recipientData['blocked_users'] != null &&
                    _recipientData['blocked_users'][user['data']['uid']] !=
                        null) {
                  // user is blocked by recipient

                  // pop loading indicator
                  Navigator.pop(context);

                  // navigate back to HomeScreen
                  Navigator.pushNamed(context, '/home');

                  // show error dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomAlertDialog(
                        dialogTitle: 'errore!',
                        dialogBody: '$recipientUsername ti ha bloccato',
                      );
                    },
                  );
                } else {
                  // start new chat

                  // upload image
                  String imageUrl = await uploadImage(image);

                  // create chat Map
                  Map<String, dynamic> chat = {
                    'image': imageUrl,
                    'text': text,
                    'sender_uid': user['data']['uid'],
                    'sender_username': user['data']['username'],
                    'is_recipient_random': isRecipientRandom,
                    'sent_at': DateTime.now().toString(),
                    'recipient_uid': _recipientUid,
                    'streak': 1,
                  };

                  // store chat locally
                  if (user['chats'] == null) {
                    user['chats'] = [];
                  }
                  user['chats'].add(chat);

                  // upload chat to sender
                  await firestore
                      .collection('uids')
                      .doc(user['data']['uid'])
                      .collection('chats')
                      .doc(_recipientUid)
                      .set(chat);

                  // upload chat to recipient
                  await firestore
                      .collection('uids')
                      .doc(_recipientUid)
                      .collection('chats')
                      .doc(user['data']['uid'])
                      .set(chat);

                  // send notification
                  FirebaseFunctions.instance
                      .httpsCallable('sendNotification')
                      .call(
                    {
                      'sender_username': user['data']['username'],
                      'recipient_fcm_token': _recipientFcm,
                    },
                  );

                  // pop loading indicator
                  Navigator.pop(context);

                  // navigate back to HomeScreen
                  Navigator.pushNamed(context, '/home');

                  // show successful dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const CustomAlertDialog(
                        dialogTitle: 'fatto!',
                        dialogBody: 'messaggio inviato con successo',
                      );
                    },
                  );
                }
              }
            },
          );
        }
      },
    );
  }
}
