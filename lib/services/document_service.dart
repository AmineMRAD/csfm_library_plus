import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document_model.dart';

class DocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addDocument(DocumentModel document) async {
    await _firestore
        .collection('documents')
        .doc(document.id)
        .set(document.toMap());
  }

  Stream<List<DocumentModel>> getDocuments() {
    return _firestore.collection('documents').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> deleteDocument(String id) async {
    await _firestore.collection('documents').doc(id).delete();
  }

  Future<void> updateDocument(DocumentModel document) async {
    await _firestore
        .collection('documents')
        .doc(document.id)
        .update(document.toMap());
  }
}