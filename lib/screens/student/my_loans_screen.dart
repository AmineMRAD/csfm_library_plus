// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyLoansScreen extends StatelessWidget {
  const MyLoansScreen({super.key});

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
                  .collection('emprunts')
                  .where('userId', isEqualTo: currentUid)
                  .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];

            final loans = docs
                .map((doc) => {
                      ...doc.data(),
                      '_id': doc.id,
                    })
                .where((loan) => loan['returned'] != true)
                .toList();

            loans.sort((a, b) {
              final dateA = _parseDate(a['borrowDate']);
              final dateB = _parseDate(b['borrowDate']);
              return dateB.compareTo(dateA);
            });

            final activeCount = loans.length;
            final overdueCount = loans.where((loan) {
              final returnDate = _parseDate(loan['returnDate']);
              return DateTime.now().isAfter(_endOfDay(returnDate));
            }).length;

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    children: [
                      _buildSummaryCard(
                        activeCount: activeCount,
                        overdueCount: overdueCount,
                      ),
                      const SizedBox(height: 18),
                      if (loans.isEmpty)
                        _buildEmptyState()
                      else
                        ...loans.map((loan) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _loanCard(loan),
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
                  'Mes emprunts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Gérez vos documents empruntés',
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
    required int activeCount,
    required int overdueCount,
  }) {
    Widget item(String count, String label, Color color) {
      return Expanded(
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
          item('$activeCount', 'Emprunts actifs', const Color(0xFF2563EB)),
          item('$overdueCount', 'En retard', const Color(0xFFF97316)),
        ],
      ),
    );
  }

  Widget _loanCard(Map<String, dynamic> loan) {
    final documentId = (loan['documentId'] ?? '').toString();
    final title = (loan['documentTitle'] ?? 'Document').toString();
    final borrowDate = _parseDate(loan['borrowDate']);
    final returnDate = _parseDate(loan['returnDate']);

    final now = DateTime.now();
    final remainingDays = _endOfDay(returnDate).difference(now).inDays + 1;
    final isOverdue = now.isAfter(_endOfDay(returnDate));

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: documentId.isEmpty
          ? null
          : FirebaseFirestore.instance.collection('documents').doc(documentId).get(),
      builder: (context, snapshot) {
        final documentData = snapshot.data?.data();
        final imagePath = (documentData?['imagePath'] ?? '').toString();
        final author = (documentData?['author'] ?? 'Auteur').toString();

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
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            height: 1.25,
                          ),
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
                                'Emprunté le:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(borrowDate),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'À retourner le:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(returnDate),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF111827),
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
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? const Color(0xFFFFE5E5)
                      : const Color(0xFFDCE9FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: isOverdue ? Colors.red : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOverdue
                          ? '${now.difference(_endOfDay(returnDate)).inDays + 1} jours de retard'
                          : '$remainingDays jours restants',
                      style: TextStyle(
                        color: isOverdue ? Colors.red : const Color(0xFF2563EB),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFF59E0B),
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Vous pouvez prolonger vos emprunts une fois si aucune réservation n'est en cours.",
              style: TextStyle(
                color: Color(0xFF1D4ED8),
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
            Icons.menu_book_outlined,
            size: 42,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 12),
          Text(
            'Aucun emprunt actif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Vos emprunts en cours apparaîtront ici.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }

    return DateTime.now();
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}