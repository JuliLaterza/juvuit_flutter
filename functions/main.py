# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import firestore_fn, https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore
import logging

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