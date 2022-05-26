import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/upload_image.dart';
import 'package:eeloo/services/local_notifications_service.dart';
import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void replyToChat(context, image, text, chatData, senderData) async {
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

    // upload image
    String imageUrl = await uploadImage(image);

    if (chatData['penultimate'] != null) {
      // delete old image

      try {
        await FirebaseStorage.instance
            .refFromURL(chatData['penultimate']['image'])
            .delete();
      } on Exception {
        null;
      }
    }

    // remove third last message
    chatData['penultimate'] = null;

    // create chat Map
    Map<String, dynamic> chat = {
      'image': imageUrl,
      'is_recipient_random': FieldValue.delete(),
      'is_chat_expired': FieldValue.delete(),
      'text': text,
      'sender_uid': user['data']['uid'],
      'sender_username': user['data']['username'],
      'sent_at': DateTime.now().toString(),
      'recipient_uid': senderData['uid'],
      'penultimate': chatData,
      'streak': chatData['streak'] + 1,
    };

    // update chat locally
    List tempChats = [];

    for (Map _chat in user['chats']) {
      if (_chat['sender_uid'] == senderData['uid']) {
        _chat = chat;
      }
      tempChats.add(_chat);
    }
    user['chats'] = tempChats;

    // instatiate reference of Cloud Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // upload chat and friend for sender
    await firestore
        .collection('uids')
        .doc(user['data']['uid'])
        .collection('chats')
        .doc(senderData['uid'])
        .update(chat);

    await firestore.collection('uids').doc(user['data']['uid']).update(
      {
        'friends.${senderData['uid']}': senderData['uid'],
      },
    );

    // upload chat and friend for recipient
    await firestore
        .collection('uids')
        .doc(senderData['uid'])
        .collection('chats')
        .doc(user['data']['uid'])
        .update(chat);

    await firestore.collection('uids').doc(senderData['uid']).update(
      {
        'friends.${user['data']['uid']}': user['data']['uid'],
      },
    );

    // send notification
    FirebaseFunctions.instance.httpsCallable('sendNotification').call(
      {
        'sender_username': user['data']['username'],
        'recipient_fcm_token': senderData['fcm_token'],
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

    // delete notification schedule
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? notificationId = prefs.getInt(senderData['uid']);
    prefs.remove(senderData['uid']);

    LocalNotificationService.deleteScheduledNotification(notificationId);
  }
}
