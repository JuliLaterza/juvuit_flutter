import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class LocationFilterButtons extends StatefulWidget {
  final String? selectedProvince;
  final String? selectedZone;
  final Function(String?) onProvinceChanged;
  final Function(String?) onZoneChanged;

  const LocationFilterButtons({
    super.key,
    this.selectedProvince,
    this.selectedZone,
    required this.onProvinceChanged,
    required this.onZoneChanged,
  });

  @override
  State<LocationFilterButtons> createState() => _LocationFilterButtonsState();
}

class _LocationFilterButtonsState extends State<LocationFilterButtons> {
  // Datos ficticios de provincias argentinas
  static const Map<String, List<String>> _provincesAndZones = {
    'Buenos Aires': ['Zona Oeste', 'Zona Sur', 'Zona Norte', 'Zona Este', 'Costa Argentina'],
    'Córdoba': ['Capital', 'Sierras Chicas', 'Sierras Grandes', 'Valle de Punilla', 'Valle de Calamuchita'],
    'Santa Fe': ['Rosario', 'Capital', 'Litoral', 'Centro', 'Sur'],
    'Mendoza': ['Capital', 'Valle de Uco', 'Este', 'Sur', 'Norte'],
    'Tucumán': ['Capital', 'Sur', 'Este', 'Oeste', 'Norte'],
    'Salta': ['Capital', 'Valle de Lerma', 'Quebrada', 'Puna', 'Chaco Salteño'],
    'Entre Ríos': ['Paraná', 'Concordia', 'Gualeguaychú', 'Federación', 'Victoria'],
    'Chaco': ['Resistencia', 'Sáenz Peña', 'Villa Ángela', 'Charata', 'Quitilipi'],
    'Corrientes': ['Capital', 'Goya', 'Mercedes', 'Paso de los Libres', 'Curuzú Cuatiá'],
    'Misiones': ['Posadas', 'Oberá', 'Eldorado', 'Puerto Iguazú', 'San Vicente'],
  };

  List<String> get _provinces => _provincesAndZones.keys.toList();
  
  List<String> get _availableZones {
    if (widget.selectedProvince == null) return [];
    return _provincesAndZones[widget.selectedProvince!] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtro de Provincia
        Container(
          height: 40,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Botón "Todas las provincias"
                ElevatedButton(
                  onPressed: () {
                    widget.onProvinceChanged(null);
                    widget.onZoneChanged(null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.selectedProvince == null 
                        ? AppColors.yellow 
                        : AppColors.black,
                    foregroundColor: widget.selectedProvince == null 
                        ? Colors.black 
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Todas'),
                ),
                const SizedBox(width: 8),
                // Botones de provincias
                ..._provinces.map((province) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onProvinceChanged(province);
                      widget.onZoneChanged(null); // Reset zona al cambiar provincia
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.selectedProvince == province 
                          ? AppColors.yellow 
                          : AppColors.black,
                      foregroundColor: widget.selectedProvince == province 
                          ? Colors.black 
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(province),
                  ),
                )),
              ],
            ),
          ),
        ),
        
        // Filtro de Zona (solo se muestra si hay provincia seleccionada)
        if (widget.selectedProvince != null && _availableZones.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Botón "Todas las zonas"
                  ElevatedButton(
                    onPressed: () => widget.onZoneChanged(null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.selectedZone == null 
                          ? AppColors.yellow 
                          : AppColors.black,
                      foregroundColor: widget.selectedZone == null 
                          ? Colors.black 
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Todas las zonas'),
                  ),
                  const SizedBox(width: 8),
                  // Botones de zonas
                  ..._availableZones.map((zone) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () => widget.onZoneChanged(zone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.selectedZone == zone 
                            ? AppColors.yellow 
                            : AppColors.black,
                        foregroundColor: widget.selectedZone == zone 
                            ? Colors.black 
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(zone),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

