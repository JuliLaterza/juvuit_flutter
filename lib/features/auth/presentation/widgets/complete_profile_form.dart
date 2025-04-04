import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:intl/intl.dart';

class CompleteProfileForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<TextEditingController> songControllers;
  final TextEditingController drinkController;
  final void Function(String?) onSignChanged;
  final void Function(String?) onDrinkChanged;

  const CompleteProfileForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.songControllers,
    required this.drinkController,
    required this.onSignChanged,
    required this.onDrinkChanged,
  });

  @override
  State<CompleteProfileForm> createState() => CompleteProfileFormState();
}

class CompleteProfileFormState extends State<CompleteProfileForm> {
  String? _selectedSign;
  String? _selectedDrink;
  DateTime? _selectedDate;

  DateTime? get selectedBirthDate => _selectedDate;

  final List<Map<String, dynamic>> signosZodiacales = [
    {'signo': 'Aries', 'icono': Icons.whatshot},
    {'signo': 'Tauro', 'icono': Icons.grass},
    {'signo': 'Géminis', 'icono': Icons.wb_twighlight},
    {'signo': 'Cáncer', 'icono': Icons.nights_stay},
    {'signo': 'Leo', 'icono': Icons.wb_sunny},
    {'signo': 'Virgo', 'icono': Icons.eco},
    {'signo': 'Libra', 'icono': Icons.balance},
    {'signo': 'Escorpio', 'icono': Icons.water},
    {'signo': 'Sagitario', 'icono': Icons.architecture},
    {'signo': 'Capricornio', 'icono': Icons.terrain},
    {'signo': 'Acuario', 'icono': Icons.bubble_chart},
    {'signo': 'Piscis', 'icono': Icons.alarm},
  ];

  final List<String> _drinks = [
    'Cerveza', 'Fernet', 'WhisCola', 'Vino', 'Whisky', 'Ron',
    'Vodka', 'Tequila', 'Gin', 'Champagne', 'Gaseosas', 'Agua',
  ];

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
        const SizedBox(height: 16),
        _buildDropdownField('Signo Zodiacal', signosZodiacales, _selectedSign, (value) {
          setState(() => _selectedSign = value);
          widget.onSignChanged(value);
        }),
        const SizedBox(height: 16),
        const Center(child: Text('AGREGA TUS CANCIONES FAVORITAS', style: TextStyle(fontWeight: FontWeight.bold))),
        ...List.generate(widget.songControllers.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildInputField(widget.songControllers[i], 'Canción ${i + 1}', Icons.music_note),
          );
        }),
        const SizedBox(height: 16),
        const Center(child: Text('AGREGA TU TRAGO FAVORITO', style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        _buildDropdownList('Trago Favorito', _drinks, _selectedDrink, (value) {
          setState(() => _selectedDrink = value);
          widget.onDrinkChanged(value);
        }),
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
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow),
            ),
          ),
          controller: TextEditingController(
            text: _selectedDate == null ? '' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
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
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.yellow),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<Map<String, dynamic>> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.yellow),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['signo'],
          child: Row(
            children: [
              Icon(item['icono'], color: AppColors.yellow),
              const SizedBox(width: 8),
              Text(item['signo']),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownList(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.yellow),
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }
}
