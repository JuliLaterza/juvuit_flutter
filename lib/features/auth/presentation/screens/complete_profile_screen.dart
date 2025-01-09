import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/auth/presentation/widgets/image_picker_grid.dart';
import 'package:juvuit_flutter/features/auth/presentation/widgets/complete_profile_form.dart';
import 'dart:io';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _songControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final TextEditingController _drinkController = TextEditingController();

  final List<File?> _images = List.generate(6, (_) => null);
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int index, ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _images[index] = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    // Lógica para guardar el perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guardando datos...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa tu Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            children: [
              ImagePickerGrid(
                images: _images,
                onPickImage: _pickImage,
              ),
              const SizedBox(height: 16),
              CompleteProfileForm(
                nameController: _nameController,
                ageController: _ageController,
                descriptionController: _descriptionController,
                songControllers: _songControllers,
                drinkController: _drinkController,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
          
                  onPressed: _saveProfile,
                  child: const Text('Guardar Perfil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
