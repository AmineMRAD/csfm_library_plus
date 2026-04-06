import 'package:cloud_firestore/cloud_firestore.dart';

class EmpruntModel {
  final String id;
  final String userId;
  final String userName;
  final String documentId;
  final String documentTitle;
  final String borrowDate;
  final String returnDate;
  final bool returned;
  final DateTime? createdAt;

  EmpruntModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.documentId,
    required this.documentTitle,
    required this.borrowDate,
    required this.returnDate,
    required this.returned,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'documentId': documentId,
      'documentTitle': documentTitle,
      'borrowDate': borrowDate,
      'returnDate': returnDate,
      'returned': returned,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory EmpruntModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;

    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    }

    return EmpruntModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      documentId: map['documentId'] ?? '',
      documentTitle: map['documentTitle'] ?? '',
      borrowDate: map['borrowDate'] ?? '',
      returnDate: map['returnDate'] ?? '',
      returned: map['returned'] ?? false,
      createdAt: parsedCreatedAt,
    );
  }
}