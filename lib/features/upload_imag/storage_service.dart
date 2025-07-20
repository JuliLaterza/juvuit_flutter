import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Servicio para manejar la subida y eliminación de imágenes en Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  Future<File?> _compressImage(File file) async {
    try {
      final targetPath = file.path.replaceFirst('.jpg', '_compressed.jpg');
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 75,
        minWidth: 1080,
        minHeight: 1080,
      );
      if (result != null) {
        return File(result.path);
      } else {
        return File(file.path);
      }
    } catch (e) {
      // Si ocurre un error, retorna null para que se intente subir el original
      return null;
    }
  }

  /// Sube una imagen a Firebase Storage bajo la carpeta del usuario y retorna la URL pública.
  /// [userId] es el identificador único del usuario.
  /// [file] es el archivo de imagen a subir.
  /// Retorna la URL de descarga de la imagen subida.
  Future<String?> uploadUserImage({required String userId, required File file}) async {
    try {
      final File? compressedFile = await _compressImage(file);
      File fileToUpload = compressedFile ?? file;
      final String fileId = _uuid.v4();
      final String path = 'users/$userId/photos/$fileId.jpg';
      final ref = _storage.ref().child(path);
      try {
        final uploadTask = await ref.putFile(fileToUpload);
        final url = await uploadTask.ref.getDownloadURL();
        return url;
      } catch (e) {
        // Si falla subir el comprimido, intenta subir el original si no es el mismo
        if (compressedFile != null && compressedFile.path != file.path) {
          try {
            final uploadTask = await ref.putFile(file);
            final url = await uploadTask.ref.getDownloadURL();
            return url;
          } catch (e2) {
            // Si también falla, retorna null
            return null;
          }
        } else {
          return null;
        }
      }
    } catch (e) {
      return null;
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
