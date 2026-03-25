enum UserRole { admin, boardingStudent, externalStudent }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  /// Convertir vers Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name, // important
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convertir depuis Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
