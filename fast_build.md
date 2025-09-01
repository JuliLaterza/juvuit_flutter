# 🚀 Guía para Builds Rápidos en iOS

## Comandos para builds más rápidos:

### 1. Limpieza completa (ejecutar cuando hay problemas):
```bash
chmod +x ios_clean.sh
./ios_clean.sh
```

### 2. Build de desarrollo (más rápido):
```bash
flutter run --debug
```

### 3. Build de release (para testing):
```bash
flutter run --release
```

### 4. Build específico para iOS:
```bash
flutter build ios --debug
flutter build ios --release
```

## Tips para acelerar el build:

### ✅ Hacer:
- Cerrar Xcode durante el build
- Usar `flutter run --debug` para desarrollo
- Tener al menos 10GB de espacio libre
- Usar un cable USB directo (no WiFi)
- Desactivar antivirus temporalmente

### ❌ Evitar:
- Tener muchas apps abiertas
- Builds simultáneos
- Cambiar de rama durante el build
- Usar simulador con muchas apps instaladas

## Optimizaciones implementadas:

1. **Podfile optimizado** - Configuraciones de performance
2. **Bitcode deshabilitado** - Reduce tiempo de linking
3. **Optimizaciones de compilación** - Para builds de debug
4. **Script de limpieza** - Limpia cache y archivos temporales

## Tiempos esperados:
- **Primer build**: 5-10 minutos
- **Builds subsecuentes**: 1-3 minutos
- **Hot reload**: 2-5 segundos

## Si sigue siendo lento:

1. Ejecutar el script de limpieza
2. Reiniciar Xcode
3. Reiniciar la Mac
4. Verificar espacio en disco
5. Actualizar Flutter y CocoaPods

