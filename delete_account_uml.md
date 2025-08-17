# Diagrama UML - Eliminación de Cuenta en Firebase

## Diagrama de Secuencia

```mermaid
sequenceDiagram
    participant U as Usuario
    participant UI as ProfileScreen
    participant Auth as Firebase Auth
    participant FS as Firestore
    participant Storage as Firebase Storage
    participant FCM as Firebase Messaging
    participant Functions as Cloud Functions

    Note over U, Functions: Proceso de Eliminación de Cuenta

    U->>UI: Toca "Eliminar cuenta"
    UI->>UI: Muestra diálogo de confirmación
    U->>UI: Confirma eliminación
    UI->>UI: Muestra indicador de carga

    Note over UI, FS: Fase 1: Limpieza de Datos en Firestore
    
    UI->>FS: Batch Delete - Perfil de usuario
    UI->>FS: Batch Delete - Likes recibidos
    UI->>FS: Query - Likes enviados
    FS-->>UI: Lista de likes enviados
    UI->>FS: Batch Delete - Likes enviados
    UI->>FS: Query - Matches del usuario
    FS-->>UI: Lista de matches
    UI->>FS: Batch Delete - Matches
    UI->>FS: Query - Chats del usuario
    FS-->>UI: Lista de chats
    UI->>FS: Batch Delete - Chats
    UI->>FS: Commit Batch
    FS-->>UI: Confirmación de eliminación

    Note over UI, Auth: Fase 2: Eliminación de Firebase Auth
    
    UI->>Auth: currentUser.delete()
    Auth->>Auth: Invalida todos los tokens
    Auth->>Auth: Cierra sesiones activas
    Auth->>Auth: Elimina cuenta permanentemente
    Auth-->>UI: Confirmación de eliminación

    Note over UI, Storage: Fase 3: Impacto en Otros Servicios
    
    Note over Storage: Archivos quedan huérfanos
    Note over FCM: Tokens FCM se invalidan
    Note over Functions: Triggers pueden fallar

    UI->>UI: Cierra diálogo de carga
    UI->>UI: Muestra mensaje de éxito
    UI->>UI: Redirige al login
```

## Diagrama de Clases - Impacto en la Base de Datos

```mermaid
classDiagram
    class User {
        +String uid
        +String name
        +String email
        +DateTime birthDate
        +String description
        +List~String~ photoUrls
        +List~Map~ topSongs
        +String favoriteDrink
        +String sign
    }

    class LikeReceived {
        +String userId
        +List~Map~ likes
        +DateTime lastUpdated
    }

    class LikeSent {
        +String id
        +String fromUserId
        +String toUserId
        +DateTime timestamp
        +String message
    }

    class Match {
        +String id
        +List~String~ participants
        +DateTime createdAt
        +String status
    }

    class Chat {
        +String id
        +List~String~ participants
        +DateTime lastMessage
        +String lastMessageText
    }

    class FirebaseAuth {
        +User currentUser
        +deleteUser()
        +signOut()
    }

    class Firestore {
        +CollectionReference users
        +CollectionReference likes_received
        +CollectionReference likes_sent
        +CollectionReference matches
        +CollectionReference chats
        +batch()
        +commit()
    }

    User ||--o{ LikeSent : "envía"
    User ||--o{ Match : "participa"
    User ||--o{ Chat : "participa"
    User ||--|| LikeReceived : "tiene"
    
    FirebaseAuth ||--|| User : "autentica"
    Firestore ||--|| User : "almacena"
    Firestore ||--|| LikeReceived : "almacena"
    Firestore ||--|| LikeSent : "almacena"
    Firestore ||--|| Match : "almacena"
    Firestore ||--|| Chat : "almacena"
```

## Diagrama de Estados - Ciclo de Vida del Usuario

```mermaid
stateDiagram-v2
    [*] --> Registrado
    Registrado --> Activo : Login exitoso
    Activo --> Inactivo : Logout
    Inactivo --> Activo : Login exitoso
    Activo --> Eliminando : Solicita eliminación
    Eliminando --> DatosLimpios : Limpia Firestore
    DatosLimpios --> CuentaEliminada : Elimina Auth
    CuentaEliminada --> [*]
    
    Eliminando --> Error : Fallo en proceso
    Error --> Activo : Usuario cancela
    Error --> [*] : Reintento fallido
```

## Impacto en Reglas de Seguridad

```mermaid
graph TD
    A[Usuario Eliminado] --> B[UID Inválido]
    B --> C[Reglas de Seguridad Fallan]
    C --> D[Acceso Denegado]
    C --> E[Operaciones Bloqueadas]
    
    F[Documentos Huérfanos] --> G[Referencias Rotas]
    G --> H[Consultas Fallan]
    G --> I[Índices Inconsistentes]
    
    J[Archivos en Storage] --> K[Sin Propietario]
    K --> L[Acceso Limitado]
    K --> M[Costo Continuo]
    
    N[Tokens FCM] --> O[Notificaciones Fallan]
    O --> P[Experiencia Degradada]
```

## Recomendaciones de Limpieza

1. **Eliminar archivos de Storage** asociados al UID
2. **Limpiar referencias** en otros documentos
3. **Actualizar índices** de Firestore
4. **Revisar reglas de seguridad** para casos edge
5. **Monitorear costos** de Storage por archivos huérfanos
