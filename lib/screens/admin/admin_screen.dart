// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'document_list_screen.dart';
import 'loan_list_screen.dart';
import 'reservation_list_screen.dart';
import 'users_list_screen.dart';
import 'statistics_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStats(),
              const SizedBox(height: 20),
              _buildActions(context),
              const SizedBox(height: 20),
              _buildRecentActivity(),
            ],
          ),
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

  Widget _buildStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _liveStatCard(
          title: "Documents",
          color: Colors.blue,
          icon: Icons.menu_book,
          stream: FirebaseFirestore.instance.collection('documents').snapshots(),
        ),
        _liveStatCard(
          title: "Emprunts",
          color: Colors.green,
          icon: Icons.description,
          stream: FirebaseFirestore.instance.collection('emprunts').snapshots(),
        ),
        _liveStatCard(
          title: "Réservations",
          color: Colors.orange,
          icon: Icons.calendar_today,
          stream: FirebaseFirestore.instance.collection('reservations').snapshots(),
        ),
        _liveStatCard(
          title: "Utilisateurs",
          color: Colors.purple,
          icon: Icons.people,
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
        ),
      ],
    );
  }

  Widget _liveStatCard({
    required String title,
    required Color color,
    required IconData icon,
    required Stream<QuerySnapshot> stream,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;

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
                count.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        );
      },
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
                  MaterialPageRoute(builder: (_) => const DocumentListScreen()),
                );
              }),
              _action(Icons.list, "Gérer\n emprunts", Colors.green, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoanListScreen()),
                );
              }),
              _action(Icons.calendar_today, "Réservations", Colors.orange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReservationListScreen(),
                  ),
                );
              }),
              _action(Icons.people, "Utilisateurs", Colors.purple, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsersListScreen()),
                );
              }),
              _action(Icons.notifications, "Notifications", Colors.red, () {}),
              _action(Icons.bar_chart, "Statistiques", Colors.indigo, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, Color color, VoidCallback onTap) {
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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('emprunts').snapshots(),
      builder: (context, loanSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('reservations').snapshots(),
          builder: (context, reservationSnapshot) {
            if (loanSnapshot.connectionState == ConnectionState.waiting ||
                reservationSnapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            final loans = (loanSnapshot.data?.docs ?? []).map((doc) {
              return {
                ...doc.data(),
                '_type': 'loan',
                '_id': doc.id,
              };
            }).toList();

            final reservations = (reservationSnapshot.data?.docs ?? []).map((doc) {
              return {
                ...doc.data(),
                '_type': 'reservation',
                '_id': doc.id,
              };
            }).toList();

            final allActivities = [...loans, ...reservations];

            allActivities.sort((a, b) {
              final dateA = _extractDate(a);
              final dateB = _extractDate(b);
              return dateB.compareTo(dateA);
            });

            final recent = allActivities.take(5).toList();

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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (recent.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Aucune activité récente",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  else
                    ...recent.asMap().entries.map((entry) {
                      final index = entry.key;
                      final activity = entry.value;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == recent.length - 1 ? 0 : 10,
                        ),
                        child: _buildActivityItem(activity),
                      );
                    }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final type = (activity['_type'] ?? '').toString();
    final userName = _extractUserName(activity);
    final date = _extractDate(activity);

    late final String title;
    late final String letter;
    late final Color color;

    if (type == 'loan') {
      final returned = activity['returned'] == true;
      title = returned ? "Retour document" : "Nouvel emprunt";
      letter = returned ? "R" : "M";
      color = returned ? Colors.blue : Colors.green;
    } else {
      title = "Réservation";
      letter = "P";
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.18),
            child: Text(
              letter,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  userName,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _timeAgo(date),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _extractUserName(Map<String, dynamic> activity) {
    final possibleKeys = [
      'userName',
      'name',
      'user',
      'studentName',
      'borrowerName',
    ];

    for (final key in possibleKeys) {
      final value = activity[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return 'Utilisateur';
  }

  DateTime _extractDate(Map<String, dynamic> data) {
    const possibleKeys = [
      'createdAt',
      'reservationCreatedAt',
      'returnCreatedAt',
      'borrowDate',
      'reservationDate',
      'date',
      'loanDate',
    ];

    for (final key in possibleKeys) {
      final value = data[key];

      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;

      if (value is String) {
        final normalized = _normalizeDateString(value);
        final parsed = DateTime.tryParse(normalized);
        if (parsed != null) return parsed;
      }
    }

    return DateTime.now();
  }

  String _normalizeDateString(String value) {
    final trimmed = value.trim();

    final dashPattern = RegExp(r'^\d{4}-\d{1,2}-\d{1,2}$');
    if (dashPattern.hasMatch(trimmed)) {
      final parts = trimmed.split('-');
      final year = parts[0];
      final month = parts[1].padLeft(2, '0');
      final day = parts[2].padLeft(2, '0');
      return '$year-$month-$day';
    }

    return trimmed;
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return "À l'instant";
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Il y a ${diff.inHours} h";
    return "Il y a ${diff.inDays} j";
  }
}