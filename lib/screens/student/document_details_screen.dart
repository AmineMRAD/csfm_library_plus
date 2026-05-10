// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DocumentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> documentData;

  const DocumentDetailsScreen({
    super.key,
    required this.documentData,
  });

  @override
  State<DocumentDetailsScreen> createState() => _DocumentDetailsScreenState();
}

class _DocumentDetailsScreenState extends State<DocumentDetailsScreen> {
  bool _isReserving = false;

  Future<void> _reserveDocument() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non connecté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final documentId =
        (widget.documentData['_id'] ?? widget.documentData['id'] ?? '')
            .toString();
    final documentTitle =
        (widget.documentData['title'] ?? 'Document').toString();

    if (documentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document introuvable'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isReserving = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        if (!mounted) return;
        setState(() {
          _isReserving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil utilisateur introuvable'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userData = userDoc.data() ?? {};
      final userName = (userData['name'] ?? 'Utilisateur').toString();
      final userRole = (userData['role'] ?? 'externalStudent').toString();

      final existingReservation = await firestore
          .collection('reservations')
          .where('userId', isEqualTo: currentUser.uid)
          .where('documentId', isEqualTo: documentId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingReservation.docs.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _isReserving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez déjà réservé ce document'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final now = DateTime.now();
      final reservationId = now.millisecondsSinceEpoch.toString();

      await firestore.collection('reservations').doc(reservationId).set({
        'id': reservationId,
        'userId': currentUser.uid,
        'userName': userName,
        'userRole': userRole,
        'documentId': documentId,
        'documentTitle': documentTitle,
        'reservationDate': now.toIso8601String(),
        'createdAt': now.toIso8601String(),
        'status': 'pending',
        'priority': userRole == 'boardingStudent' ? 1 : 2,
      });

      if (!mounted) return;
      setState(() {
        _isReserving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation envoyée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isReserving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de réservation : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.documentData;

    final title = (data['title'] ?? 'Document').toString();
    final author = (data['author'] ?? 'Unknown author').toString();
    final category = (data['category'] ?? 'Unknown').toString();
    final year = (data['year'] ?? '').toString();
    final description = (data['description'] ??
            'Ce document offre une exploration complète du sujet traité, avec des explications claires et des exemples pratiques.')
        .toString();
    final imagePath = (data['imagePath'] ?? '').toString();
    final available = data['available'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildMainCard(
                  title: title,
                  author: author,
                  category: category,
                  year: year,
                  available: available,
                  imagePath: imagePath,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDescriptionCard(description),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildReserveButton(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildInfoBox(),
              ),
            ],
          ),
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
            child: Text(
              'Détails du document',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required String author,
    required String category,
    required String year,
    required bool available,
    required String imagePath,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 128,
            height: 178,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE8FF),
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: imagePath.isNotEmpty
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.menu_book_rounded,
                        size: 46,
                        color: Color(0xFF3B82F6),
                      );
                    },
                  )
                : const Icon(
                    Icons.menu_book_rounded,
                    size: 46,
                    color: Color(0xFF3B82F6),
                  ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            author,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:
                  available ? const Color(0xFFDDF6E5) : const Color(0xFFFFE5E5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              available ? 'Disponible' : 'Emprunté',
              style: TextStyle(
                color: available ? const Color(0xFF16A34A) : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _infoTile(
            icon: Icons.menu_book_outlined,
            label: 'Catégorie',
            value: category,
          ),
          const SizedBox(height: 12),
          _infoTile(
            icon: Icons.calendar_today_outlined,
            label: 'Année de publication',
            value: year,
          ),
          const SizedBox(height: 12),
          _infoTile(
            icon: Icons.person_outline_rounded,
            label: 'Auteur',
            value: author,
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF111827),
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

  Widget _buildDescriptionCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF334155),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReserveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isReserving ? null : _reserveDocument,
        icon: _isReserving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.bookmark_border_rounded),
        label: Text(
          _isReserving ? 'Réservation en cours...' : 'Réserver ce document',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF94A3B8),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
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
            Icons.push_pin_outlined,
            color: Color(0xFFEC4899),
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Les apprenants logés ont la priorité sur les réservations. Les emprunts sont validés par le bibliothécaire.",
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
}