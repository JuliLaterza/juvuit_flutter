import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/auth/presentation/widgets/complete_profile_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/features/profile/data/services/save_user_profile.dart';
import 'package:juvuit_flutter/features/upload_imag/storage_service.dart';
import 'package:juvuit_flutter/features/onboarding/presentation/screens/personality_onboarding_screen.dart';
import 'package:juvuit_flutter/core/services/spotify_service.dart';

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

    // Debug: Verificar que la fecha se está obteniendo correctamente
    print('DEBUG: birthDate from form: $birthDate');
    if (birthDate != null) {
      print('DEBUG: birthDate formatted: ${birthDate.toIso8601String()}');
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

class CompleteSongsDrinkScreen extends StatefulWidget {
  const CompleteSongsDrinkScreen({super.key});

  @override
  State<CompleteSongsDrinkScreen> createState() => _CompleteSongsDrinkScreenState();
}

class _CompleteSongsDrinkScreenState extends State<CompleteSongsDrinkScreen> {
  final List<TextEditingController> _songControllers = List.generate(3, (_) => TextEditingController());
  List<Map<String, String>> _selectedSongs = List.generate(3, (_) => {'title': '', 'artist': '', 'imageUrl': ''});
  final List<List<Map<String, String>>> _suggestions = List.generate(3, (_) => []);
  final List<bool> _isSearching = List.generate(3, (_) => false);
  String? _selectedDrink;
  bool _isLoading = false;

  final List<String> _drinks = [
    'Cerveza', 'Fernet', 'WhisCola', 'Vino', 'Whisky', 'Ron',
    'Vodka', 'Tequila', 'Gin', 'Champagne', 'Gaseosas', 'Agua',
  ];

  void _onSearchChanged(String query, int index) async {
    if (query.length < 2) {
      setState(() => _suggestions[index] = []);
      return;
    }
    setState(() => _isSearching[index] = true);
    try {
      final results = await SpotifyService.searchSongs(query);
      setState(() => _suggestions[index] = results);
    } catch (e) {
      print('Error buscando canciones: $e');
    }
    setState(() => _isSearching[index] = false);
  }

  void _selectSong(Map<String, String> song, int index) {
    setState(() {
      _selectedSongs[index] = song;
      _songControllers[index].text = '';
      _suggestions[index] = [];
    });
  }

  Future<void> _saveSongsAndDrink() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
        return;
      }

      // Filtrar solo las canciones que tienen título
      final topSongs = _selectedSongs
          .where((song) => song['title']!.isNotEmpty)
          .toList();

      // Obtener las fotos existentes del usuario para no sobrescribirlas
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      List<String> existingPhotoUrls = [];
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        existingPhotoUrls = List<String>.from(userData['photoUrls'] ?? []);
      }

      // Usar la función específica para actualizar solo canciones y trago
      await updateUserSongsAndDrink(
        topSongs: topSongs,
        drink: _selectedDrink ?? '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completá tu perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Completá estos datos para poder conectar en eventos de fiesta',
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              const Center(child: Text('AGREGA TUS CANCIONES FAVORITAS', style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              for (int i = 0; i < 3; i++) ...[
                TextField(
                  controller: _songControllers[i],
                  onChanged: (value) => _onSearchChanged(value, i),
                  decoration: InputDecoration(
                    hintText: _selectedSongs[i]['title']!.isNotEmpty ? _selectedSongs[i]['title'] : 'Buscar canción ${i + 1}...',
                    prefixIcon: _selectedSongs[i]['imageUrl']!.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.network(
                              _selectedSongs[i]['imageUrl']!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.music_note, color: AppColors.yellow),
                    suffixIcon: _selectedSongs[i]['title']!.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedSongs[i] = {'title': '', 'artist': '', 'imageUrl': ''};
                                _songControllers[i].clear();
                              });
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_isSearching[i]) const CircularProgressIndicator(),
                if (_suggestions[i].isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestions[i].length,
                    itemBuilder: (context, index2) {
                      final song = _suggestions[i][index2];
                      return ListTile(
                        leading: Image.network(song['imageUrl']!, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(song['title']!),
                        subtitle: Text(song['artist']!),
                        onTap: () => _selectSong(song, i),
                      );
                    },
                  ),
                const SizedBox(height: 12),
              ],
              const Center(child: Text('AGREGA TU TRAGO FAVORITO', style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDrink,
                decoration: InputDecoration(
                  labelText: 'Trago favorito',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.yellow),
                  ),
                ),
                items: _drinks.map((drink) => DropdownMenuItem(
                  value: drink,
                  child: Text(drink),
                )).toList(),
                onChanged: (value) => setState(() => _selectedDrink = value),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveSongsAndDrink,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
