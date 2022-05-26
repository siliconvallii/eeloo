import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eeloo/widgets/custom_alert_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/providers/upload_image.dart';
import 'package:eeloo/utils/crop_image_to_square.dart';
import 'package:eeloo/utils/pick_image.dart';
import 'package:eeloo/utils/take_image.dart';

class ModifyProfileScreen extends StatefulWidget {
  final Map profile;
  const ModifyProfileScreen({required this.profile, Key? key})
      : super(key: key);

  @override
  State<ModifyProfileScreen> createState() => _ModifyProfileScreenState();
}

class _ModifyProfileScreenState extends State<ModifyProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  File? _image;
  File? _post;

  String _dropdownValue = 'I';
  String _secondDropdownValue = 'A';

  @override
  Widget build(BuildContext context) {
    double _imageSize = MediaQuery.of(context).size.width * 0.3;
    double _marginSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2E2E2E),
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.profile['username'],
          style: GoogleFonts.alata(),
        ),
      ),
      backgroundColor: const Color(0xff121212),
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _image == null
                              ? CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  errorWidget: (BuildContext context,
                                          String url, dynamic error) =>
                                      const Icon(Icons.error),
                                  imageUrl: widget.profile['profile_picture'],
                                  placeholder:
                                      (BuildContext context, String url) =>
                                          const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xffBC91F8),
                                    ),
                                  ),
                                )
                              : Image.file(
                                  _image!,
                                  fit: BoxFit.fill,
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
                                      widget.profile['total_friends']
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
                                margin: const EdgeInsets.only(right: 20),
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Container(
                                      child: DropdownButton<String>(
                                        dropdownColor: const Color(0xff2E2E2E),
                                        items: classes,
                                        onChanged: (newValue) => setState(() {
                                          _dropdownValue = newValue.toString();
                                        }),
                                        style: GoogleFonts.alata(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                        value: _dropdownValue,
                                      ),
                                      margin:
                                          EdgeInsets.only(left: _marginSize),
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
                                  Container(
                                    child: DropdownButton<String>(
                                      dropdownColor: const Color(0xff2E2E2E),
                                      items: sections,
                                      onChanged: (newValue) => setState(() {
                                        _secondDropdownValue =
                                            newValue.toString();
                                      }),
                                      style: GoogleFonts.alata(
                                        color: Colors.white,
                                        fontSize: 17,
                                      ),
                                      value: _secondDropdownValue,
                                    ),
                                    margin: EdgeInsets.only(left: _marginSize),
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
                          TextButton(
                            child: Text(
                              'prendi immagine dalla libreria',
                              style: GoogleFonts.alata(
                                color: const Color(0xffBC91F8),
                                fontSize: 14,
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
                                fontSize: 14,
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
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      const Spacer(),
                    ],
                  ),
                  Container(
                    child: TextField(
                      autocorrect: false,
                      controller: _usernameController,
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
                        hintText: 'username...',
                        hintStyle: GoogleFonts.alata(
                          color: Colors.grey,
                          fontSize: 17,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp("[a-z0-9_]"),
                        ),
                      ],
                      keyboardType: TextInputType.text,
                      maxLength: 20,
                      maxLines: 1,
                      style: GoogleFonts.alata(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: _marginSize,
                    ),
                  ),
                  Container(
                    child: TextField(
                      autocorrect: false,
                      controller: _bioController,
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
                        hintText: 'scrivi una breve bio...',
                        hintStyle: GoogleFonts.alata(
                          color: Colors.grey,
                          fontSize: 17,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      maxLength: 150,
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
                  widget.profile['post'] == null
                      ? TextButton(
                          child: Text(
                            'carica un post',
                            style: GoogleFonts.alata(
                              color: const Color(0xffBC91F8),
                              fontSize: 14,
                            ),
                          ),
                          onPressed: () async {
                            // pick image
                            XFile? tempImage = await pickImage();

                            // crop image to square
                            File? image = await cropImageToSquare(tempImage!);

                            // initialize image
                            setState(() {
                              _post = image;
                            });
                          },
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (states) => Colors.transparent),
                          ),
                        )
                      : TextButton(
                          child: Text(
                            'cambia post',
                            style: GoogleFonts.alata(
                              color: const Color(0xffBC91F8),
                              fontSize: 14,
                            ),
                          ),
                          onPressed: () async {
                            // pick image
                            XFile? tempImage = await pickImage();

                            // crop image to square
                            File? image = await cropImageToSquare(tempImage!);

                            // initialize image
                            setState(() {
                              _post = image;
                            });
                          },
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (states) => Colors.transparent),
                          ),
                        ),
                  widget.profile['post'] == null && _post == null
                      ? Container()
                      : SizedBox(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _post != null
                                ? Image.file(
                                    _post!,
                                    fit: BoxFit.fill,
                                  )
                                : CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    errorWidget: (BuildContext context,
                                            String url, dynamic error) =>
                                        const Icon(Icons.error),
                                    imageUrl: widget.profile['post'],
                                    placeholder:
                                        (BuildContext context, String url) =>
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
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: _marginSize,
                vertical: _marginSize,
              ),
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
      floatingActionButton: ElevatedButton(
        child: const Text('conferma modifiche'),
        onPressed: () async {
          // check if there are image and text

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

          // update username
          if (_usernameController.text != '') {
            if (_usernameController.text.length > 2) {
              // check if username already exists
              bool usernameExists = false;

              await firestore.collection('usernames').get().then(
                (QuerySnapshot querySnapshot) {
                  for (QueryDocumentSnapshot username in querySnapshot.docs) {
                    if (username.id == _usernameController.text) {
                      usernameExists = true;
                    }
                  }
                },
              );

              if (usernameExists) {
                // username already exists

                // pop loading indicator
                Navigator.pop(context);

                // show error dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CustomAlertDialog(
                      dialogTitle: 'errore!',
                      dialogBody: 'questo username esiste già',
                    );
                  },
                );

                return;
              } else {
                // username doesn't exist

                // update username in uids
                await firestore
                    .collection('uids')
                    .doc(user['data']['uid'])
                    .update(
                  {
                    'username': _usernameController.text,
                  },
                );

                // update username in usernames
                await firestore
                    .collection('usernames')
                    .doc(user['data']['username'])
                    .delete();

                await firestore
                    .collection('usernames')
                    .doc(_usernameController.text)
                    .set(
                  {
                    'uid': user['data']['uid'],
                    'fcm_token': user['data']['fcm_token'],
                  },
                );
              }
            } else {
              // username is too short
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const CustomAlertDialog(
                    dialogTitle: 'errore!',
                    dialogBody: 'il tuo username è troppo breve',
                  );
                },
              );
            }
          }

          // update profile picture
          if (_image != null) {
            // upload image
            String imageUrl = await uploadImage(_image!);

            // delete old image
            try {
              await FirebaseStorage.instance
                  .refFromURL(user['data']['profile_picture'])
                  .delete();
            } catch (e) {
              null;
            }

            // update profile picture
            await firestore.collection('uids').doc(user['data']['uid']).update(
              {
                'profile_picture': imageUrl,
              },
            );
          }

          // update bio
          if (_bioController.text != '') {
            // update bio
            await firestore.collection('uids').doc(user['data']['uid']).update(
              {
                'bio': _bioController.text,
              },
            );
          }

          // update class
          if (_dropdownValue != widget.profile['class']) {
            // update class
            await firestore.collection('uids').doc(user['data']['uid']).update(
              {
                'class': _dropdownValue,
              },
            );
          }

          // update section
          if (_secondDropdownValue != widget.profile['section']) {
            // update section
            await firestore.collection('uids').doc(user['data']['uid']).update(
              {
                'section': _secondDropdownValue,
              },
            );
          }

          // update post
          if (_post != null) {
            // upload image
            String imageUrl = await uploadImage(_post!);

            try {
              // delete old image
              await FirebaseStorage.instance
                  .refFromURL(user['data']['post'])
                  .delete();
            } catch (e) {
              null;
            }

            // update post
            await firestore.collection('uids').doc(user['data']['uid']).update(
              {
                'post': imageUrl,
              },
            );
          }

          // update locally stored user data
          await firestore
              .collection('uids')
              .doc(user['data']['uid'])
              .get()
              .then(
                (DocumentSnapshot documentSnapshot) =>
                    user['data'] = documentSnapshot.data(),
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
                dialogBody: 'hai modificato il tuo profilo',
              );
            },
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            const Color(0xff63D7C6),
          ),
          foregroundColor: MaterialStateProperty.all(
            const Color(0xff121212),
          ),
          textStyle: MaterialStateProperty.all(
            GoogleFonts.alata(
              fontSize: 14,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
