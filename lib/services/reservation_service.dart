import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation_model.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ReservationModel>> getReservations() {
    return _firestore.collection('reservations').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ReservationModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> updateStatus(String id, String status) async {
    await _firestore.collection('reservations').doc(id).update({
      'status': status,
    });
  }
}