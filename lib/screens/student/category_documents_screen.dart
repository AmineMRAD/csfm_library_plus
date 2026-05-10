// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'document_details_screen.dart';

class CategoryDocumentsScreen extends StatefulWidget {
  final String category;

  const CategoryDocumentsScreen({super.key, required this.category});

  @override
  State<CategoryDocumentsScreen> createState() =>
      _CategoryDocumentsScreenState();
}

class _CategoryDocumentsScreenState extends State<CategoryDocumentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _processingDocumentId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;

    final title = (data['title'] ?? '').toString().toLowerCase();
    final author = (data['author'] ?? '').toString().toLowerCase();

    return title.contains(_searchQuery) || author.contains(_searchQuery);
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Informatique':
        return Icons.computer_outlined;
      case 'Mathématiques':
        return Icons.calculate_outlined;
      case 'Histoire':
        return Icons.history_edu_outlined;
      case 'Sciences':
        return Icons.science_outlined;
      case 'Langues':
        return Icons.language_outlined;
      case 'Magazine':
        return Icons.menu_book_outlined;
      case 'DVD':
        return Icons.album_outlined;
      case 'Supports Pédagogiques':
        return Icons.school_outlined;
      default:
        return Icons.menu_book_outlined;
    }
  }

  Future<void> _reserveDocument(Map<String, dynamic> data) async {
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

    final documentId = (data['_id'] ?? data['id'] ?? '').toString();
    final documentTitle = (data['title'] ?? 'Document').toString();

    if (documentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Identifiant du document introuvable'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _processingDocumentId = documentId;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        if (!mounted) return;
        setState(() {
          _processingDocumentId = null;
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
      final role = (userData['role'] ?? 'externalStudent').toString();

      final existingReservation = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userId', isEqualTo: currentUser.uid)
          .where('documentId', isEqualTo: documentId)
          .limit(1)
          .get();

      if (existingReservation.docs.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _processingDocumentId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez déjà réservé ce document'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final reservationId = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .set({
            'id': reservationId,
            'userId': currentUser.uid,
            'userName': userName,
            'role': role,
            'documentId': documentId,
            'documentTitle': documentTitle,
            'date': DateTime.now().toIso8601String(),
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      setState(() {
        _processingDocumentId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processingDocumentId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la réservation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('documents')
              .where('category', isEqualTo: widget.category)
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];

            final documents = docs
                .map((doc) => {...doc.data(), '_id': doc.id})
                .where(_matchesSearch)
                .toList();

            return Column(
              children: [
                _buildHeader(totalCount: docs.length),
                Expanded(
                  child: documents.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                          itemCount: documents.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final doc = documents[index];
                            return _documentCard(doc);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader({required int totalCount}) {
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
      child: Column(
        children: [
          Row(
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
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(widget.category),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalCount documents',
                      style: const TextStyle(
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
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher dans cette catégorie...',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentCard(Map<String, dynamic> data) {
    final title = (data['title'] ?? '').toString();
    final author = (data['author'] ?? '').toString();
    final available = data['available'] == true;
    final year = (data['year'] ?? '').toString();
    final imagePath = (data['imagePath'] ?? '').toString();
    final documentId = (data['_id'] ?? data['id'] ?? '').toString();
    final isProcessing = _processingDocumentId == documentId;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DocumentDetailsScreen(documentData: data),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _documentImage(imagePath),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (year.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCE9FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            year,
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: available
                              ? const Color(0xFFDDF6E5)
                              : const Color(0xFFFFE5E5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          available ? 'Disponible' : 'Emprunté',
                          style: TextStyle(
                            color: available
                                ? const Color(0xFF16A34A)
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _outlinedActionButton(
                      icon: Icons.bookmark_border_rounded,
                      label: isProcessing
                          ? 'Réservation...'
                          : 'Réserver maintenant',
                      color: const Color(0xFF2563EB),
                      onTap: isProcessing ? null : () => _reserveDocument(data),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _documentImage(String imagePath) {
    return Container(
      width: 64,
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
                  size: 32,
                  color: Color(0xFF3B82F6),
                );
              },
            )
          : const Icon(
              Icons.menu_book_rounded,
              size: 32,
              color: Color(0xFF3B82F6),
            ),
    );
  }

  Widget _outlinedActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.35)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 42, color: Color(0xFF9CA3AF)),
            SizedBox(height: 12),
            Text(
              'No documents found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try another search in this category.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
