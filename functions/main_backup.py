# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import firestore_fn, https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore, messaging
import logging
import time

# For cost control, you can set the maximum number of containers that can be
# running at the same time. This helps mitigate the impact of unexpected
# traffic spikes by instead downgrading performance. This limit is a per-function
# limit. You can override the limit for each function using the max_instances
# parameter in the decorator, e.g. @https_fn.on_request(max_instances=5).
set_global_options(max_instances=10)

# Inicializar Firebase Admin
initialize_app()

# Configurar logging
logger = logging.getLogger(__name__)

@firestore_fn.on_document_created(
    document="users/{userId}/likesGiven/{likedUserId}"
)
def detect_match(event) -> None:
    """
    Cloud Function que detecta automáticamente cuando se crea un like
    y verifica si existe un like recíproco para crear el match.
    """
    
    # Obtener parámetros del evento
    user_id = event.params["userId"]  # Usuario que dio like
    liked_user_id = event.params["likedUserId"]  # Usuario que recibió like
    
    # Obtener datos del documento
    if event.data is None:
        logger.error("No se pudo obtener datos del documento")
        return
    
    event_data = event.data.to_dict()
    if event_data is None:
        logger.error("No se pudo obtener datos del documento")
        return
    
    event_id = event_data.get("eventId", "")
    
    logger.info(f"Like detectado: {user_id} → {liked_user_id}", extra={
        "user_id": user_id,
        "liked_user_id": liked_user_id,
        "event_id": event_id
    })
    
    try:
        # Obtener referencia a Firestore
        db = firestore.client()
        
        # Verificar si el usuario que recibió like ya le había dado like al usuario que dio like
        reciprocal_like_ref = db.collection("users").document(liked_user_id).collection("likesGiven").document(user_id)
        reciprocal_like_doc = reciprocal_like_ref.get()
        
        if reciprocal_like_doc.exists:
            # ¡MATCH! Ambos usuarios se dieron like
            logger.info(f"¡MATCH detectado! {user_id} ↔ {liked_user_id}")
            
            # Crear el match en la colección matches
            match_id = "_".join(sorted([user_id, liked_user_id]))
            
            match_data = {
                "users": [user_id, liked_user_id],
                "eventId": event_id,
                "createdAt": firestore.SERVER_TIMESTAMP,
                "lastEventId": event_id
            }
            
            db.collection("matches").document(match_id).set(match_data)
            
            logger.info(f"Match creado con ID: {match_id}")
        else:
            logger.info(f"No hay match aún. {liked_user_id} aún no le dio like a {user_id}")
            
    except Exception as e:
        logger.error(f"Error en detect_match: {str(e)}")
        # No re-lanzar la excepción para evitar que la función falle
        return

@https_fn.on_request()
def send_test_notification(req: https_fn.Request) -> https_fn.Response:
    """
    Función HTTP para enviar notificaciones de prueba
    """
    try:
        # Obtener datos del request
        request_data = req.get_json()
        if not request_data:
            return https_fn.Response(
                "Datos requeridos: userId, title, body",
                status=400
            )
        
        user_id = request_data.get("userId")
        title = request_data.get("title", "Notificación de prueba")
        body = request_data.get("body", "Esta es una notificación de prueba")
        
        if not user_id:
            return https_fn.Response(
                "userId es requerido",
                status=400
            )
        
        # Obtener el token FCM del usuario
        db = firestore.client()
        user_doc = db.collection("users").document(user_id).get()
        
        if not user_doc.exists:
            return https_fn.Response(
                "Usuario no encontrado",
                status=404
            )
        
        user_data = user_doc.to_dict()
        fcm_token = user_data.get("fcmToken")
        notifications_enabled = user_data.get("notificationsEnabled", True)
        
        if not fcm_token:
            return https_fn.Response(
                "Usuario no tiene token FCM registrado",
                status=400
            )
        
        if not notifications_enabled:
            return https_fn.Response(
                "Usuario tiene las notificaciones deshabilitadas",
                status=400
            )
        
        # Enviar notificación
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body
            ),
            token=fcm_token,
            data={
                "type": "test_notification",
                "userId": user_id,
                "timestamp": str(int(time.time()))
            }
        )
        
        response = messaging.send(message)
        logger.info(f"Notificación enviada exitosamente: {response}")
        
        return https_fn.Response(
            f"Notificación enviada exitosamente: {response}",
            status=200
        )
        
    except Exception as e:
        logger.error(f"Error enviando notificación: {str(e)}")
        return https_fn.Response(
            f"Error enviando notificación: {str(e)}",
            status=500
        )

@https_fn.on_request()
def send_match_notification(req: https_fn.Request) -> https_fn.Response:
    """
    Función HTTP para enviar notificaciones de match
    """
    try:
        # Obtener datos del request
        request_data = req.get_json()
        if not request_data:
            return https_fn.Response(
                "Datos requeridos: userId, matchUserId, eventName",
                status=400
            )
        
        user_id = request_data.get("userId")
        match_user_id = request_data.get("matchUserId")
        event_name = request_data.get("eventName", "un evento")
        
        if not user_id or not match_user_id:
            return https_fn.Response(
                "userId y matchUserId son requeridos",
                status=400
            )
        
        # Obtener el token FCM del usuario
        db = firestore.client()
        user_doc = db.collection("users").document(user_id).get()
        
        if not user_doc.exists:
            return https_fn.Response(
                "Usuario no encontrado",
                status=404
            )
        
        user_data = user_doc.to_dict()
        fcm_token = user_data.get("fcmToken")
        notifications_enabled = user_data.get("notificationsEnabled", True)
        
        if not fcm_token:
            return https_fn.Response(
                "Usuario no tiene token FCM registrado",
                status=400
            )
        
        if not notifications_enabled:
            return https_fn.Response(
                "Usuario tiene las notificaciones deshabilitadas",
                status=400
            )
        
        # Obtener nombre del usuario que hizo match
        match_user_doc = db.collection("users").document(match_user_id).get()
        match_user_name = "Alguien"
        if match_user_doc.exists:
            match_user_data = match_user_doc.to_dict()
            match_user_name = match_user_data.get("name", "Alguien")
        
        # Enviar notificación de match
        message = messaging.Message(
            notification=messaging.Notification(
                title="¡Nuevo Match! 🎉",
                body=f"¡Tienes un nuevo match con {match_user_name} en {event_name}!"
            ),
            token=fcm_token,
            data={
                "type": "match_notification",
                "userId": user_id,
                "matchUserId": match_user_id,
                "eventName": event_name,
                "timestamp": str(int(time.time()))
            }
        )
        
        response = messaging.send(message)
        logger.info(f"Notificación de match enviada exitosamente: {response}")
        
        return https_fn.Response(
            f"Notificación de match enviada exitosamente: {response}",
            status=200
        )
        
    except Exception as e:
        logger.error(f"Error enviando notificación de match: {str(e)}")
        return https_fn.Response(
            f"Error enviando notificación de match: {str(e)}",
            status=500
        )