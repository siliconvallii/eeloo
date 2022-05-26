import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> cropImageToSquare(XFile image) async {
  File? croppedImage = await ImageCropper().cropImage(
    sourcePath: image.path,
    aspectRatio: const CropAspectRatio(
      ratioX: 1,
      ratioY: 1,
    ),
  );

  return croppedImage;
}
