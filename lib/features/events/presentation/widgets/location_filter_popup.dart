import 'package:flutter/material.dart';

class LocationFilterPopup extends StatefulWidget {
  final String? selectedProvince;
  final String? selectedZone;
  final Function(String?) onProvinceChanged;
  final Function(String?) onZoneChanged;
  final VoidCallback onClose;

  const LocationFilterPopup({
    super.key,
    this.selectedProvince,
    this.selectedZone,
    required this.onProvinceChanged,
    required this.onZoneChanged,
    required this.onClose,
  });

  @override
  State<LocationFilterPopup> createState() => _LocationFilterPopupState();
}

class _LocationFilterPopupState extends State<LocationFilterPopup> {
  // Estado local para manejar los filtros antes de aplicarlos
  String? _localSelectedProvince;
  String? _localSelectedZone;
  
  @override
  void initState() {
    super.initState();
    _localSelectedProvince = widget.selectedProvince;
    _localSelectedZone = widget.selectedZone;
  }

  // Datos de provincias argentinas con sus zonas específicas
  static const Map<String, List<String>> _provincesAndZones = {
    'Buenos Aires': ['CABA', 'Zona Oeste', 'Zona Norte', 'Zona Este', 'Zona Sur', 'Costa Argentina'],
    'Córdoba': ['Capital', 'Sierras Chicas', 'Sierras Grandes', 'Valle de Punilla', 'Valle de Calamuchita', 'Río Cuarto', 'San Francisco'],
    'Santa Fe': ['Rosario', 'Capital', 'Litoral', 'Centro', 'Sur', 'Reconquista'],
    'Mendoza': ['Capital', 'Valle de Uco', 'Este', 'Sur', 'Norte', 'San Rafael'],
    'Tucumán': ['Capital', 'Sur', 'Este', 'Oeste', 'Norte', 'Tafí del Valle'],
    'Salta': ['Capital', 'Valle de Lerma', 'Quebrada', 'Puna', 'Chaco Salteño', 'Cafayate'],
    'Entre Ríos': ['Paraná', 'Concordia', 'Gualeguaychú', 'Federación', 'Victoria', 'Concepción del Uruguay'],
    'Chaco': ['Resistencia', 'Sáenz Peña', 'Villa Ángela', 'Charata', 'Quitilipi', 'Presidencia Roque Sáenz Peña'],
    'Corrientes': ['Capital', 'Goya', 'Mercedes', 'Paso de los Libres', 'Curuzú Cuatiá', 'Ituzaingó'],
    'Misiones': ['Posadas', 'Oberá', 'Eldorado', 'Puerto Iguazú', 'San Vicente', 'Apóstoles'],
  };

  List<String> get _provinces => _provincesAndZones.keys.toList();
  
  List<String> get _availableZones {
    if (_localSelectedProvince == null) return [];
    final zones = _provincesAndZones[_localSelectedProvince!] ?? [];
    print('Provincia seleccionada: $_localSelectedProvince');
    print('Zonas disponibles: $zones');
    return zones;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: Colors.black,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Filtros de Ubicación',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close, color: Colors.black),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Filtro de Provincia
            Text(
              'Provincia',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _localSelectedProvince,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: 'Seleccionar provincia',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Todas las provincias'),
                  ),
                  ..._provinces.map((province) => DropdownMenuItem<String>(
                    value: province,
                    child: Text(province),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _localSelectedProvince = value;
                    _localSelectedZone = null; // Reset zona al cambiar provincia
                  });
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Filtro de Zona
            Row(
              children: [
                Text(
                  'Zona',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_localSelectedProvince == null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Selecciona provincia primero',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _localSelectedProvince != null 
                      ? Colors.black 
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
                color: _localSelectedProvince != null 
                    ? Colors.white 
                    : Colors.grey[50],
              ),
              child: DropdownButtonFormField<String>(
                value: _localSelectedZone,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: _localSelectedProvince != null 
                      ? 'Seleccionar zona' 
                      : 'Primero selecciona una provincia',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Todas las zonas'),
                  ),
                  if (_localSelectedProvince != null)
                    ..._availableZones.map((zone) => DropdownMenuItem<String>(
                      value: zone,
                      child: Text(zone),
                    )),
                ],
                onChanged: _localSelectedProvince != null ? (value) {
                  setState(() {
                    _localSelectedZone = value;
                  });
                } : null,
              ),
            ),
            const SizedBox(height: 20),
            
            // Filtros activos
            if (_localSelectedProvince != null || _localSelectedZone != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtros activos:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_localSelectedProvince != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _localSelectedProvince!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (_localSelectedZone != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _localSelectedZone!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _localSelectedProvince = null;
                        _localSelectedZone = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: const Text('Limpiar', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Aplicar los filtros solo cuando se presiona "Aplicar"
                      widget.onProvinceChanged(_localSelectedProvince);
                      widget.onZoneChanged(_localSelectedZone);
                      widget.onClose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
