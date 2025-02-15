import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class CompleteProfileForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController descriptionController;
  final List<TextEditingController> songControllers;
  final TextEditingController drinkController;

  const CompleteProfileForm({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.descriptionController,
    required this.songControllers,
    required this.drinkController,
    
  });

  @override
  State<CompleteProfileForm> createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  String? _selectedSign;
  String? _selectedDrink;

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
    'Cerveza',
    'Fernet',
    'WhisCola',
    'Vino',
    'Whisky',
    'Ron',
    'Vodka',
    'Tequila',
    'Gin',
    'Champagne',
    'Gaseosas',
    'Agua',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow)
            )
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: widget.ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Edad', //pedir fecha de nacimiento
            border: OutlineInputBorder(
              
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow)
            )
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: widget.descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(
              
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow)
            )
          ),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          value: _selectedSign,
          decoration: const InputDecoration(
            labelText: 'Signo Zodiacal',
            border: OutlineInputBorder(
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow)
            )
          ),
          items: signosZodiacales.map((signoData) {
            return DropdownMenuItem<String>(
              value: signoData['signo'],
              child: Row(
                children: [
                  Icon(
                    signoData['icono'],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(signoData['signo']),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSign = value;
            });
          },
        ),
        const SizedBox(height: 24),
        Center(
          child: const Text(
            'AGREGA TUS CANCIONES FAVORITAS',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        for (int i = 0; i < widget.songControllers.length; i++) ...[
          const SizedBox(height: 16),
          TextField(
            controller: widget.songControllers[i],
            decoration: InputDecoration(
              labelText: 'Canción ${i + 1}',
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.yellow),
              ),
              focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow)
            )
            ),
          ),
        ],
        const SizedBox(height: 24),
        Center(
          child: const Text(
            'AGREGA TU TRAGO FAVORITO',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        /* TextField(
          controller: widget.drinkController,
          decoration: const InputDecoration(
            labelText: 'Trago Favorito',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow)
            )
          ),
        ), */
        DropdownButtonFormField<String>(
          value: _selectedDrink,
          decoration: const InputDecoration(
            labelText: 'Trago Favorito',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow)
            )
          ),
          items: _drinks.map((drink) {
            return DropdownMenuItem<String>(
              value: drink,
              child: Text(drink),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDrink = value;
            });
          },
        ),
      ],
    );
  }
}
