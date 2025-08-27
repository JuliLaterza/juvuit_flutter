import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthConfig {
  static const String serviceId = 'com.example.juvuitFlutter.signin';
  
  static Future<bool> isAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      print('Error checking Apple Sign In availability: $e');
      return false;
    }
  }

  static Future<AuthorizationCredentialAppleID?> signIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: serviceId,
          redirectUri: Uri.parse('https://juvuit-flutter.firebaseapp.com/__/auth/handler'),
        ),
      );
      
      return credential;
    } catch (e) {
      print('Error during Apple Sign In: $e');
      rethrow;
    }
  }

  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('canceled')) {
      return 'Inicio de sesión cancelado';
    } else if (error.toString().contains('not available')) {
      return 'Apple Sign In no está disponible en este dispositivo';
    } else if (error.toString().contains('network')) {
      return 'Error de conexión. Verifica tu internet.';
    } else {
      return 'Error al iniciar sesión con Apple';
    }
  }
}
