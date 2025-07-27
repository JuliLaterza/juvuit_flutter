import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/events/presentation/screens/events_screen.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/profile/data/services/save_user_profile.dart';

class PersonalityOnboardingScreen extends StatefulWidget {
  const PersonalityOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<PersonalityOnboardingScreen> createState() => _PersonalityOnboardingScreenState();
}

class _PersonalityOnboardingScreenState extends State<PersonalityOnboardingScreen> {
  String? _gender;
  DateTime? _birthDate;
  List<String> _interests = [];
  String? _lookingFor;
  String? _job;
  bool? _hasDegree;
  String? _university;
  String? _smoke;
  final List<String> _smokeOptions = ['No', 'Socialmente', 'Seguido'];
  final List<String> _personalTraits = [
    'Creatividad', 'Naturaleza', 'Arte', 'Cine', 'Fotografía', 'Yoga', 'Deportes',
    'Reiki', 'Meditación', 'Introvertido', 'Extrovertido', 'Música', 'Lectura',
    'Tecnología', 'Viajes', 'Cocina', 'Mascotas', 'Voluntariado', 'Gaming',
    'Moda', 'Ciencia', 'Política', 'Espiritualidad', 'Humor', 'Baile',
  ];
  List<String> _selectedTraits = [];
  String? _studies;
  bool _isLoading = false;

  final List<String> _genders = ['Hombre', 'Mujer', 'Prefiero no decirlo'];
  final List<String> _interestOptions = [
    'Recitales',
    'Festivales',
    'Boliches',
    'Plazas',
  ];
  final List<String> _lookingForOptions = ['Mujeres', 'Hombres', 'Ambos'];

  void _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_interests.contains(interest)) {
        _interests.remove(interest);
      } else {
        _interests.add(interest);
      }
    });
  }

  void _finishOnboarding() async {
    setState(() => _isLoading = true);
    try {
      await saveUserPersonality(
        gender: _gender,
        interests: _interests,
        lookingFor: _lookingFor,
        job: _job,
        studies: _studies,
        university: _university,
        smoke: _smoke,
        traits: _selectedTraits,
        profileComplete: true,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EventsScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando perfil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre vos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Text(
                  '¡Cuantos más datos completes, más personalizado será tu perfil y tus recomendaciones!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ),
              _sectionTitle('¿Con qué género te identificás?'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _genders.map((g) => ChoiceChip(
                  label: Text(g, style: TextStyle(color: _gender == g ? AppColors.black : Colors.grey[800], fontSize: 14)),
                  selected: _gender == g,
                  onSelected: (_) => setState(() => _gender = g),
                  showCheckmark: false,
                  selectedColor: AppColors.yellow,
                  backgroundColor: Colors.grey[200],
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                )).toList(),
              ),
              const SizedBox(height: 20),
              _sectionTitle('¿Cuáles son tus intereses sociales?'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _interestOptions.map((interest) => FilterChip(
                  label: Text(interest, style: TextStyle(color: _interests.contains(interest) ? AppColors.black : Colors.grey[800], fontSize: 14)),
                  selected: _interests.contains(interest),
                  onSelected: (_) => _toggleInterest(interest),
                  showCheckmark: false,
                  selectedColor: AppColors.yellow,
                  backgroundColor: Colors.grey[200],
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                )).toList(),
              ),
              const SizedBox(height: 20),
              _sectionTitle('¿A quién te gustaría conocer?'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _lookingForOptions.map((opt) => ChoiceChip(
                  label: Text(opt, style: TextStyle(color: _lookingFor == opt ? AppColors.black : Colors.grey[800], fontSize: 14)),
                  selected: _lookingFor == opt,
                  onSelected: (_) => setState(() => _lookingFor = opt),
                  showCheckmark: false,
                  selectedColor: AppColors.yellow,
                  backgroundColor: Colors.grey[200],
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                )).toList(),
              ),
              const SizedBox(height: 20),
              _sectionTitle('¿A qué te dedicás?'),
              const SizedBox(height: 8),
              _minimalTextField(
                hint: 'Ej: Desarrollador, estudiante, artista... (opcional)',
                onChanged: (v) => setState(() => _job = v),
              ),
              const SizedBox(height: 20),
              _sectionTitle('¿Qué estudiaste o estudiás?'),
              const SizedBox(height: 8),
              _minimalTextField(
                hint: 'Ej: Ingeniería, Marketing, Derecho... (opcional)',
                onChanged: (v) => setState(() => _studies = v),
              ),
              const SizedBox(height: 20),
              _sectionTitle('Universidad'),
              const SizedBox(height: 8),
              _minimalTextField(
                hint: 'Ej: UBA, UTN, UNSAM... (opcional)',
                onChanged: (v) => setState(() => _university = v),
              ),
              const SizedBox(height: 20),
              _sectionTitle('¿Fumás?'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _smokeOptions.map((opt) => ChoiceChip(
                  label: Text(opt, style: TextStyle(color: _smoke == opt ? AppColors.black : Colors.grey[800], fontSize: 14)),
                  selected: _smoke == opt,
                  onSelected: (_) => setState(() => _smoke = opt),
                  showCheckmark: false,
                  selectedColor: AppColors.yellow,
                  backgroundColor: Colors.grey[200],
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                )).toList(),
              ),
              const SizedBox(height: 24),
              _sectionTitle('¿Qué te representa más?'),
              const SizedBox(height: 8),
              Text('Completá todas las que quieras!', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: _personalTraits.map((trait) => FilterChip(
                  label: Text(
                    trait,
                    style: TextStyle(
                      color: _selectedTraits.contains(trait) ? AppColors.black : Colors.grey[800],
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  selected: _selectedTraits.contains(trait),
                  onSelected: (_) {
                    setState(() {
                      if (_selectedTraits.contains(trait)) {
                        _selectedTraits.remove(trait);
                      } else {
                        _selectedTraits.add(trait);
                      }
                    });
                  },
                  showCheckmark: false,
                  selectedColor: AppColors.yellow,
                  backgroundColor: Colors.grey[200],
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: (_gender != null && _interests.isNotEmpty && _lookingFor != null && !_isLoading)
                      ? _finishOnboarding
                      : null,
                  child: _isLoading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Finalizar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 18,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }

  Widget _minimalTextField({required String hint, required Function(String) onChanged}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.yellow),
        ),
      ),
      style: const TextStyle(fontSize: 14),
      onChanged: onChanged,
    );
  }
} 