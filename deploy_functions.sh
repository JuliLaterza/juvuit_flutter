#!/bin/bash

echo "🚀 Desplegando funciones de Firebase..."

# Navegar al directorio de funciones
cd functions

# Activar el entorno virtual si existe
if [ -d "venv" ]; then
    echo "📦 Activando entorno virtual..."
    source venv/bin/activate
else
    echo "📦 Creando entorno virtual..."
    python3 -m venv venv
    source venv/bin/activate
    
    echo "📦 Instalando dependencias..."
    pip install -r requirements.txt
fi

# Desplegar las funciones
echo "🚀 Desplegando funciones..."
firebase deploy --only functions

echo "✅ Funciones desplegadas exitosamente!"
echo ""
echo "📋 URLs de las funciones:"
echo "  - Test notification: https://us-central1-juvuit-flutter.cloudfunctions.net/send_test_notification"
echo "  - Match notification: https://us-central1-juvuit-flutter.cloudfunctions.net/send_match_notification"
echo ""
echo "🔧 Para probar las funciones, puedes usar curl:"
echo "  curl -X POST https://us-central1-juvuit-flutter.cloudfunctions.net/send_test_notification \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"userId\": \"USER_ID\", \"title\": \"Test\", \"body\": \"Test message\"}'"
