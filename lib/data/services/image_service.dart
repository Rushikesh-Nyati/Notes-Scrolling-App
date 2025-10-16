import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return await _saveAndCompressImage(File(pickedFile.path));
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  Future<File?> captureImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return await _saveAndCompressImage(File(pickedFile.path));
      }
      return null;
    } catch (e) {
      debugPrint('Error capturing image from camera: $e');
      return null;
    }
  }

  Future<File> _saveAndCompressImage(File imageFile) async {
    try {
      // Get app directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String notesDir = '${appDir.path}/notes_images';

      // Create notes directory if it doesn't exist
      final Directory notesDirObj = Directory(notesDir);
      if (!await notesDirObj.exists()) {
        await notesDirObj.create(recursive: true);
      }

      // Generate unique filename
      final String fileName =
          'note_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(notesDir, fileName);

      // Compress and save image
      final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
      if (image != null) {
        final img.Image resized = img.copyResize(image, width: 1080);
        final File compressedFile = File(filePath);
        await compressedFile.writeAsBytes(img.encodeJpg(resized, quality: 85));
        return compressedFile;
      }

      // Fallback: just copy the file
      return await imageFile.copy(filePath);
    } catch (e) {
      debugPrint('Error saving image: $e');
      return imageFile;
    }
  }

  Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }
}
