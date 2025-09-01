#!/bin/bash

echo "🧹 Limpiando build de iOS..."

# Limpiar Flutter
flutter clean

# Limpiar pods
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

# Limpiar build de Xcode
rm -rf build/
rm -rf DerivedData/

# Reinstalar pods
pod install --repo-update

# Volver al directorio raíz
cd ..

# Obtener dependencias de Flutter
flutter pub get

echo "✅ Limpieza completada. Ahora puedes hacer un build más rápido."
echo "💡 Tips para builds más rápidos:"
echo "   - Usa 'flutter run --release' para builds de producción"
echo "   - Cierra Xcode si está abierto durante el build"
echo "   - Asegúrate de tener suficiente espacio en disco"

