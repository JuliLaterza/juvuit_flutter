import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/auth/presentation/widgets/complete_profile_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/features/profile/data/services/save_user_profile.dart';
import 'package:juvuit_flutter/features/upload_imag/storage_service.dart';
import 'package:juvuit_flutter/features/onboarding/presentation/screens/personality_onboarding_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final GlobalKey<CompleteProfileFormState> _formKey = GlobalKey<CompleteProfileFormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _drinkController = TextEditingController();

  final List<File?> _images = List.generate(6, (_) => null);
  final List<String> _preloadedUrls = [];
  final ImagePicker _picker = ImagePicker();

  String? _selectedSign;
  String? _selectedDrink;

  Future<void> _pickImage(int index, ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _images[index] = File(pickedFile.path);
      });
    }
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return false;
    }
    return true;
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    final birthDate = _formKey.currentState?.selectedBirthDate;
    final topSongs = _formKey.currentState?.selectedSongs ?? [];

    final StorageService storageService = StorageService();
    List<String> photoUrls = [];
    try {
      for (final img in _images) {
        if (img != null && await img.exists()) {
          final url = await storageService.uploadUserImage(userId: currentUser.uid, file: img);
          if (url != null) {
            photoUrls.add(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo subir una de las imágenes. Intenta con otra.')),
            );
            return;
          }
        }
      }
      // Agregar las URLs precargadas
      photoUrls.addAll(_preloadedUrls);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error subiendo imágenes: $e')),
      );
      return;
    }

    await saveUserProfile(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      sign: _selectedSign,
      birthDate: birthDate,
      photoUrls: photoUrls,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil guardado')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PersonalityOnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Completa tu Perfil',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sube tus mejores fotos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildImagePickerGrid(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CompleteProfileForm(
                  key: _formKey,
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  drinkController: _drinkController,
                  onSignChanged: (value) => _selectedSign = value,
                  onDrinkChanged: (value) => _selectedDrink = value,
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveProfile,
                      child: const Text(
                        'Guardar Perfil',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerGrid() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageSourceDialog(index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: _images[index] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _images[index]!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.add_a_photo, size: 40),
            ),
          );
        },
      ),
    );
  }

  void _showImageSourceDialog(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(index, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de la galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(index, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
