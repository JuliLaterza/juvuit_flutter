import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';


class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      await _storage.ref('uploads/${file.uri.pathSegments.last}').putFile(file);
      String downloadURL = await _storage.ref('uploads/${file.uri.pathSegments.last}').getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  Future<File> downloadFile(String fileName, String destinationPath) async {
    try {
      final ref = _storage.ref('uploads/$fileName');
      File file = File(destinationPath);
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      throw Exception('Error downloading file: $e');
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      await _storage.ref('uploads/$fileName').delete();
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }
}
