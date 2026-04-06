import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emprunt_model.dart';

class EmpruntService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEmprunt(EmpruntModel emprunt) async {
    await _firestore
        .collection('emprunts')
        .doc(emprunt.id)
        .set(emprunt.toMap());

    await _firestore.collection('documents').doc(emprunt.documentId).update({
      'available': false,
    });
  }

  Stream<List<EmpruntModel>> getEmprunts() {
    return _firestore.collection('emprunts').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EmpruntModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> markAsReturned(EmpruntModel emprunt) async {
    await _firestore.collection('emprunts').doc(emprunt.id).update({
      'returned': true,
    });

    await _firestore.collection('documents').doc(emprunt.documentId).update({
      'available': true,
    });
  }

  Future<void> cancelEmprunt(EmpruntModel emprunt) async {
    await _firestore.collection('emprunts').doc(emprunt.id).delete();

    await _firestore.collection('documents').doc(emprunt.documentId).update({
      'available': true,
    });
  }
}