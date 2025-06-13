import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/core/widgets/password_input_field.dart';
import 'package:juvuit_flutter/core/widgets/social_login_button.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/register_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/features/events/presentation/screens/events_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Por favor, llena todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _showMessage('Inicio de sesión exitoso');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const EventsScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage('Usuario no encontrado');
      } else if (e.code == 'wrong-password') {
        _showMessage('Contraseña incorrecta');
      } else {
        _showMessage('Error: ${e.message}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  //String home_path_png = "/Users/jlaterza/Documents/workspace/juvuit_flutter/assets/images/homescreen/home.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/homescreen/home.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.05)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 250),
                  // Email
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Correo electrónico',
                      hintStyle: const TextStyle(color: Colors.black),
                      prefixIcon: const Icon(Icons.mail, color: Colors.black),
                      filled: true,
                      fillColor: Colors.white.withAlpha(150),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password
                  PasswordInputField(
                    labelText: 'Contraseña',
                    controller: _passwordController,
                    labelColor: Colors.black,
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    borderRadius: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    fillColor: Colors.white.withAlpha(150),
                  ),
                  const SizedBox(height: 30),
                  // Botón login
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.black,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: AppColors.black)
                          : const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Login con redes
                  SocialLoginButton(
                    icon: FontAwesomeIcons.google,
                    text: 'Continuar con Google',
                    onPressed: () {
                      print('Google Login');
                    },
                  ),
                  const SizedBox(height: 16),
                  SocialLoginButton(
                    icon: FontAwesomeIcons.apple,
                    text: 'Continuar con Apple',
                    onPressed: () {
                      print('Apple Login');
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
