// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Bibliothèque'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),

            const Text(
              'Firebase fonctionne correctement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            /// 🔥 BOUTON TEST INSCRIPTION
            ElevatedButton(
              onPressed: () async {
                final authService = AuthService();

                var user = await authService.register(
                  name: "Test User",
                  email: "test${DateTime.now().millisecondsSinceEpoch}@gmail.com",
                  password: "123456",
                  role: UserRole.boardingStudent,
                );

                if (user != null) {
                  print("✅ Utilisateur créé !");
                } else {
                  print("❌ Erreur lors de l'inscription");
                }
              },
              child: const Text("Tester inscription"),
            ),
          ],
        ),
      ),
    );
  }
}