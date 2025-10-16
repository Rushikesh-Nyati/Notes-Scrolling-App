import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/services/image_service.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(File) onImageSelected;
  final ImageService _imageService = ImageService();

  ImagePickerBottomSheet({super.key, required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blue),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              Navigator.pop(context);
              final File? image = await _imageService.pickImageFromGallery();
              if (image != null) {
                onImageSelected(image);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text('Take a Photo'),
            onTap: () async {
              Navigator.pop(context);
              final File? image = await _imageService.captureImageFromCamera();
              if (image != null) {
                onImageSelected(image);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.grey),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, Function(File) onImageSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          ImagePickerBottomSheet(onImageSelected: onImageSelected),
    );
  }
}
