import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String userId;
  final String userName;
  final String role;
  final String documentId;
  final String documentTitle;
  final String date;
  final String status;
  final DateTime? createdAt;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    required this.documentId,
    required this.documentTitle,
    required this.date,
    required this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'role': role,
      'documentId': documentId,
      'documentTitle': documentTitle,
      'date': date,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;

    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    }

    return ReservationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      role: map['role'] ?? '',
      documentId: map['documentId'] ?? '',
      documentTitle: map['documentTitle'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: parsedCreatedAt,
    );
  }
}