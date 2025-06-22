import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/core/widgets/password_input_field.dart';
import 'package:juvuit_flutter/core/widgets/social_login_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/complete_profile_screen.dart';

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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
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
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/homescreen/logo_witu.png',
                      width: 180,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Crea tu cuenta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: const TextStyle(color: AppColors.darkGray),
                  prefixIcon: const Icon(Icons.mail, color: AppColors.gray),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.lightGray),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PasswordInputField(
                hintText: 'Contraseña',
                controller: _passwordController,
                fillColor: Colors.white.withAlpha(150),
              ),
              const SizedBox(height: 20),
              PasswordInputField(
                hintText: 'Confirmar contraseña',
                controller: _confirmPasswordController,
                fillColor: Colors.white.withAlpha(150),
              ),
              const SizedBox(height: 30),
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
                      ? const CircularProgressIndicator(color: AppColors.black)
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
