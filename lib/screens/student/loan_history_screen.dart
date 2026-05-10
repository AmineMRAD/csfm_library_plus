// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoanHistoryScreen extends StatelessWidget {
  const LoanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: currentUid == null
                    ? null
                    : FirebaseFirestore.instance
                        .collection('emprunts')
                        .where('userId', isEqualTo: currentUid)
                        .where('returned', isEqualTo: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: _emptyCard(),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final loanData = docs[index].data();
                      return _historyCard(loanData);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> loanData) {
    final documentId = (loanData['documentId'] ?? '').toString();

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: documentId.isEmpty
          ? null
          : FirebaseFirestore.instance
              .collection('documents')
              .doc(documentId)
              .get(),
      builder: (context, snapshot) {
        final documentData = snapshot.data?.data();

        final title = (loanData['documentTitle'] ??
                documentData?['title'] ??
                'Document')
            .toString();

        final author = (documentData?['author'] ??
                loanData['documentAuthor'] ??
                'Auteur inconnu')
            .toString();

        final imagePath = (documentData?['imagePath'] ?? '').toString();

        final borrowDate = _parseDate(loanData['borrowDate']);
        final returnDate = _parseDate(loanData['returnDate']);
        final returnedAt = _parseDate(loanData['returnedAt']);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
              _documentImage(imagePath),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      author,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _greenBadge('Retourné'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dateLine('Emprunté le', borrowDate),
                    const SizedBox(height: 6),
                    _dateLine('Date prévue', returnDate),
                    const SizedBox(height: 6),
                    _dateLine('Retourné le', returnedAt),
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
      width: 68,
      height: 88,
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
                  size: 34,
                  color: Color(0xFF2563EB),
                );
              },
            )
          : const Icon(
              Icons.menu_book_rounded,
              size: 34,
              color: Color(0xFF2563EB),
            ),
    );
  }

  Widget _greenBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF6E5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF16A34A),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _dateLine(String label, DateTime date) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Text(
          _formatDate(date),
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 52,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 12),
          Text(
            'Aucun historique',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vos anciens emprunts apparaîtront ici.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            onTap: () => Navigator.pop(context),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historique',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Historique des emprunts',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
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

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}