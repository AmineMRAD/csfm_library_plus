// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                  return const Center(child: CircularProgressIndicator());
                }

                final loans = (loanSnapshot.data?.docs ?? []).map((doc) {
                  return {
                    ...doc.data(),
                    '_id': doc.id,
                  };
                }).toList();

                final reservations =
                    (reservationSnapshot.data?.docs ?? []).map((doc) {
                  return {
                    ...doc.data(),
                    '_id': doc.id,
                  };
                }).toList();

                final notifications = _buildNotifications(
                  loans: loans,
                  reservations: reservations,
                );

                final urgentCount =
                    notifications.where((n) => n.type == _NotifType.urgent).length;
                final pendingCount =
                    notifications.where((n) => n.type == _NotifType.pending).length;
                final completedCount = notifications
                    .where((n) => n.type == _NotifType.completed)
                    .length;

                return Column(
                  children: [
                    _buildHeader(
                      context,
                      total: notifications.length,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            if (urgentCount > 0) ...[
                              _buildUrgentAlert(urgentCount),
                              const SizedBox(height: 16),
                            ],
                            if (notifications.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text(
                                  'Aucune notification pour le moment',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            else
                              ...notifications.map((notification) {
                                return _notificationCard(notification);
                              }).toList(),
                            const SizedBox(height: 20),
                            _buildSummary(
                              urgentCount: urgentCount,
                              pendingCount: pendingCount,
                              completedCount: completedCount,
                            ),
                          ],
                        ),
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

  List<_NotificationItem> _buildNotifications({
    required List<Map<String, dynamic>> loans,
    required List<Map<String, dynamic>> reservations,
  }) {
    final now = DateTime.now();
    final List<_NotificationItem> items = [];

    for (final loan in loans) {
      final returned = loan['returned'] == true;
      final userName = _extractString(
        loan,
        ['userName', 'name', 'user'],
        fallback: 'Utilisateur',
      );
      final documentTitle = _extractString(
        loan,
        ['documentTitle', 'title'],
        fallback: 'Document',
      );

      final createdAt = _extractDate(
        loan,
        ['createdAt', 'borrowDate', 'loanDate', 'date'],
      );
      final dueDate = _extractDate(
        loan,
        ['returnDate', 'dueDate'],
      );

      if (!returned && dueDate != null && _isBeforeDay(dueDate, now)) {
        final daysLate = _daysBetween(_startOfDay(dueDate), _startOfDay(now));

        items.add(
          _NotificationItem(
            type: _NotifType.urgent,
            icon: Icons.warning_rounded,
            color: Colors.red,
            title: 'Retour en retard',
            description:
                '$userName n\'a pas retourné "$documentTitle" ($daysLate ${daysLate > 1 ? 'jours' : 'jour'} de retard)',
            time: _timeAgo(createdAt ?? dueDate),
            actionText: 'Envoyer un rappel',
            sortDate: createdAt ?? dueDate,
          ),
        );
      }

      if (!returned &&
          dueDate != null &&
          (_isSameDay(dueDate, now) ||
              _isSameDay(dueDate, now.add(const Duration(days: 1))))) {
        final dueLabel = _isSameDay(dueDate, now) ? 'aujourd\'hui' : 'demain';

        items.add(
          _NotificationItem(
            type: _NotifType.pending,
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            title: 'Retour bientôt dû',
            description:
                '$userName doit retourner "$documentTitle" $dueLabel',
            time: _timeAgo(createdAt ?? dueDate),
            actionText: 'Envoyer un rappel',
            sortDate: createdAt ?? dueDate,
          ),
        );
      }

      if (returned) {
        items.add(
          _NotificationItem(
            type: _NotifType.completed,
            icon: Icons.check_circle,
            color: Colors.green,
            title: 'Document retourné',
            description: '$userName a retourné "$documentTitle"',
            time: _timeAgo(createdAt ?? DateTime.now()),
            actionText: null,
            sortDate: createdAt ?? DateTime.now(),
          ),
        );
      }
    }

    for (final reservation in reservations) {
      final userName = _extractString(
        reservation,
        ['userName', 'name', 'user'],
        fallback: 'Utilisateur',
      );
      final documentTitle = _extractString(
        reservation,
        ['documentTitle', 'title'],
        fallback: 'Document',
      );
      final status = _extractString(
        reservation,
        ['status'],
        fallback: 'pending',
      ).toLowerCase();

      final reservationDate = _extractDate(
        reservation,
        ['createdAt', 'date', 'reservationDate'],
      );

      if (status == 'pending' || status == 'en attente') {
        items.add(
          _NotificationItem(
            type: _NotifType.pending,
            icon: Icons.access_time,
            color: Colors.orange,
            title: 'Réservation en attente',
            description:
                '$userName attend la validation de sa réservation',
            time: _timeAgo(reservationDate ?? DateTime.now()),
            actionText: 'Voir la réservation',
            sortDate: reservationDate ?? DateTime.now(),
          ),
        );
      } else if (status == 'approved' ||
          status == 'accepted' ||
          status == 'confirmed' ||
          status == 'confirmée' ||
          status == 'confirmee') {
        items.add(
          _NotificationItem(
            type: _NotifType.pending,
            icon: Icons.access_time,
            color: Colors.orange,
            title: 'Nouvelle réservation',
            description:
                '$userName a réservé "$documentTitle"',
            time: _timeAgo(reservationDate ?? DateTime.now()),
            actionText: 'Voir la réservation',
            sortDate: reservationDate ?? DateTime.now(),
          ),
        );
      } else {
        items.add(
          _NotificationItem(
            type: _NotifType.pending,
            icon: Icons.access_time,
            color: Colors.orange,
            title: 'Nouvelle réservation',
            description:
                '$userName a réservé "$documentTitle"',
            time: _timeAgo(reservationDate ?? DateTime.now()),
            actionText: 'Voir la réservation',
            sortDate: reservationDate ?? DateTime.now(),
          ),
        );
      }
    }

    items.sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return items.take(20).toList();
  }

  Widget _buildHeader(BuildContext context, {required int total}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'Retour',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notifications",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Alertes et événements",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "$total\nTotal",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentAlert(int urgentCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Vous avez $urgentCount notification${urgentCount > 1 ? 's' : ''} urgente${urgentCount > 1 ? 's' : ''} nécessitant votre attention",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(_NotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: item.color.withOpacity(0.2),
            child: Icon(item.icon, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(item.description, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    if (item.actionText != null)
                      Text(
                        item.actionText!,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary({
    required int urgentCount,
    required int pendingCount,
    required int completedCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_none, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "Résumé",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _summaryBox(
                  urgentCount.toString(),
                  "Urgentes",
                  Colors.red,
                  Icons.warning_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryBox(
                  pendingCount.toString(),
                  "En attente",
                  Colors.orange,
                  Icons.access_time,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryBox(
                  completedCount.toString(),
                  "Complétées",
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(
    String count,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _extractString(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  DateTime? _extractDate(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;

      if (value is String) {
        final normalized = _normalizeDateString(value);
        final parsed = DateTime.tryParse(normalized);
        if (parsed != null) return parsed;
      }
    }
    return null;
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isBeforeDay(DateTime a, DateTime b) {
    final da = _startOfDay(a);
    final db = _startOfDay(b);
    return da.isBefore(db);
  }

  DateTime _startOfDay(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  int _daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }
}

enum _NotifType {
  urgent,
  pending,
  completed,
}

class _NotificationItem {
  final _NotifType type;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String time;
  final String? actionText;
  final DateTime sortDate;

  _NotificationItem({
    required this.type,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.time,
    required this.actionText,
    required this.sortDate,
  });
}