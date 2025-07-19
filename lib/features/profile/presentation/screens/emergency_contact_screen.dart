import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isConfigured = false;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContact();
  }

  Future<void> _loadEmergencyContact() async {
    // TODO: Cargar contacto de emergencia desde SharedPreferences/Firebase
    // Por ahora, verificamos si hay un número guardado
    setState(() {
      _isConfigured = _phoneController.text.isNotEmpty;
    });
  }

  Future<void> _saveEmergencyContact() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un número de teléfono')),
      );
      return;
    }

    // TODO: Guardar en SharedPreferences/Firebase
    setState(() {
      _isConfigured = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacto de emergencia guardado')),
    );
  }

  Future<void> _sendEmergencyMessage() async {
    if (!_isConfigured || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes configurar un contacto de emergencia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final phoneNumber = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final contactName = _nameController.text.isNotEmpty ? _nameController.text : 'Contacto';
    
    
    final message = '''
*EMERGENCIA*

Hola ${contactName}. Estoy en una situación que me preocupa y necesito ayuda.

Mi ubicación actual: [Ubicación automática]
Hora: ${DateTime.now().toString().substring(11, 16)}
App: Wit Ü

Por favor, contáctame lo antes posible.
''';


    final whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';


    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        // Fallback: abrir WhatsApp con el número
        final fallbackUrl = 'https://wa.me/$phoneNumber';
        await launchUrl(Uri.parse(fallbackUrl));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacto de Emergencia'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información de seguridad
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Tu seguridad es importante',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configura un contacto de confianza que recibirá un mensaje de emergencia si presionas el botón antipánico.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Formulario de contacto
              Text(
                'Contacto de Emergencia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),

              // Nombre del contacto
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del contacto (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Número de teléfono
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'Número de teléfono *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  hintText: 'Ej: 5491112345678',
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 24),
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
                  onPressed: _saveEmergencyContact,
                  child: const Text(
                    'Guardar Contacto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón antipánico
              if (_isConfigured) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Botón Antipánico',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Presiona este botón si te encuentras en una situación de emergencia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _sendEmergencyMessage,
                          child: const Text(
                            '🚨 ENVIAR MENSAJE DE EMERGENCIA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 