// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'document_list_screen.dart';
import 'loan_list_screen.dart';
import 'reservation_list_screen.dart';
import 'users_list_screen.dart';
import 'statistics_screen.dart';
import 'notifications_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<void> _showAdminProfileSheet(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    if (currentUser == null) return;

    final authService = AuthService();
    final userData = await authService.getUserData(currentUser.uid);

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final name = userData?.name ?? 'Admin';
        final email = userData?.email ?? currentUser.email ?? '--';
        final role = _roleLabel(userData?.role);

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Mon profil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(sheetContext),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _profileRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Nom',
                    value: name,
                  ),
                  const SizedBox(height: 14),

                  _profileRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    value: email,
                  ),
                  const SizedBox(height: 14),

                  _profileRow(
                    icon: Icons.badge_outlined,
                    label: 'Rôle',
                    value: role,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        if (!sheetContext.mounted) return;

                        Navigator.pop(sheetContext);

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.boardingStudent:
        return 'Apprenant logé';
      case UserRole.externalStudent:
        return 'Apprenant externe';
      default:
        return 'Administrateur';
    }
  }

  Widget _profileRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF2FB),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(context),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  "Bienvenue, Admin Test",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showAdminProfileSheet(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
              ),
            ),
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
          stream: FirebaseFirestore.instance
              .collection('documents')
              .snapshots(),
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
          stream: FirebaseFirestore.instance
              .collection('reservations')
              .snapshots(),
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
              _action(Icons.notifications, "Notifications", Colors.red, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              }),
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
          stream: FirebaseFirestore.instance
              .collection('reservations')
              .snapshots(),
          builder: (context, reservationSnapshot) {
            if (loanSnapshot.connectionState == ConnectionState.waiting ||
                reservationSnapshot.connectionState ==
                    ConnectionState.waiting) {
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
              return {...doc.data(), '_type': 'loan', '_id': doc.id};
            }).toList();

            final reservations = (reservationSnapshot.data?.docs ?? []).map((
              doc,
            ) {
              return {...doc.data(), '_type': 'reservation', '_id': doc.id};
            }).toList();

            final allActivities = [...loans, ...reservations];

            allActivities.sort((a, b) {
              final dateA = _extractDate(a);
              final dateB = _extractDate(b);
              return dateB.compareTo(dateA);
            });

            final now = DateTime.now();

            final recent = allActivities
                .where((activity) {
                  final activityDate = _extractDate(activity);

                  final difference = now.difference(activityDate);

                  return difference.inHours < 24;
                })
                .take(5)
                .toList();

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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  if (recent.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Aucune activité récente",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
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
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
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
                Text(userName, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Text(
            _timeAgo(date),
            style: const TextStyle(fontSize: 11, color: Colors.black54),
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

    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Il y a ${diff.inHours} h";
    return "Il y a ${diff.inDays} j";
  }
}
