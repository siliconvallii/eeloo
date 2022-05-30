import 'dart:io';
import 'package:eeloo/data/data.dart';
import 'package:eeloo/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eeloo/providers/create_profile.dart';
import 'package:eeloo/utils/crop_image_to_square.dart';
import 'package:eeloo/utils/pick_image.dart';
import 'package:eeloo/utils/take_image.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({
    required this.uid,
    required this.email,
    Key? key,
  }) : super(key: key);

  final String uid;
  final String email;

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  void _createProfile() async {
    // Check if profile picture is missing
    if (_profilePicture == null) {
      // Profile picture is missing
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('errore!'),
            content: Text('devi inserire un\'immagine del profilo'),
          );
        },
      );

      // Shut down function
      return;
    }

    // Check if username is too short
    if (_usernameController.text.length < 3) {
      // Username is too short
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('errore!'),
            content: Text('il tuo username è troppo breve'),
          );
        },
      );

      // Shut down function
      return;
    }

    // Check if bio is missing
    if (_bioController.text == '') {
      // Bio is missing
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('errore!'),
            content: Text('devi scrivere una bio per continuare'),
          );
        },
      );

      // Shut down function
      return;
    }

    // Upload profile to Cloud Firestore
    try {
      // Create profile
      await createProfile(
        _usernameController.text,
        widget.uid,
        _profilePicture!,
        _classDropdownValue,
        _sectionDropdownValue,
        _bioController.text,
        widget.email,
      );

      // Navigate to HomeScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const HomeScreen();
          },
        ),
        (Route route) => false,
      );
    } catch (e) {
      // Check which error occurred
      if (e == 'username-already-exists') {
        // Username already exists
        // Show dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('errore!'),
              content: Text('l\'username inserito è già stato preso'),
            );
          },
        );
      } else {
        // An unknown error occurred
        // Show dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('errore!'),
              content: Text(e.toString()),
            );
          },
        );
      }
    }
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _profilePicture;
  String _classDropdownValue = 'I';
  String _sectionDropdownValue = 'A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    // Profile picture Column
                    Column(
                      children: [
                        SizedBox(
                          child: _profilePicture == null
                              // There is no profile picture
                              ? Container()
                              // There is profile picture
                              : Image.file(_profilePicture!),
                          width: double.infinity,
                        ),
                        // Profile picture from library TextButton
                        TextButton(
                          child: const Text('prendi immagine dalla libreria'),
                          onPressed: () async {
                            // Take image from library
                            XFile? tempImage = await takeImage();

                            // Crop image to square
                            File? image = await cropImageToSquare(tempImage!);

                            // Initialize profile picture
                            setState(() => _profilePicture = image);
                          },
                        ),
                        // Profile picture from camera TextButton
                        TextButton(
                          child: const Text('scatta fotografia'),
                          onPressed: () async {
                            // Pick image from camera
                            XFile? tempImage = await pickImage();

                            // Crop image to square
                            File? image = await cropImageToSquare(tempImage!);

                            // Initialize profile picture
                            setState(() => _profilePicture = image);
                          },
                        ),
                      ],
                    ),
                    // Username TextField
                    TextField(
                      autocorrect: false,
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintText: 'username',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp("[a-z0-9_]"),
                        ),
                      ],
                      maxLength: 30,
                      maxLines: 1,
                    ),
                    // Full name TextField
                    TextField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        hintText: 'full name',
                      ),
                      keyboardType: TextInputType.name,
                      maxLength: 50,
                      maxLines: 1,
                    ),
                    // Bio TextField
                    TextField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        hintText: 'biografia',
                      ),
                      keyboardType: TextInputType.text,
                      maxLength: 150,
                      maxLines: null,
                    ),
                    // Class and section Row
                    Row(
                      children: [
                        // Class DropdownButton
                        const Text('classe:'),
                        DropdownButton(
                          items: classes,
                          onChanged: (newValue) {
                            setState(() =>
                                _classDropdownValue = newValue.toString());
                          },
                          value: _classDropdownValue,
                        ),
                        // Section DropdownButton
                        DropdownButton(
                          items: sections,
                          onChanged: (newValue) {
                            setState(() =>
                                _sectionDropdownValue = newValue.toString());
                          },
                          value: _sectionDropdownValue,
                        ),
                      ],
                    ),
                  ],
                ),
                // Create profile ElevatedButton
                ElevatedButton(
                  child: const Text('completa registrazione'),
                  onPressed: () => _createProfile(),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // Close keyboard if user taps on screen
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
