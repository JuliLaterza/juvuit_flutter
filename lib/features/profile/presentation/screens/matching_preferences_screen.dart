import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class MatchingPreferencesScreen extends StatefulWidget {
  const MatchingPreferencesScreen({super.key});

  @override
  State<MatchingPreferencesScreen> createState() => _MatchingPreferencesScreenState();
}

class _MatchingPreferencesScreenState extends State<MatchingPreferencesScreen> {
  // Rango de edad
  RangeValues _ageRange = const RangeValues(18, 60);
  
  // Distancia máxima (km)
  double _maxDistance = 25.0;
  
  // Géneros de interés
  final List<String> _genders = ['Mujeres', 'Hombres', 'Todos'];
  String _selectedGender = 'Todos';
  
  // Preferencias de música
  final List<String> _musicGenres = [
    'Pop', 'Rock', 'Reggaeton', 'Electrónica', 'Hip Hop',
    'Jazz', 'Clásica', 'Country', 'Salsa', 'Otros'
  ];
  final Set<String> _selectedMusicGenres = {};
  
  // Tipos de eventos
  final List<String> _eventTypes = [
    'Fiestas', 'Conciertos', 'Deportes', 'Cultura', 'Gastronomía',
    'Aire libre', 'Networking', 'Otros'
  ];
  final Set<String> _selectedEventTypes = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // TODO: Cargar preferencias guardadas desde Firebase/SharedPreferences
    setState(() {
      // Valores por defecto
    });
  }

  Future<void> _savePreferences() async {
    // TODO: Guardar preferencias en Firebase/SharedPreferences
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferencias guardadas')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Rango de edad
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rango de edad',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_ageRange.start.round()} - ${_ageRange.end.round()} años',
                      style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 16),
                    RangeSlider(
                      values: _ageRange,
                      min: 18,
                      max: 65,
                      divisions: 47,
                      activeColor: theme.colorScheme.primary,
                      labels: RangeLabels(
                        _ageRange.start.round().toString(),
                        _ageRange.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _ageRange = values;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Distancia máxima
            /*Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distancia máxima',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_maxDistance.round()} km',
                      style: const TextStyle(fontSize: 16, color: AppColors.gray),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _maxDistance,
                      min: 1,
                      max: 100,
                      divisions: 99,
                      activeColor: AppColors.yellow,
                      label: '${_maxDistance.round()} km',
                      onChanged: (double value) {
                        setState(() {
                          _maxDistance = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Género de interés
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interesado en',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...(_genders.map((gender) => RadioListTile<String>(
                      title: Text(gender),
                      value: gender,
                      groupValue: _selectedGender,
                      activeColor: AppColors.yellow,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ))),
                  ],
                ),
              ),
            ),
            */
            const SizedBox(height: 16),

            // Géneros de música
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Géneros de música favoritos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecciona los géneros que te gustan',
                      style: TextStyle(fontSize: 14, color: AppColors.gray),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _musicGenres.map((genre) {
                        final isSelected = _selectedMusicGenres.contains(genre);
                        return FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          selectedColor: AppColors.yellow,
                          showCheckmark: false,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedMusicGenres.add(genre);
                              } else {
                                _selectedMusicGenres.remove(genre);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tipos de eventos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipos de eventos favoritos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecciona los tipos de eventos que te interesan',
                      style: TextStyle(fontSize: 14, color: AppColors.gray),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _eventTypes.map((eventType) {
                        final isSelected = _selectedEventTypes.contains(eventType);
                        return FilterChip(
                          label: Text(eventType),
                          selected: isSelected,
                          selectedColor: AppColors.yellow,
                          showCheckmark: false,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedEventTypes.add(eventType);
                              } else {
                                _selectedEventTypes.remove(eventType);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _savePreferences,
                child: const Text(
                  'Guardar Preferencias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
