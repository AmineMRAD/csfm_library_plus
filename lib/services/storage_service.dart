import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadDocumentImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      debugPrint('Storage: préparation référence');

      final Reference ref = _storage
          .ref()
          .child('documents')
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

      debugPrint('Storage: début putData');

      final UploadTask uploadTask = ref.putData(fileBytes);

      final TaskSnapshot snapshot = await uploadTask;
      debugPrint('Storage: upload terminé');

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Storage: URL récupérée');

      return downloadUrl;
    } catch (e) {
      debugPrint('Erreur upload image: ${e.toString()}');
      return null;
    }
  }
}