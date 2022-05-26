import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImage() async {
  // pick image
  final XFile? image = await ImagePicker().pickImage(
    imageQuality: 50,
    source: ImageSource.camera,
  );
  return image;
}
