import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// REGISTER
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      // 1. créer compte Firebase
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        // 2. créer user model
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: role,
          createdAt: DateTime.now(),
        );

        // 3. enregistrer dans Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }

      return user;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }
}