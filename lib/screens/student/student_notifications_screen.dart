// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'student_dashboard_screen.dart';

class StudentNotificationsScreen extends StatelessWidget {
  const StudentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: currentUid == null
              ? null
              : FirebaseFirestore.instance
                    .collection('reservations')
                    .where('userId', isEqualTo: currentUid)
                    .snapshots(),
          builder: (context, reservationSnapshot) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: currentUid == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('emprunts')
                        .where('userId', isEqualTo: currentUid)
                        .snapshots(),
              builder: (context, loanSnapshot) {
                if (reservationSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    loanSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reservations = reservationSnapshot.data?.docs ?? [];

                final loans = loanSnapshot.data?.docs ?? [];

                final notifications = <Map<String, dynamic>>[];

                for (final reservation in reservations) {
                  final data = reservation.data();

                  final title = (data['documentTitle'] ?? 'Document')
                      .toString();

                  final status = (data['status'] ?? 'pending')
                      .toString()
                      .toLowerCase();

                  if (status == 'approved') {
                    notifications.add({
                      'icon': Icons.check_circle_outline,
                      'color': const Color(0xFF16A34A),
                      'title': 'Réservation approuvée',
                      'message':
                          'Votre réservation pour "$title" a été acceptée.',
                    });
                  }

                  if (status == 'rejected') {
                    notifications.add({
                      'icon': Icons.cancel_outlined,
                      'color': Colors.red,
                      'title': 'Réservation refusée',
                      'message':
                          'Votre réservation pour "$title" a été refusée.',
                    });
                  }

                  if (data['pickupConfirmed'] == true) {
                    notifications.add({
                      'icon': Icons.library_add_check_rounded,
                      'color': const Color(0xFF2563EB),
                      'title': 'Retrait confirmé',
                      'message': 'Vous avez confirmé le retrait de "$title".',
                    });
                  }
                }

                for (final loan in loans) {
                  final data = loan.data();

                  final title = (data['documentTitle'] ?? 'Document')
                      .toString();

                  final returned = data['returned'] == true;

                  final returnDateRaw = data['returnDate'];

                  DateTime? returnDate;

                  if (returnDateRaw is Timestamp) {
                    returnDate = returnDateRaw.toDate();
                  } else if (returnDateRaw is String) {
                    returnDate = DateTime.tryParse(returnDateRaw);
                  }

                  if (!returned && returnDate != null) {
                    final now = DateTime.now();

                    if (returnDate.isBefore(now)) {
                      notifications.add({
                        'icon': Icons.warning_amber_rounded,
                        'color': Colors.red,
                        'title': 'Emprunt en retard',
                        'message': 'Le retour de "$title" est en retard.',
                      });
                    } else {
                      final remainingDays = returnDate.difference(now).inDays;

                      if (remainingDays <= 2) {
                        notifications.add({
                          'icon': Icons.schedule_rounded,
                          'color': Colors.orange,
                          'title': 'Retour bientôt dû',
                          'message':
                              'Le document "$title" doit être retourné bientôt.',
                        });
                      }
                    }
                  }

                  if (returned) {
                    notifications.add({
                      'icon': Icons.assignment_turned_in_rounded,
                      'color': const Color(0xFF16A34A),
                      'title': 'Document retourné',
                      'message':
                          'Le document "$title" a été retourné avec succès.',
                    });
                  }
                }

                return Column(
                  children: [
                    _buildHeader(context, notifications.length),
                    Expanded(
                      child: notifications.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucune notification',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final notif = notifications[index];

                                return _notificationCard(
                                  icon: notif['icon'],
                                  color: notif['color'],
                                  title: notif['title'],
                                  message: notif['message'],
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentDashboardScreen(),
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total notification(s)',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.14),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
