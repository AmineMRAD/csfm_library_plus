// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

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
            final reservationDocs = reservationSnapshot.data?.docs ?? [];

            final reservations = reservationDocs
                .map((doc) => {...doc.data(), '_id': doc.id})
                .toList();

            reservations.sort((a, b) {
              final dateA = _extractDate(a['createdAt'], a['date']);
              final dateB = _extractDate(b['createdAt'], b['date']);
              return dateB.compareTo(dateA);
            });

            final pendingCount = reservations
                .where((r) => _normalizeStatus(r['status']) == 'pending')
                .length;

            final approvedCount = reservations
                .where((r) => _normalizeStatus(r['status']) == 'approved')
                .length;

            final rejectedCount = reservations
                .where((r) => _normalizeStatus(r['status']) == 'rejected')
                .length;

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    children: [
                      _buildSummaryCard(
                        pendingCount: pendingCount,
                        approvedCount: approvedCount,
                        rejectedCount: rejectedCount,
                      ),
                      const SizedBox(height: 18),
                      if (reservations.isEmpty)
                        _buildEmptyState()
                      else
                        ...reservations.map((reservation) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _reservationCard(context, reservation),
                          );
                        }),
                      const SizedBox(height: 4),
                      _buildInfoBox(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 40,
              height: 40,
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
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes réservations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Suivez vos réservations',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required int pendingCount,
    required int approvedCount,
    required int rejectedCount,
  }) {
    Widget item(String count, String label, Color color) {
      return Expanded(
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          item('$pendingCount', 'En attente', const Color(0xFFF97316)),
          item('$approvedCount', 'Approuvées', const Color(0xFF16A34A)),
          item('$rejectedCount', 'Rejetées', const Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _reservationCard(
    BuildContext context,
    Map<String, dynamic> reservation,
  ) {
    final documentId = (reservation['documentId'] ?? '').toString();
    final documentTitle = (reservation['documentTitle'] ?? 'Document')
        .toString();
    final status = _normalizeStatus(reservation['status']);
    final reservedAt = _extractDate(
      reservation['createdAt'],
      reservation['date'],
    );
    final reservationId = (reservation['_id'] ?? reservation['id'] ?? '')
        .toString();
    final pickupConfirmed = reservation['pickupConfirmed'] == true;
    final pickupDeadline = _getPickupDeadline(reservation, reservedAt);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: documentId.isEmpty
          ? null
          : FirebaseFirestore.instance
                .collection('documents')
                .doc(documentId)
                .get(),
      builder: (context, documentSnapshot) {
        final documentData = documentSnapshot.data?.data();
        final imagePath = (documentData?['imagePath'] ?? '').toString();
        final author = (documentData?['author'] ?? 'Auteur').toString();

        final statusUi = _statusUi(status);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _documentImage(imagePath),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                documentTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  height: 1.25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusBadge(
                              label: statusUi.label,
                              textColor: statusUi.textColor,
                              bgColor: statusUi.bgColor,
                              icon: statusUi.icon,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          author,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Réservé le:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(reservedAt),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (status == 'pending') ...[
                          const SizedBox(height: 8),
                          FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            future: FirebaseFirestore.instance
                                .collection('reservations')
                                .where('documentId', isEqualTo: documentId)
                                .get(),
                            builder: (context, queueSnapshot) {
                              if (queueSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Row(
                                  children: const [
                                    Expanded(
                                      child: Text(
                                        'Position dans la file:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              final queueDocs = queueSnapshot.data?.docs ?? [];

                              final pendingForSameDocument = queueDocs
                                  .map((doc) => {...doc.data(), '_id': doc.id})
                                  .where(
                                    (item) =>
                                        _normalizeStatus(item['status']) ==
                                        'pending',
                                  )
                                  .toList();

                              pendingForSameDocument.sort((a, b) {
                                final dateA = _extractDate(
                                  a['createdAt'],
                                  a['date'],
                                );
                                final dateB = _extractDate(
                                  b['createdAt'],
                                  b['date'],
                                );
                                return dateA.compareTo(dateB);
                              });

                              int position = 0;
                              for (
                                int i = 0;
                                i < pendingForSameDocument.length;
                                i++
                              ) {
                                final itemId =
                                    (pendingForSameDocument[i]['_id'] ?? '')
                                        .toString();
                                if (itemId == reservationId) {
                                  position = i + 1;
                                  break;
                                }
                              }

                              return Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Position dans la file:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    position > 0 ? '#$position' : '--',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (status == 'pending') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => _cancelReservation(context, reservationId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1F1),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Annuler la réservation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              if (status == 'approved') ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FFF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            pickupConfirmed
                                ? Icons.check_circle_outline
                                : Icons.event_available_outlined,
                            color: const Color(0xFF16A34A),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pickupConfirmed
                                ? 'Retrait confirmé'
                                : 'Document disponible!',
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pickupConfirmed
                            ? 'Le document a été retiré avec succès.'
                            : 'À retirer avant le ${_formatDate(pickupDeadline)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!pickupConfirmed) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _confirmPickup(context, reservationId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Confirmer le retrait',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  DateTime _getPickupDeadline(
    Map<String, dynamic> reservation,
    DateTime reservedAt,
  ) {
    final pickupDeadline = reservation['pickupDeadline'];

    if (pickupDeadline is Timestamp) return pickupDeadline.toDate();
    if (pickupDeadline is DateTime) return pickupDeadline;

    if (pickupDeadline is String) {
      final parsed = DateTime.tryParse(pickupDeadline);
      if (parsed != null) return parsed;
    }

    return reservedAt.add(const Duration(days: 3));
  }

  Future<void> _confirmPickup(
    BuildContext context,
    String reservationId,
  ) async {
    if (reservationId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .update({
            'pickupConfirmed': true,
            'pickupConfirmedAt': DateTime.now().toIso8601String(),
          });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retrait confirmé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la confirmation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelReservation(
    BuildContext context,
    String reservationId,
  ) async {
    if (reservationId.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Annuler la réservation'),
          content: const Text(
            'Voulez-vous vraiment annuler cette réservation ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Non'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Oui, annuler'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation annulée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l’annulation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _documentImage(String imagePath) {
    return Container(
      width: 62,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagePath.isNotEmpty
          ? Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.menu_book_rounded,
                  size: 30,
                  color: Color(0xFF3B82F6),
                );
              },
            )
          : const Icon(
              Icons.menu_book_rounded,
              size: 30,
              color: Color(0xFF3B82F6),
            ),
    );
  }

  Widget _statusBadge({
    required String label,
    required Color textColor,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F0FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "En tant qu'apprenant logé, vous bénéficiez d'une priorité sur les réservations.",
              style: TextStyle(
                color: Color(0xFF7E22CE),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 42,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 12),
          Text(
            'Aucune réservation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Vos réservations apparaîtront ici.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  _ReservationStatusUi _statusUi(String status) {
    switch (status) {
      case 'approved':
        return const _ReservationStatusUi(
          label: 'Approuvée',
          textColor: Color(0xFF16A34A),
          bgColor: Color(0xFFDDF6E5),
          icon: Icons.check_circle_outline,
        );
      case 'rejected':
        return const _ReservationStatusUi(
          label: 'Rejetée',
          textColor: Color(0xFF94A3B8),
          bgColor: Color(0xFFF1F5F9),
          icon: Icons.cancel_outlined,
        );
      default:
        return const _ReservationStatusUi(
          label: 'En attente',
          textColor: Color(0xFFF97316),
          bgColor: Color(0xFFFFEDD5),
          icon: Icons.access_time,
        );
    }
  }

  String _normalizeStatus(dynamic value) {
    final raw = (value ?? 'pending').toString().toLowerCase();

    if (raw == 'approved' ||
        raw == 'acceptée' ||
        raw == 'acceptee' ||
        raw == 'accepted' ||
        raw == 'confirmée' ||
        raw == 'confirmee' ||
        raw == 'confirmed') {
      return 'approved';
    }

    if (raw == 'rejected' || raw == 'refusée' || raw == 'refusee') {
      return 'rejected';
    }

    return 'pending';
  }

  DateTime _extractDate(dynamic createdAt, dynamic date) {
    if (createdAt is Timestamp) return createdAt.toDate();
    if (createdAt is DateTime) return createdAt;

    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;

    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return parsed;
    }

    return DateTime.now();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _ReservationStatusUi {
  final String label;
  final Color textColor;
  final Color bgColor;
  final IconData icon;

  const _ReservationStatusUi({
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.icon,
  });
}
