import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/core/widgets/password_input_field.dart';
import 'package:juvuit_flutter/core/widgets/social_login_button.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/register_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/features/events/presentation/screens/events_screen.dart';

import '../../../testing/screens/debug_screen.dart';

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
    // Validar campos vacíos
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Por favor, llena todos los campos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Login en Firebase con email y contraseña
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _showMessage('Inicio de sesión exitoso');

      // Navegar a HomeScreen
     
      Navigator.pushAndRemoveUntil(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const EventsScreen()),
      (route) => false, // Esto elimina todas las rutas anteriores
    );
    
    /*
    //Para TESTING
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DebugScreen()),
      (route) => false,
    );
    */    

    } on FirebaseAuthException catch (e) {
      // Manejo de errores comunes de Firebase
      if (e.code == 'user-not-found') {
        _showMessage('Usuario no encontrado');
      } else if (e.code == 'wrong-password') {
        _showMessage('Contraseña incorrecta');
      } else {
        _showMessage('Error: ${e.message}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Fondo blanco
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // Espacio superior
              const Center(
                child: Column(
                  children: [
                    Text(
                      'WIT Ü',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Inicia sesión para continuar',
                      style: TextStyle(fontSize: 16, color: AppColors.gray),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Email Input
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: const TextStyle(color: AppColors.darkGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.yellow),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Contraseña Input
              PasswordInputField(
                labelText: 'Contraseña',
                controller: _passwordController,
              ),
              const SizedBox(height: 30),
              // Botón de Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.black,
                        )
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              // Forgot Password & Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?',
                      style: TextStyle(color: AppColors.gray)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Regístrate',
                        style: TextStyle(
                            color: AppColors.yellow,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SocialLoginButton(
                icon: FontAwesomeIcons.google,
                text: 'Continuar con Google',
                onPressed: () {
                  print('Google Login');
                },
              ),
              const SizedBox(height: 20),
              SocialLoginButton(
                icon: FontAwesomeIcons.apple,
                text: 'Continuar con Apple',
                onPressed: () {
                  print('Apple Login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
