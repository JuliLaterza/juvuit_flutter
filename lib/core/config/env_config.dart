import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración centralizada de variables de entorno
class EnvConfig {
  // Spotify API
  static String get spotifyClientId => dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  static String get spotifyClientSecret => dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';
  
  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'WIT Ü';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '0.1.0';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  
  // Firebase Configuration (opcional)
  static String get firebaseApiKeyAndroid => dotenv.env['FIREBASE_API_KEY_ANDROID'] ?? '';
  static String get firebaseApiKeyIos => dotenv.env['FIREBASE_API_KEY_IOS'] ?? '';
  
  /// Valida que las credenciales esenciales estén configuradas
  static bool get hasValidSpotifyCredentials {
    return spotifyClientId.isNotEmpty && spotifyClientSecret.isNotEmpty;
  }
  
  /// Obtiene el valor de una variable de entorno con validación
  static String getEnvVar(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }
  
  /// Verifica si estamos en modo desarrollo
  static bool get isDevelopment => environment == 'development';
  
  /// Verifica si estamos en modo producción
  static bool get isProduction => environment == 'production';
}
