import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String adminEmail = 'admin@csfm.tn';

  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      final UserRole finalRole =
          normalizedEmail == adminEmail.toLowerCase()
              ? UserRole.admin
              : role;

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: normalizedEmail,
          role: finalRole,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }

      return user;
    } catch (e) {
      debugPrint('Erreur register: ${e.toString()}');
      return null;
    }
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      return credential.user;
    } catch (e) {
      debugPrint('Erreur login: ${e.toString()}');
      return null;
    }
  }

  /// 🔥 NOUVEAU : récupérer données user (role)
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getUserData: $e');
      return null;
    }
  }
}