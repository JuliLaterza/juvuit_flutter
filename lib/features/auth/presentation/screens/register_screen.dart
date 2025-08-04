import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/core/widgets/password_input_field.dart';
import 'package:juvuit_flutter/core/widgets/social_login_button.dart';
import 'package:juvuit_flutter/core/widgets/theme_aware_logo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:juvuit_flutter/core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
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
      await _authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
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

  Future<void> _registerWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null) {
        _showMessage('Registro con Google exitoso');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
          (route) => false,
        );
      } else {
        _showMessage('Registro cancelado');
      }
    } catch (e) {
      _showMessage('Error al registrarse con Google: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerWithApple() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithApple();
      
      if (userCredential != null) {
        _showMessage('Registro con Apple exitoso');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const CompleteProfileScreen()),
          (route) => false,
        );
      } else {
        _showMessage('Registro cancelado');
      }
    } catch (e) {
      _showMessage('Error al registrarse con Apple: ${e.toString()}');
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
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
                    const LargeLogo(),
                    const SizedBox(height: 10),
                    Text(
                      'Crea tu cuenta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
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
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                  prefixIcon: Icon(Icons.mail, color: theme.colorScheme.onSurface),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PasswordInputField(
                hintText: 'Contraseña',
                controller: _passwordController,
              ),
              const SizedBox(height: 20),
              PasswordInputField(
                hintText: 'Confirmar contraseña',
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
                      : Text(
                          'Registrarse',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
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
                  Text(
                    '¿Ya tienes cuenta?',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Inicia sesión',
                      style: TextStyle(
                          color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SocialLoginButton(
                icon: FontAwesomeIcons.google,
                text: 'Registrarse con Google',
                onPressed: _isLoading ? () {} : () => _registerWithGoogle(),
              ),
              const SizedBox(height: 10),
              SocialLoginButton(
                icon: FontAwesomeIcons.apple,
                text: 'Registrarse con Apple',
                onPressed: _isLoading ? () {} : () => _registerWithApple(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
