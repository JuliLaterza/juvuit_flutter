import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/core/widgets/password_input_field.dart';
import 'package:juvuit_flutter/core/widgets/social_login_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/features/home/presentation/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Función para registrar un usuario en Firebase
  Future<void> _register() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      _showMessage('Por favor, llena todos los campos');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Las contraseñas no coinciden');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showMessage('Registro exitoso');

      // Reemplazar toda la pila con HomeScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showMessage('El correo ya está registrado');
      } else if (e.code == 'invalid-email') {
        _showMessage('El correo no es válido');
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
      backgroundColor: AppColors.white,
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
                      'Crea tu cuenta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Regístrate para empezar',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.gray,
                      ),
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
              const SizedBox(height: 20),
              // Confirmar Contraseña Input
              PasswordInputField(
                labelText: 'Confirmar contraseña',
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 30),
              // Botón de Registro
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                          'Registrarse',
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              // Botón de regresar al Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes cuenta?',
                    style: TextStyle(color: AppColors.gray),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(
                          color: AppColors.yellow, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SocialLoginButton(
                icon: FontAwesomeIcons.google,
                text: 'Registrarse con Google',
                onPressed: () {
                  print('Google');
                },
              ),
              const SizedBox(height: 10),
              SocialLoginButton(
                icon: FontAwesomeIcons.apple,
                text: 'Registrarse con Apple',
                onPressed: () {
                  print('Apple');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
