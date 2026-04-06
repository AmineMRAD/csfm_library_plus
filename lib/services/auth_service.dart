import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
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
          isActive: true,
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

  Future<String?> createUserByAdmin({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required bool isActive,
  }) async {
    FirebaseApp? secondaryApp;

    try {
      final normalizedEmail = email.trim().toLowerCase();

      final UserRole finalRole =
          normalizedEmail == adminEmail.toLowerCase()
              ? UserRole.admin
              : role;

      final secondaryAppName =
          'admin-create-user-${DateTime.now().millisecondsSinceEpoch}';

      secondaryApp = await Firebase.initializeApp(
        name: secondaryAppName,
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final createdUser = credential.user;
      if (createdUser == null) {
        return 'Échec de création du compte';
      }

      final newUser = UserModel(
        uid: createdUser.uid,
        name: name.trim(),
        email: normalizedEmail,
        role: finalRole,
        isActive: isActive,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(createdUser.uid).set(newUser.toMap());

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      return null;
    } on FirebaseAuthException catch (e) {
      if (secondaryApp != null) {
        try {
          await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
          await secondaryApp.delete();
        } catch (_) {}
      }

      switch (e.code) {
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé';
        case 'invalid-email':
          return 'Email invalide';
        case 'weak-password':
          return 'Mot de passe trop faible (minimum 6 caractères)';
        default:
          return e.message ?? 'Erreur lors de la création du compte';
      }
    } catch (e) {
      if (secondaryApp != null) {
        try {
          await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
          await secondaryApp.delete();
        } catch (_) {}
      }

      debugPrint('Erreur createUserByAdmin: $e');
      return 'Une erreur est survenue';
    }
  }
}