import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Sugerencia';
  String _selectedSeverity = 'Media';
  bool _sendAnonymously = false;
  bool _receiveResponse = true;

  final List<String> _categories = [
    'Sugerencia',
    'Nueva funcionalidad',
    'Comentario general',
    'Reporte de bug',
  ];

  final List<String> _severities = [
    'Baja',
    'Media',
    'Alta',
    'Crítica',
  ];

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Gracias por tu feedback!'),
        content: const Text(
          'Tu mensaje ha sido enviado correctamente. '
          'Nuestro equipo lo revisará y te responderemos pronto.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver a la pantalla anterior
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFeedback() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa el título y la descripción'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Enviar feedback a Firebase/Backend
    print('📝 Feedback enviado:');
    print('Categoría: $_selectedCategory');
    print('Título: ${_titleController.text}');
    print('Descripción: ${_descriptionController.text}');
    print('Severidad: $_selectedSeverity');
    print('Anónimo: $_sendAnonymously');
    print('Recibir respuesta: $_receiveResponse');

    _showSuccessDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Feedback'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.feedback, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Tu opinión nos importa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ayúdanos a mejorar Wit Ü compartiendo tus ideas, sugerencias o comentarios.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Categoría
              Text(
                'Categoría',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                'Título',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Breve descripción de tu feedback',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                'Descripción detallada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Cuéntanos más detalles sobre tu feedback...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Severidad (solo para bugs)
              if (_selectedCategory == 'Reporte de bug') ...[
                Text(
                  'Severidad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSeverity,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _severities.map((String severity) {
                    return DropdownMenuItem<String>(
                      value: severity,
                      child: Text(severity),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSeverity = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Adjuntar captura de pantalla
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar adjuntar captura de pantalla
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de captura de pantalla próximamente')),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Adjuntar captura de pantalla (opcional)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Opciones
              Text(
                'Opciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),

              // Enviar anónimamente
              CheckboxListTile(
                title: const Text('Enviar anónimamente'),
                subtitle: const Text('No incluir tu información personal'),
                value: _sendAnonymously,
                onChanged: (bool? value) {
                  setState(() {
                    _sendAnonymously = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              // Recibir respuesta
              CheckboxListTile(
                title: const Text('Recibir respuesta'),
                subtitle: const Text('Te notificaremos cuando revisemos tu feedback'),
                value: _receiveResponse,
                onChanged: (bool? value) {
                  setState(() {
                    _receiveResponse = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),

              // Botón enviar
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
                  onPressed: _sendFeedback,
                  child: const Text(
                    'Enviar Feedback',
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
      ),
    );
  }
} 