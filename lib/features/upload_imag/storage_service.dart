import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Servicio para manejar la subida y eliminación de imágenes en Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  /// Sube una imagen a Firebase Storage bajo la carpeta del usuario y retorna la URL pública.
  /// [userId] es el identificador único del usuario.
  /// [file] es el archivo de imagen a subir.
  /// Retorna la URL de descarga de la imagen subida.
  Future<String> uploadUserImage({required String userId, required File file}) async {
    try {
      final String fileId = _uuid.v4();
      final String path = 'users/$userId/photos/$fileId.jpg';
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina una imagen de Firebase Storage dado su URL.
  /// [imageUrl] es la URL de la imagen a eliminar.
  Future<void> deleteUserImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }
}
