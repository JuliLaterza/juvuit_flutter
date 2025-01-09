import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:juvuit_flutter/core/utils/colors.dart';

class ImagePickerGrid extends StatefulWidget {
  final List<File?> images;
  final Function(int, ImageSource) onPickImage;

  const ImagePickerGrid({
    super.key,
    required this.images,
    required this.onPickImage,
  });

  @override
  State<ImagePickerGrid> createState() => _ImagePickerGridState();
}

class _ImagePickerGridState extends State<ImagePickerGrid> {
  void _showImagePickerOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.4, // Ocupa el 40% de la pantalla
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(context);
                widget.onPickImage(index, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.pop(context);
                widget.onPickImage(index, ImageSource.camera);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(widget.images.length, (index) {
        final image = widget.images[index];
        return GestureDetector(
          onTap: () => _showImagePickerOptions(index),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(8),
              image: image != null
                  ? DecorationImage(
                      image: FileImage(image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: image == null
                ? const Center(
                    child: Icon(
                      Icons.add,
                      size: 40,
                      color: AppColors.gray,
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }
}
