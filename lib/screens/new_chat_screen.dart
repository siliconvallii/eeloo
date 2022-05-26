import 'dart:io';
import 'package:eeloo/providers/start_new_chat.dart';
import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/fetch_random_user.dart';
import 'package:eeloo/utils/crop_image_to_square.dart';
import 'package:eeloo/utils/pick_image.dart';
import 'package:eeloo/utils/take_image.dart';
import 'package:url_launcher/url_launcher.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({required this.recipientUsername, Key? key})
      : super(key: key);

  final String recipientUsername;

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  File? _image;

  bool _isObscured = false;
  bool _isEnabled = true;
  bool _isRecipientDefined = false;

  @override
  Widget build(BuildContext context) {
    if (widget.recipientUsername != '') {
      setState(() {
        _isRecipientDefined = true;
      });
      _recipientController.text = widget.recipientUsername;
    }
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2E2E2E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'nuova chat',
          style: GoogleFonts.alata(),
        ),
      ),
      backgroundColor: const Color(0xff121212),
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _isObscured
                    ? Container(
                        child: Column(
                          children: [
                            Text(
                              'questo messaggio sarà inviato a un destinatario '
                              'casuale. il destinatario vedrà che sei stato tu a '
                              'scrivere e saprà di essere stato scelto casualmente.',
                              style: GoogleFonts.alata(
                                color: Colors.grey,
                                fontSize: 17,
                              ),
                            ),
                            InkWell(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '\nricorda di rispettare ',
                                      style: GoogleFonts.alata(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'EULA',
                                      style: GoogleFonts.alata(
                                        color: Colors.grey,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' e ',
                                      style: GoogleFonts.alata(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: GoogleFonts.alata(
                                        color: Colors.grey,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () => launchUrl(
                                  Uri.parse('https://siliconvallii.github.io')),
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
                        margin: EdgeInsets.all(
                          _marginSize,
                        ),
                        padding: EdgeInsets.all(
                          _marginSize,
                        ),
                      )
                    : Container(),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Column(
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
                            Row(
                              children: [
                                Text(
                                  'a: ',
                                  style: GoogleFonts.alata(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    child: TextField(
                                      autocorrect: false,
                                      controller: _recipientController,
                                      cursorColor: const Color(0xffBC91F8),
                                      decoration: InputDecoration(
                                        border: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                        counterText: '',
                                        enabledBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        hintText: 'destinatario...',
                                        hintStyle: GoogleFonts.alata(
                                          color: Colors.grey,
                                          fontSize: 17,
                                        ),
                                      ),
                                      enabled: _isRecipientDefined
                                          ? false
                                          : _isEnabled,
                                      keyboardType: TextInputType.text,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp("[a-z0-9_]"),
                                        ),
                                      ],
                                      maxLength: 50,
                                      obscureText: _isObscured,
                                      style: GoogleFonts.alata(
                                        color: _isEnabled == false ||
                                                _isRecipientDefined
                                            ? Colors.grey
                                            : Colors.white,
                                        fontSize: 17,
                                      ),
                                    ),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: _marginSize,
                                    ),
                                  ),
                                ),
                                _isRecipientDefined
                                    ? Container()
                                    : _isObscured
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.cancel_outlined,
                                              color: Color(0xffBC91F8),
                                            ),
                                            onPressed: () {
                                              _recipientController.text = '';
                                              setState(() {
                                                _isEnabled = true;
                                                _isObscured = false;
                                              });
                                            },
                                          )
                                        : IconButton(
                                            icon: const Icon(
                                              Icons.person_search,
                                              color: Color(0xffBC91F8),
                                            ),
                                            onPressed: () async {
                                              String randomUser =
                                                  await fetchRandomUser();

                                              if (randomUser == '') {
                                                // random user not found
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return const CustomAlertDialog(
                                                      dialogTitle: 'errore!',
                                                      dialogBody:
                                                          'non è stato possibile '
                                                          'trovare un destinatario casuale',
                                                    );
                                                  },
                                                );
                                              } else {
                                                // random user was found

                                                setState(() {
                                                  _isObscured = true;
                                                  _isEnabled = false;
                                                });

                                                _recipientController.text =
                                                    randomUser;
                                              }
                                            },
                                          ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.center,
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            contentPadding: EdgeInsets.zero,
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
                          maxLength: 200,
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
                    onPressed: () => startNewChat(
                      context,
                      _image,
                      _textController.text,
                      _recipientController.text,
                      _isObscured,
                    ),
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
