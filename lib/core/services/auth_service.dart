import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'apple_auth_config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Login con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Registro con email y contraseña
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Login con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Forzar la limpieza completa para mostrar el selector de cuentas
      await forceGoogleAccountSelector();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // Usuario canceló el login
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Manejo específico para iOS
      if (e.toString().contains('GoogleSignIn') || e.toString().contains('cancelled')) {
        print('Google Sign-In cancelado o no disponible en este dispositivo');
        return null;
      }
      rethrow;
    }
  }

  // Login con Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      final isAvailable = await AppleAuthConfig.isAvailable();
      
      if (!isAvailable) {
        throw Exception('Apple Sign In no está disponible en este dispositivo');
      }

      // Request credential for the currently signed in Apple account
      final appleCredential = await AppleAuthConfig.signIn();
      
      if (appleCredential == null) {
        return null; // Usuario canceló el login
      }

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      print('Apple Sign In error: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Forzar desconexión completa de Google (incluye limpieza de caché)
  Future<void> forceGoogleSignOut() async {
    try {
      // Desconectar completamente de Google
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Método más agresivo para limpiar la sesión de Google
  Future<void> clearGoogleSession() async {
    try {
      // Intentar desconectar completamente
      await _googleSignIn.disconnect();
    } catch (e) {
      // Si falla disconnect, continuar con signOut
      print('Disconnect failed, continuing with signOut: $e');
    }
    
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google signOut failed: $e');
    }
    
    try {
      await _auth.signOut();
    } catch (e) {
      print('Firebase signOut failed: $e');
    }
  }

  // Método específico para forzar el selector de cuentas de Google
  Future<void> forceGoogleAccountSelector() async {
    try {
      // Limpiar completamente la sesión actual
      await clearGoogleSession();
      
      // Crear una nueva instancia de GoogleSignIn para forzar la limpieza
      final newGoogleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // Intentar signOut con la nueva instancia también
      try {
        await newGoogleSignIn.signOut();
      } catch (e) {
        print('New GoogleSignIn signOut failed: $e');
      }
    } catch (e) {
      print('Error in forceGoogleAccountSelector: $e');
    }
  }

  // Verificar si hay una sesión activa de Google
  Future<bool> isGoogleSignedIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      return account != null;
    } catch (e) {
      return false;
    }
  }

  // Método específico para eliminar cuenta (no desconecta de Google porque el usuario se elimina)
  Future<void> signOutForAccountDeletion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
} 