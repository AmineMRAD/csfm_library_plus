// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../services/admin_stats_service.dart';
import 'document_list_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsService = AdminStatsService();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: FutureBuilder<Map<String, int>>(
          future: statsService.getDashboardStats(),
          builder: (context, snapshot) {
            final stats = snapshot.data ??
                {
                  'documents': 0,
                  'emprunts': 0,
                  'reservations': 0,
                  'users': 0,
                };

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStats(stats),
                  const SizedBox(height: 20),
                  _buildActions(context),
                  const SizedBox(height: 20),
                  _buildRecentActivity(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard Administrateur",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Bienvenue, Admin",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Map<String, int> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard(
          "Documents",
          stats['documents'],
          Colors.blue,
          Icons.menu_book,
        ),
        _statCard(
          "Emprunts",
          stats['emprunts'],
          Colors.green,
          Icons.description,
        ),
        _statCard(
          "Réservations",
          stats['reservations'],
          Colors.orange,
          Icons.calendar_today,
        ),
        _statCard(
          "Utilisateurs",
          stats['users'],
          Colors.purple,
          Icons.people,
        ),
      ],
    );
  }

  Widget _statCard(String title, int? value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Actions rapides",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _action(Icons.add, "Ajouter\n document", Colors.blue, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DocumentListScreen(),
                  ),
                );
              }),
              _action(Icons.list, "Gérer\n emprunts", Colors.green, () {}),
              _action(Icons.calendar_today, "Réservations", Colors.orange, () {}),
              _action(Icons.people, "Utilisateurs", Colors.purple, () {}),
              _action(Icons.notifications, "Notifications", Colors.red, () {}),
              _action(Icons.bar_chart, "Statistiques", Colors.indigo, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Activité récente",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _activity("M", "Nouvel emprunt", "Marie Durant", "Il y a 5 min"),
          _activity("P", "Réservation", "Pierre Martin", "Il y a 12 min"),
          _activity("S", "Retour document", "Sophie Lefebvre", "Il y a 23 min"),
        ],
      ),
    );
  }

  Widget _activity(String letter, String title, String user, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(letter),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(user, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}