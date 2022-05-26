import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eeloo/providers/reply_to_chat.dart';
import 'package:eeloo/screens/chat_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/utils/crop_image_to_square.dart';
import 'package:eeloo/utils/pick_image.dart';
import 'package:eeloo/utils/take_image.dart';

class RestartChatScreen extends StatefulWidget {
  final Map chatData;
  final Map otherUserData;
  const RestartChatScreen(
      {required this.chatData, required this.otherUserData, Key? key})
      : super(key: key);

  @override
  State<RestartChatScreen> createState() => _RestartChatScreenState();
}

class _RestartChatScreenState extends State<RestartChatScreen> {
  final TextEditingController _textController = TextEditingController();

  File? _image;

  @override
  Widget build(BuildContext context) {
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatSettingsScreen(
                    chatData: widget.chatData,
                    senderData: widget.otherUserData,
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
          'chat',
          style: GoogleFonts.alata(),
        ),
      ),
      backgroundColor: const Color(0xff121212),
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                widget.chatData['is_recipient_random'] != null &&
                        widget.chatData['is_recipient_random'] == true
                    ? Container(
                        child: Text(
                          widget.otherUserData['uid'] == user['data']['uid']
                              ? 'hai inviato questo messaggio a un destinatario '
                                  'casuale, che è ${widget.chatData['username']}! :)'
                              : 'questo messaggio è stato inviato a un '
                                  'destinatario casuale, che sei tu! :)',
                          style: GoogleFonts.alata(
                            color: Colors.grey,
                            fontSize: 17,
                          ),
                        ),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                          color: Color(0xff1E1E1E),
                        ),
                        margin: EdgeInsets.all(
                          _marginSize,
                        ),
                        padding: EdgeInsets.all(
                          _marginSize,
                        ),
                      )
                    : Container(),
                Container(
                  child: Text(
                    'ultimo messaggio:',
                    style: GoogleFonts.alata(
                      color: Colors.grey,
                    ),
                  ),
                  margin: EdgeInsets.all(
                    _marginSize,
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Container(
                              child: SizedBox(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    errorWidget: (BuildContext context,
                                            String url, dynamic error) =>
                                        const Icon(Icons.error),
                                    imageUrl: widget
                                                .chatData['recipient_uid'] ==
                                            user['data']['uid']
                                        ? widget
                                            .otherUserData['profile_picture']
                                        : user['data']['profile_picture'],
                                    placeholder:
                                        (BuildContext context, String url) =>
                                            const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xffBC91F8),
                                      ),
                                    ),
                                  ),
                                ),
                                height: 40,
                                width: 40,
                              ),
                              margin: EdgeInsets.only(
                                right: _marginSize,
                              ),
                            ),
                            Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'da: ',
                                        style: GoogleFonts.alata(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            widget.chatData['sender_username'],
                                        style: GoogleFonts.alata(
                                          color: Colors.grey,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'a: ',
                                        style: GoogleFonts.alata(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            widget.chatData['recipient_uid'] ==
                                                    user['data']['uid']
                                                ? user['data']['username']
                                                : widget
                                                    .otherUserData['username'],
                                        style: GoogleFonts.alata(
                                          color: Colors.grey,
                                          fontSize: 17,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ],
                        ),
                        margin: EdgeInsets.all(
                          _marginSize,
                        ),
                      ),
                      SizedBox(
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          errorWidget: (BuildContext context, String url,
                                  dynamic error) =>
                              const Icon(Icons.error),
                          imageUrl: widget.chatData['image'],
                          placeholder: (BuildContext context, String url) =>
                              const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xffBC91F8),
                            ),
                          ),
                        ),
                        width: double.infinity,
                      ),
                      Container(
                        child: Text(
                          widget.chatData['text'],
                          style: GoogleFonts.alata(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                        margin: EdgeInsets.all(
                          _marginSize,
                        ),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: Color(0xff1E1E1E),
                  ),
                  margin: EdgeInsets.all(_marginSize),
                ),
                Container(
                  child: Text(
                    'riprendi chat:',
                    style: GoogleFonts.alata(
                      color: Colors.grey,
                    ),
                  ),
                  margin: EdgeInsets.all(
                    _marginSize,
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Container(
                              child: SizedBox(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    errorWidget: (BuildContext context,
                                            String url, dynamic error) =>
                                        const Icon(Icons.error),
                                    imageUrl: user['data']['profile_picture'],
                                    placeholder:
                                        (BuildContext context, String url) =>
                                            const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xffBC91F8),
                                      ),
                                    ),
                                  ),
                                ),
                                height: 40,
                                width: 40,
                              ),
                              margin: EdgeInsets.only(
                                right: _marginSize,
                              ),
                            ),
                            Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'da: ',
                                        style: GoogleFonts.alata(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                      TextSpan(
                                        text: user['data']['username'],
                                        style: GoogleFonts.alata(
                                          color: Colors.grey,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'a: ',
                                        style: GoogleFonts.alata(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                      TextSpan(
                                        text: widget.otherUserData['username'],
                                        style: GoogleFonts.alata(
                                          color: Colors.grey,
                                          fontSize: 17,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ],
                        ),
                        margin: EdgeInsets.all(
                          _marginSize,
                        ),
                      ),
                      SizedBox(
                        child:
                            _image == null ? Container() : Image.file(_image!),
                        width: double.infinity,
                      ),
                      TextButton(
                        child: Text(
                          'prendi immagine dalla libreria',
                          style: GoogleFonts.alata(
                            color: const Color(0xffBC91F8),
                            fontSize: 17,
                          ),
                        ),
                        onPressed: () async {
                          // take image
                          XFile? tempImage = await takeImage();

                          // crop image to square
                          File? image = await cropImageToSquare(tempImage!);

                          // initialize image
                          setState(() {
                            _image = image;
                          });
                        },
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent),
                        ),
                      ),
                      TextButton(
                        child: Text(
                          'scatta fotografia',
                          style: GoogleFonts.alata(
                            color: const Color(0xffBC91F8),
                            fontSize: 17,
                          ),
                        ),
                        onPressed: () async {
                          // pick image
                          XFile? tempImage = await pickImage();

                          // crop image to square
                          File? image = await cropImageToSquare(tempImage!);

                          // initialize image
                          setState(() {
                            _image = image;
                          });
                        },
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent),
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
                            hintText: 'scrivi messaggio...',
                            hintStyle: GoogleFonts.alata(
                              color: Colors.grey,
                              fontSize: 17,
                            ),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLength: 500,
                          maxLines: null,
                          onSubmitted: (string) {
                            // dismiss keyboard
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          style: GoogleFonts.alata(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                          textInputAction: TextInputAction.done,
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
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: Color(0xff1E1E1E),
                  ),
                  margin: EdgeInsets.all(_marginSize),
                ),
                Container(
                  child: ElevatedButton(
                    child: const Text('invia messaggio'),
                    onPressed: () {
                      replyToChat(
                        context,
                        _image,
                        _textController.text,
                        widget.chatData,
                        widget.otherUserData,
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        const Color(0xff63D7C6),
                      ),
                      foregroundColor:
                          MaterialStateProperty.all(const Color(0xff121212)),
                      textStyle: MaterialStateProperty.all(
                        GoogleFonts.alata(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  margin: EdgeInsets.only(
                    bottom: _marginSize,
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
