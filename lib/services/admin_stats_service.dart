import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getDocumentsCount() async {
    final snapshot = await _firestore.collection('documents').get();
    return snapshot.docs.length;
  }

  Future<int> getEmpruntsCount() async {
    final snapshot = await _firestore.collection('emprunts').get();
    return snapshot.docs.length;
  }

  Future<int> getReservationsCount() async {
    final snapshot = await _firestore.collection('reservations').get();
    return snapshot.docs.length;
  }

  Future<int> getUsersCount() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.length;
  }

  Future<Map<String, int>> getDashboardStats() async {
    final results = await Future.wait([
      getDocumentsCount(),
      getEmpruntsCount(),
      getReservationsCount(),
      getUsersCount(),
    ]);

    return {
      'documents': results[0],
      'emprunts': results[1],
      'reservations': results[2],
      'users': results[3],
    };
  }
}