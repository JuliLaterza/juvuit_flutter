# 💻 Ejemplos de Código - WIT Ü Flutter App

## 📋 Tabla de Contenidos

1. [Autenticación](#autenticación)
2. [Matching](#matching)
3. [Chat](#chat)
4. [Eventos](#eventos)
5. [Perfiles](#perfiles)
6. [Navegación](#navegación)
7. [Temas](#temas)
8. [Firebase](#firebase)
9. [Widgets Personalizados](#widgets-personalizados)

---

## 🔐 Autenticación

### Login con Firebase Auth

```dart
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // Navegar a la pantalla principal
        Navigator.pushReplacementNamed(context, AppRoutes.events);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error de autenticación')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email requerido';
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Contraseña requerida';
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              child: _isLoading 
                ? CircularProgressIndicator() 
                : Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Registro de Usuario

```dart
Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
    
    try {
      // Crear usuario en Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Crear documento de usuario en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'photoUrls': [],
      });
      
      // Navegar a completar perfil
      Navigator.pushReplacementNamed(context, AppRoutes.completeSongsDrink);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error de registro')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

---

## 💕 Matching

### Pantalla Principal de Matching

```dart
class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final CardSwiperController controller = CardSwiperController();
  List<Map<String, dynamic>> profiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isNotEqualTo: currentUser.uid)
          .limit(20)
          .get();

      setState(() {
        profiles = snapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando perfiles: $e');
      setState(() => isLoading = false);
    }
  }

  Future<bool> _onSwipe(int index, CardSwiperDirection direction) async {
    final profile = profiles[index];
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (direction == CardSwiperDirection.right) {
      // Dar like
      await _handleLike(profile['id']);
    }
    
    return true;
  }

  Future<void> _handleLike(String likedUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await handleLikeAndMatch(
        currentUserId: currentUser.uid,
        likedUserId: likedUserId,
        eventId: 'default_event',
        context: context,
        currentUserPhoto: 'current_user_photo_url',
        matchedUserPhoto: 'matched_user_photo_url',
        matchedUserName: 'Nombre del Usuario',
      );
    } catch (e) {
      print('Error en like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Matching')),
      body: CardSwiper(
        controller: controller,
        cardsCount: profiles.length,
        onSwipe: _onSwipe,
        cardBuilder: (context, index) {
          final profile = profiles[index];
          return ProfileCard(
            name: profile['name'] ?? 'Sin nombre',
            age: profile['age']?.toString() ?? 'N/A',
            photos: List<String>.from(profile['photoUrls'] ?? []),
            bio: profile['bio'] ?? 'Sin descripción',
            onLike: () => _handleLike(profile['id']),
            onDislike: () {},
          );
        },
      ),
    );
  }
}
```

### Tarjeta de Perfil

```dart
class ProfileCard extends StatelessWidget {
  final String name;
  final String age;
  final List<String> photos;
  final String bio;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const ProfileCard({
    super.key,
    required this.name,
    required this.age,
    required this.photos,
    required this.bio,
    required this.onLike,
    required this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          // Carrusel de imágenes
          if (photos.isNotEmpty)
            Container(
              height: 300,
              child: ImageCarousel(images: photos),
            ),
          
          // Información del perfil
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name, $age',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  bio,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: onDislike,
                icon: Icon(Icons.close, color: Colors.red),
                iconSize: 40,
              ),
              IconButton(
                onPressed: onLike,
                icon: Icon(Icons.favorite, color: Colors.green),
                iconSize: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Popup de Match

```dart
class MatchPopup extends StatelessWidget {
  final String currentUserPhoto;
  final String matchedUserPhoto;
  final String matchedUserName;
  final VoidCallback onMessagePressed;

  const MatchPopup({
    super.key,
    required this.currentUserPhoto,
    required this.matchedUserPhoto,
    required this.matchedUserName,
    required this.onMessagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Es un Match! 🎉',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            
            // Fotos de ambos usuarios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(currentUserPhoto),
                ),
                Icon(Icons.favorite, color: Colors.red, size: 30),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(matchedUserPhoto),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            Text(
              'Tú y $matchedUserName se gustaron mutuamente',
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Seguir Viendo'),
                ),
                ElevatedButton(
                  onPressed: onMessagePressed,
                  child: Text('Enviar Mensaje'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 💬 Chat

### Lista de Chats

```dart
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Map<String, dynamic>> chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('users', arrayContains: currentUser.uid)
          .get();

      final chatList = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final matchData = doc.data();
        final otherUserId = (matchData['users'] as List)
            .firstWhere((id) => id != currentUser.uid);
        
        // Obtener información del otro usuario
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();
        
        if (userDoc.exists) {
          chatList.add({
            'matchId': doc.id,
            'userId': otherUserId,
            'userName': userDoc.data()?['name'] ?? 'Sin nombre',
            'userPhoto': userDoc.data()?['photoUrls']?.first ?? '',
            'lastMessage': 'Último mensaje...', // Implementar lógica
            'timestamp': matchData['createdAt'],
          });
        }
      }

      setState(() => chats = chatList);
    } catch (e) {
      print('Error cargando chats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(chat['userPhoto']),
            ),
            title: Text(chat['userName']),
            subtitle: Text(chat['lastMessage']),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.chat,
                arguments: {
                  'matchId': chat['matchId'],
                  'personName': chat['userName'],
                  'personPhotoUrl': chat['userPhoto'],
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

### Pantalla de Chat Individual

```dart
class ChatScreen extends StatefulWidget {
  final String matchId;
  final String personName;
  final String personPhotoUrl;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.personName,
    required this.personPhotoUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    FirebaseFirestore.instance
        .collection('matches')
        .doc(widget.matchId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        messages = snapshot.docs
            .map((doc) => doc.data()..['id'] = doc.id)
            .toList();
      });
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.matchId)
          .collection('messages')
          .add({
        'text': _messageController.text.trim(),
        'senderId': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      print('Error enviando mensaje: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.personPhotoUrl),
            ),
            SizedBox(width: 8),
            Text(widget.personName),
          ],
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['senderId'] == 
                    FirebaseAuth.instance.currentUser?.uid;
                
                return Align(
                  alignment: isMe 
                      ? Alignment.centerRight 
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 8, 
                      vertical: 4,
                    ),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Campo de texto para enviar mensaje
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📅 Eventos

### Lista de Eventos

```dart
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('date')
          .get();

      setState(() {
        events = snapshot.docs
            .map((doc) => Event.fromFirestore(doc))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando eventos: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Eventos')),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  event.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(event.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.subtitle),
                  Text(
                    '${event.attendeesCount} asistentes',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Text(
                DateFormat('dd/MM/yyyy').format(event.date),
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                // Navegar a detalles del evento
                Navigator.pushNamed(
                  context,
                  AppRoutes.matching,
                  arguments: {'eventId': event.id},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

---

## 👤 Perfiles

### Pantalla de Perfil

```dart
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      print('Error cerrando sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Foto de perfil
            if (userData?['photoUrls']?.isNotEmpty ?? false)
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  userData!['photoUrls'].first,
                ),
              ),
            
            SizedBox(height: 16),
            
            // Información del usuario
            Text(
              userData?['name'] ?? 'Sin nombre',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            
            SizedBox(height: 8),
            Text(
              userData?['email'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            SizedBox(height: 24),
            
            // Opciones del perfil
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Editar Perfil'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Preferencias de Matching'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.matchingPreferences);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Centro de Ayuda'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.helpCenter);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Enviar Feedback'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.feedback);
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🛣️ Navegación

### Configuración de Rutas

```dart
// Navegación con argumentos
Navigator.pushNamed(
  context,
  AppRoutes.chat,
  arguments: {
    'matchId': 'match_123',
    'personName': 'María García',
    'personPhotoUrl': 'https://example.com/photo.jpg',
  },
);

// Navegación y reemplazo
Navigator.pushReplacementNamed(context, AppRoutes.events);

// Navegación y limpiar stack
Navigator.pushNamedAndRemoveUntil(
  context,
  AppRoutes.login,
  (route) => false,
);
```

---

## 🎨 Temas

### Cambiar Tema

```dart
// En cualquier widget
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return IconButton(
      onPressed: () => themeProvider.toggleTheme(),
      icon: Icon(
        themeProvider.isDarkMode 
            ? Icons.light_mode 
            : Icons.dark_mode,
      ),
    );
  },
);
```

### Usar Colores del Tema

```dart
// Obtener colores del tema actual
final themeProvider = Provider.of<ThemeProvider>(context);
final colors = themeProvider.currentTheme;

// Usar en widgets
Container(
  color: colors.primary,
  child: Text(
    'Texto con color del tema',
    style: TextStyle(color: colors.onPrimary),
  ),
);
```

---

## 🔥 Firebase

### Operaciones CRUD

```dart
// Crear documento
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .set({
  'name': 'Juan Pérez',
  'email': 'juan@example.com',
  'createdAt': FieldValue.serverTimestamp(),
});

// Leer documento
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();

if (doc.exists) {
  final data = doc.data()!;
  print('Usuario: ${data['name']}');
}

// Actualizar documento
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({
  'name': 'Juan Carlos Pérez',
  'updatedAt': FieldValue.serverTimestamp(),
});

// Eliminar documento
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .delete();

// Consultas
final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .where('age', isGreaterThan: 18)
    .where('city', isEqualTo: 'Madrid')
    .orderBy('createdAt', descending: true)
    .limit(10)
    .get();
```

### Subir Imágenes

```dart
Future<String> uploadImage(File imageFile) async {
  try {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_photos')
        .child(fileName);
    
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    return downloadUrl;
  } catch (e) {
    print('Error subiendo imagen: $e');
    rethrow;
  }
}
```

---

## 🎨 Widgets Personalizados

### Carrusel de Imágenes

```dart
class ImageCarousel extends StatefulWidget {
  final List<String> images;

  const ImageCarousel({
    super.key,
    required this.images,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carrusel principal
        Container(
          height: 300,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              );
            },
          ),
        ),
        
        // Indicadores
        if (widget.images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.images.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == entry.key 
                      ? Colors.blue 
                      : Colors.grey,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
```

### Botón de Carga

```dart
class LoadingButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color? color;

  const LoadingButton({
    super.key,
    required this.text,
    required this.isLoading,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 50),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }
}
```

### Campo de Texto Personalizado

```dart
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
```

---

## 📱 Ejemplos de Uso Completo

### Pantalla de Login Completa

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        Navigator.pushReplacementNamed(context, AppRoutes.events);
      } on FirebaseAuthException catch (e) {
        String message = 'Error de autenticación';
        
        switch (e.code) {
          case 'user-not-found':
            message = 'No existe una cuenta con este email';
            break;
          case 'wrong-password':
            message = 'Contraseña incorrecta';
            break;
          case 'invalid-email':
            message = 'Email inválido';
            break;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/homescreen/logo_witu.png',
                  height: 120,
                ),
                
                SizedBox(height: 48),
                
                // Campo de email
                CustomTextField(
                  label: 'Email',
                  hint: 'tu@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Email requerido';
                    }
                    if (!value!.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16),
                
                // Campo de contraseña
                CustomTextField(
                  label: 'Contraseña',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Contraseña requerida';
                    }
                    if (value!.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 24),
                
                // Botón de login
                LoadingButton(
                  text: 'Iniciar Sesión',
                  isLoading: _isLoading,
                  onPressed: _signIn,
                ),
                
                SizedBox(height: 16),
                
                // Enlace de registro
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  child: Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

*Estos ejemplos muestran las implementaciones más comunes en la aplicación WIT Ü. Para más detalles, consulta la documentación completa.*