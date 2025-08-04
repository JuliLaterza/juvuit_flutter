import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:juvuit_flutter/core/services/spotify_service.dart';

class CompleteProfileForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController drinkController;
  final void Function(String?) onDrinkChanged;
  final List<Map<String, dynamic>>? initialSongs;

  const CompleteProfileForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.drinkController,
    required this.onDrinkChanged,
    this.initialSongs,
  });

  @override
  State<CompleteProfileForm> createState() => CompleteProfileFormState();
}

class CompleteProfileFormState extends State<CompleteProfileForm> {
  String? _selectedDrink;
  DateTime? _selectedDate;
  late TextEditingController _dateController;

  DateTime? get selectedBirthDate => _selectedDate;
  List<Map<String, String>> get selectedSongs =>
      _selectedSongs.whereType<Map<String, String>>().toList();

  final List<TextEditingController> _songControllers = List.generate(3, (_) => TextEditingController());
  final List<Map<String, String>?> _selectedSongs = List.filled(3, null);
  final List<List<Map<String, String>>> _suggestions = List.generate(3, (_) => []);
  final List<bool> _isSearching = List.generate(3, (_) => false);



  final List<String> _drinks = [
    'Cerveza', 'Fernet', 'WhisCola', 'Vino', 'Whisky', 'Ron',
    'Vodka', 'Tequila', 'Gin', 'Champagne', 'Gaseosas', 'Agua',
  ];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    if (widget.initialSongs != null) {
      for (int i = 0; i < widget.initialSongs!.length && i < 3; i++) {
        _selectedSongs[i] = {
          'title': widget.initialSongs![i]['title']?.toString() ?? '',
          'artist': widget.initialSongs![i]['artist']?.toString() ?? '',
          'imageUrl': widget.initialSongs![i]['imageUrl']?.toString() ?? '',
        };
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Actualizar el controlador de texto con la fecha seleccionada
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });

      if (_calculateAge(picked) < 18) {
        _showUnderageDialog();
      }
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showUnderageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acceso restringido'),
        content: const Text('Debes ser mayor de 18 años para registrarte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(widget.nameController, 'Nombre', Icons.person),
        const SizedBox(height: 16),
        _buildDatePicker(context),
        const SizedBox(height: 16),
        _buildTextArea(widget.descriptionController, 'Descripción', Icons.edit),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Fecha de nacimiento',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.calendar_today, color: AppColors.yellow),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow),
            ),
          ),
          controller: _dateController,
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
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.yellow),
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
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.yellow),
        ),
      ),
    );
  }



  Widget _buildDropdownList(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.yellow),
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }
}
