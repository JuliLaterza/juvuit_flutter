// Archivo: features/profile/presentation/screens/edit_profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/profile/data/services/user_profile_service.dart';
import 'package:juvuit_flutter/core/services/spotify_service.dart';
import 'package:juvuit_flutter/features/upload_imag/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _drinkController = TextEditingController();
  final List<File?> _images = List.generate(6, (_) => null);
  final ImagePicker _picker = ImagePicker();
  List<String> _existingPhotoUrls = [];

  final List<TextEditingController> _songControllers = List.generate(3, (_) => TextEditingController());
  List<Map<String, String>> _selectedSongs = List.generate(3, (_) => {'title': '', 'artist': '', 'imageUrl': ''});
  final List<List<Map<String, String>>> _suggestions = List.generate(3, (_) => []);
  final List<bool> _isSearching = List.generate(3, (_) => false);

  bool _isLoading = true;

  final List<String> _drinks = [
    'Cerveza', 'Fernet', 'WhisCola', 'Vino', 'Whisky', 'Ron',
    'Vodka', 'Tequila', 'Gin', 'Champagne', 'Gaseosas', 'Agua',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profile = await UserProfileService().getUserProfile(user.uid);
    if (profile == null) return;

    setState(() {
      _nameController.text = profile.name;
      _descriptionController.text = profile.description;
      _drinkController.text = profile.favoriteDrink;
      _selectedSongs = List.generate(3, (i) {
        if (i < profile.topSongs.length) {
          final song = profile.topSongs[i];
          return {
            'title': song['title']?.toString() ?? '',
            'artist': song['artist']?.toString() ?? '',
            'imageUrl': song['imageUrl']?.toString() ?? '',
          };
        } else {
          return {'title': '', 'artist': '', 'imageUrl': ''};
        }
      });
      _existingPhotoUrls = profile.photoUrls;
      _isLoading = false;
    });
  }

  Future<void> _pickImage(int index, ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _images[index] = File(pickedFile.path);
        if (index < _existingPhotoUrls.length) {
          _existingPhotoUrls[index] = '';
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. Mantener solo las URLs existentes que no fueron eliminadas
    List<String> finalPhotoUrls = List<String>.from(_existingPhotoUrls.where((url) => url.isNotEmpty));

    // 2. Subir nuevas imágenes locales y agregar sus URLs
    for (int i = 0; i < _images.length; i++) {
      final img = _images[i];
      if (img != null) {
        final url = await StorageService().uploadUserImage(userId: user.uid, file: img);
        if (url != null) {
          if (i < finalPhotoUrls.length) {
            finalPhotoUrls[i] = url;
          } else {
            finalPhotoUrls.add(url);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo subir una de las imágenes. Intenta con otra.')),
          );
          return;
        }
      }
    }

    // 3. Limitar a máximo 6 fotos
    if (finalPhotoUrls.length > 6) {
      finalPhotoUrls = finalPhotoUrls.sublist(0, 6);
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'drink': _drinkController.text.trim(),
      'top_3canciones': _selectedSongs,
      'photoUrls': finalPhotoUrls,
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
    }
  }

  void _onSearchChanged(String query, int index) async {
    if (query.length < 2) {
      if (mounted) {
        setState(() => _suggestions[index] = []);
      }
      return;
    }
    if (mounted) {
      setState(() => _isSearching[index] = true);
    }
    try {
      final results = await SpotifyService.searchSongs(query);
      if (mounted) {
        setState(() => _suggestions[index] = results);
      }
    } catch (e) {
      print('Error buscando canciones: $e');
    }
    if (mounted) {
      setState(() => _isSearching[index] = false);
    }
  }

  void _selectSong(Map<String, String> song, int index) {
    setState(() {
      _selectedSongs[index] = song;
      _songControllers[index].text = '';
      _suggestions[index] = [];
    });
  }

  Future<void> _deleteImage(int index) async {
    // Si la imagen es una URL existente, eliminar de Storage y de la lista
    if (index < _existingPhotoUrls.length && _existingPhotoUrls[index].isNotEmpty) {
      final url = _existingPhotoUrls[index];
      try {
        await StorageService().deleteUserImage(url);
      } catch (e) {
        // Puedes mostrar un mensaje de error si lo deseas
      }
      setState(() {
        _existingPhotoUrls.removeAt(index);
        _images.removeAt(index);
        _images.add(null); // Mantener tamaño 6
      });
    } else if (_images[index] != null) {
      // Si es una imagen local, solo quitarla
      setState(() {
        _images[index] = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tus fotos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildImageGrid(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildInputField(_nameController, 'Nombre', Icons.person),
              const SizedBox(height: 16),
              _buildTextArea(_descriptionController, 'Descripción', Icons.edit),
              const SizedBox(height: 16),
              const Center(child: Text('AGREGA TUS CANCIONES FAVORITAS', style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              for (int i = 0; i < 3; i++) ...[
                TextField(
                  controller: _songControllers[i],
                  onChanged: (value) => _onSearchChanged(value, i),
                  decoration: InputDecoration(
                    hintText: _selectedSongs[i]['title'] ?? 'Buscar canción ${i + 1}...',
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
              _buildDropdownList('Trago favorito', _drinks, _drinkController.text, (value) {
                setState(() {
                  _drinkController.text = value ?? '';
                });
              }),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.yellow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _saveChanges,
                    child: const Text(
                      'Guardar Cambios',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: AppColors.yellow),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray),
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: AppColors.yellow),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray),
        ),
      ),
    );
  }

  Widget _buildDropdownList(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(selectedValue) ? selectedValue : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray),
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildImageGrid() {
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
        itemCount: 6,
        itemBuilder: (context, index) {
          final imageFile = _images[index];
          final hasUploadedImage = index < _existingPhotoUrls.length && _existingPhotoUrls[index].isNotEmpty;

          Widget imageWidget;
          if (imageFile != null) {
            imageWidget = Image.file(imageFile, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
          } else if (hasUploadedImage) {
            imageWidget = Image.network(_existingPhotoUrls[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity);
          } else {
            imageWidget = const Icon(Icons.add_a_photo, size: 40);
          }

          return GestureDetector(
            onTap: () => _showImageSourceDialog(index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageWidget,
                    if (imageFile != null || hasUploadedImage)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deleteImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
      });
  }
}
