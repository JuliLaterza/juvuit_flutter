#!/usr/bin/env python3
"""
Script para probar las funciones de notificaciones de Firebase
"""

import requests
import json
import sys

# URL base de las funciones de Firebase
BASE_URL = "https://us-central1-juvuit-flutter.cloudfunctions.net"

def test_notification_function(user_id, title="Notificación de prueba", body="Esta es una notificación de prueba"):
    """
    Prueba la función send_test_notification
    """
    url = f"{BASE_URL}/send_test_notification"
    
    data = {
        "userId": user_id,
        "title": title,
        "body": body
    }
    
    try:
        response = requests.post(url, json=data, headers={'Content-Type': 'application/json'})
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ Notificación enviada exitosamente!")
        else:
            print("❌ Error al enviar notificación")
            
        return response.status_code == 200
        
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_match_notification_function(user_id, match_user_id, event_name="Evento de prueba"):
    """
    Prueba la función send_match_notification
    """
    url = f"{BASE_URL}/send_match_notification"
    
    data = {
        "userId": user_id,
        "matchUserId": match_user_id,
        "eventName": event_name
    }
    
    try:
        response = requests.post(url, json=data, headers={'Content-Type': 'application/json'})
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ Notificación de match enviada exitosamente!")
        else:
            print("❌ Error al enviar notificación de match")
            
        return response.status_code == 200
        
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def main():
    print("🧪 Probador de Notificaciones Firebase")
    print("=" * 50)
    
    if len(sys.argv) < 2:
        print("Uso: python test_notifications.py <USER_ID> [MATCH_USER_ID]")
        print("\nEjemplos:")
        print("  python test_notifications.py user123")
        print("  python test_notifications.py user123 match456")
        sys.exit(1)
    
    user_id = sys.argv[1]
    match_user_id = sys.argv[2] if len(sys.argv) > 2 else "match_user_123"
    
    print(f"Usuario ID: {user_id}")
    print(f"Match User ID: {match_user_id}")
    print()
    
    # Probar notificación de prueba
    print("1️⃣ Probando notificación de prueba...")
    test_notification_function(user_id)
    print()
    
    # Probar notificación de match
    print("2️⃣ Probando notificación de match...")
    test_match_notification_function(user_id, match_user_id)
    print()
    
    print("✅ Pruebas completadas!")

if __name__ == "__main__":
    main()
