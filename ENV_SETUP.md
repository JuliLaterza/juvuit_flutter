# 🔐 Configuración de Variables de Entorno

## 📋 Pasos para Configurar

### 1. Crear archivo `.env`
Crea un archivo llamado `.env` en la raíz del proyecto con el siguiente contenido:

```env
# Spotify API Credentials
SPOTIFY_CLIENT_ID=43019c4f95e94a1daf3372b6b14baf52
SPOTIFY_CLIENT_SECRET=68dd1d3c4240455ea02f5aa88b6ece8b

# App Configuration
APP_NAME=WIT Ü
APP_VERSION=0.1.0

# Environment
ENVIRONMENT=development
```

### 2. Verificar `.gitignore`
Asegúrate de que el archivo `.env` esté incluido en `.gitignore`:

```gitignore
# Environment variables
.env
.env.local
.env.production
```

### 3. Instalar dependencias
Ejecuta el siguiente comando para instalar las nuevas dependencias:

```bash
flutter pub get
```

## 🔒 Seguridad

### ✅ Beneficios
- **Credenciales protegidas**: No se suben al repositorio
- **Configuración flexible**: Diferentes valores por entorno
- **Fácil mantenimiento**: Centralizado en un archivo

### ⚠️ Importante
- **NUNCA** subas el archivo `.env` al repositorio
- **SIEMPRE** usa `.env.example` como plantilla
- **VERIFICA** que las credenciales sean correctas

## 🚀 Uso en el Código

### Acceder a variables:
```dart
import 'package:juvuit_flutter/core/config/env_config.dart';

// Obtener credenciales de Spotify
String clientId = EnvConfig.spotifyClientId;
String clientSecret = EnvConfig.spotifyClientSecret;

// Verificar si las credenciales están configuradas
if (EnvConfig.hasValidSpotifyCredentials) {
  // Usar Spotify API
}

// Obtener configuración de la app
String appName = EnvConfig.appName;
bool isDevelopment = EnvConfig.isDevelopment;
```

## 🔧 Configuración por Entorno

### Desarrollo
```env
ENVIRONMENT=development
```

### Producción
```env
ENVIRONMENT=production
```

## 📝 Notas
- El archivo `env_template.txt` contiene una plantilla con las credenciales actuales
- Copia el contenido de `env_template.txt` a `.env`
- Para producción, usa credenciales diferentes y más seguras
