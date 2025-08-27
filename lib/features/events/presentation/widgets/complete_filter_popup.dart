import 'package:flutter/material.dart';

class CompleteFilterPopup extends StatefulWidget {
  final String selectedType;
  final String? selectedProvince;
  final String? selectedZone;
  final Function(String) onTypeChanged;
  final Function(String?) onProvinceChanged;
  final Function(String?) onZoneChanged;
  final VoidCallback onClose;

  const CompleteFilterPopup({
    super.key,
    required this.selectedType,
    this.selectedProvince,
    this.selectedZone,
    required this.onTypeChanged,
    required this.onProvinceChanged,
    required this.onZoneChanged,
    required this.onClose,
  });

  @override
  State<CompleteFilterPopup> createState() => _CompleteFilterPopupState();
}

class _CompleteFilterPopupState extends State<CompleteFilterPopup> {
  // Estado local para manejar los filtros antes de aplicarlos
  late String _localSelectedType;
  String? _localSelectedProvince;
  String? _localSelectedZone;
  
  @override
  void initState() {
    super.initState();
    _localSelectedType = widget.selectedType;
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
        constraints: BoxConstraints(
          maxWidth: 350, 
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filtros',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Filtro de Tipo de Evento
              Text(
                'Tipo de Evento',
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
                  value: _localSelectedType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintText: 'Seleccionar tipo',
                  ),
                  menuMaxHeight: 200,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'Todos',
                      child: Text('Todos los tipos'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'Fiesta',
                      child: Text('Fiesta'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'Festival',
                      child: Text('Festival'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'Plazas',
                      child: Text('Plazas'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _localSelectedType = value!;
                    });
                  },
                ),
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
                  menuMaxHeight: 200,
                  isExpanded: true,
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
                      _localSelectedZone = null;
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
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Selecciona provincia primero',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _localSelectedProvince != null 
                      ? theme.colorScheme.surface
                      : theme.colorScheme.surfaceVariant,
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
                  menuMaxHeight: 200,
                  isExpanded: true,
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
              if (_localSelectedType != 'Todos' || _localSelectedProvince != null || _localSelectedZone != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtros activos:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (_localSelectedType != 'Todos')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _localSelectedType,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (_localSelectedProvince != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _localSelectedProvince!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (_localSelectedZone != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _localSelectedZone!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
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
                          _localSelectedType = 'Todos';
                          _localSelectedProvince = null;
                          _localSelectedZone = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: theme.colorScheme.outline),
                      ),
                      child: Text('Limpiar', style: TextStyle(color: theme.colorScheme.onSurface)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onTypeChanged(_localSelectedType);
                        widget.onProvinceChanged(_localSelectedProvince);
                        widget.onZoneChanged(_localSelectedZone);
                        widget.onClose();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
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
      ),
    );
  }
}
