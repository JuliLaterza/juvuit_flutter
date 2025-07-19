import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showFAQDialog(String question, String answer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question),
        content: Text(answer),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSupportForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soporte Técnico'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción del problema *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar adjuntar captura de pantalla
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de captura de pantalla próximamente')),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Adjuntar captura de pantalla'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty || 
                  _emailController.text.isEmpty || 
                  _descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor completa todos los campos')),
                );
                return;
              }
              // TODO: Enviar formulario por email
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Formulario enviado correctamente')),
              );
              Navigator.pop(context);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Problema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Problema técnico'),
              onTap: () {
                Navigator.pop(context);
                _showSupportForm();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off),
              title: const Text('Conducta inapropiada'),
              onTap: () {
                Navigator.pop(context);
                _showSupportForm();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    const phoneNumber = '5491112345678'; // TODO: Cambiar por número real
    const message = 'Hola, necesito ayuda con la app Wit Ü';
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  Future<void> _openInstagram() async {
    const instagramUrl = 'https://instagram.com/witu_app'; // TODO: Cambiar por Instagram real
    try {
      await launchUrl(Uri.parse(instagramUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Instagram')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Ayuda'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Preguntas Frecuentes
            _buildSection(
              'Preguntas Frecuentes (FAQ)',
              Icons.question_answer,
              [
                _buildFAQItem(
                  '¿Cómo edito mi perfil?',
                  'Ve a tu perfil y toca "Editar Perfil". Allí podrás cambiar tu información, fotos y preferencias.',
                ),
                _buildFAQItem(
                  '¿Qué hago si olvidé mi contraseña?',
                  'En la pantalla de login, toca "¿Olvidaste tu contraseña?" y sigue las instrucciones para restablecerla.',
                ),
                _buildFAQItem(
                  '¿Cómo funciona el sistema de match?',
                  'Cuando das like a un perfil y esa persona también te da like, se produce un match. Podrás chatear y coordinar encuentros.',
                ),
                _buildFAQItem(
                  '¿Cómo elimino mi cuenta?',
                  'Ve a Configuración > Cuenta avanzada > Eliminar cuenta. Ten en cuenta que esta acción es irreversible.',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Soporte Técnico
            _buildSection(
              'Soporte Técnico',
              Icons.support_agent,
              [
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.black),
                  title: const Text('Enviar formulario de contacto'),
                  subtitle: const Text('Reporta un problema técnico'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showSupportForm,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Guía de Uso
            _buildSection(
              'Guía de Uso de la App',
              Icons.book,
              [
                _buildGuideItem(
                  'Cómo asistir a un evento',
                  'Explora eventos en la sección "Eventos", selecciona uno que te interese y toca "Asistir".',
                ),
                _buildGuideItem(
                  'Cómo dar like y hacer match',
                  'Desliza hacia la derecha para dar like o hacia la izquierda para pasar. Si ambos se gustan, ¡es un match!',
                ),
                _buildGuideItem(
                  'Cómo chatear con tus matches',
                  'Ve a la sección "Chats" y selecciona un match para comenzar a conversar.',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Reportar Problema
            _buildSection(
              'Reportar un Problema',
              Icons.report,
              [
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.black),
                  title: const Text('Reportar problema o usuario'),
                  subtitle: const Text('Problemas técnicos o conducta inapropiada'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showReportDialog,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Términos y Condiciones
            _buildSection(
              'Información Legal',
              Icons.description,
              [
                ListTile(
                  leading: const Icon(Icons.description, color: Colors.black),
                  title: const Text('Términos y condiciones'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Abrir términos y condiciones
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Términos y condiciones próximamente')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.black),
                  title: const Text('Política de privacidad'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Abrir política de privacidad
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Política de privacidad próximamente')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contacto Directo
            _buildSection(
              'Contacto Directo',
              Icons.contact_support,
              [
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text('WhatsApp'),
                  subtitle: const Text('Chat directo con soporte'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _openWhatsApp,
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.purple),
                  title: const Text('Instagram'),
                  subtitle: const Text('Síguenos en Instagram'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _openInstagram,
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.black),
                  title: const Text('Email'),
                  subtitle: const Text('soporte@witu.com'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final emailUrl = 'mailto:soporte@witu.com?subject=Ayuda%20Wit%20Ü';
                    try {
                      await launchUrl(Uri.parse(emailUrl));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se pudo abrir el email')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ListTile(
      leading: const Icon(Icons.help_outline, color: Colors.black),
      title: Text(question),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showFAQDialog(question, answer),
    );
  }

  Widget _buildGuideItem(String title, String description) {
    return ListTile(
      leading: const Icon(Icons.lightbulb_outline, color: Colors.black),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
} 