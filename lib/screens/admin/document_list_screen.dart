// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/document_model.dart';
import '../../services/document_service.dart';
import 'add_document_screen.dart';

class DocumentListScreen extends StatelessWidget {
  const DocumentListScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    String documentId,
  ) async {
    final documentService = DocumentService();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le document'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce document ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await documentService.deleteDocument(documentId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document supprimé avec succès'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editDocument(BuildContext context, Map<String, dynamic> data) {
    final document = DocumentModel.fromMap(data);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDocumentScreen(document: document),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('documents')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSearchAndFilters(),
                        const SizedBox(height: 16),
                        _buildAddButton(context),
                        const SizedBox(height: 24),
                        const Center(
                          child: Text("Aucun document disponible"),
                        ),
                      ],
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildSearchAndFilters();
                      }

                      if (index == 1) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: _buildAddButton(context),
                        );
                      }

                      final doc = docs[index - 2];
                      final data = doc.data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildDocumentCard(
                          context,
                          data,
                          onEdit: () => _editDocument(context, data),
                          onDelete: () => _confirmDelete(context, data['id']),
                        ),
                      );
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  "Retour",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Gestion des documents",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Gérez votre bibliothèque",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Rechercher un document...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF5F7FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip("Tous", true),
                const SizedBox(width: 8),
                _filterChip("Informatique", false),
                const SizedBox(width: 8),
                _filterChip("Mathématiques", false),
                const SizedBox(width: 8),
                _filterChip("Histoire", false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2563EB) : const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddDocumentScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Ajouter un document",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    Map<String, dynamic> data, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final bool available = data['available'] ?? true;
    final String imagePath =
        (data['imagePath'] ?? 'assets/images/documents/Book1.jpg').toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              width: 76,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 76,
                  height: 96,
                  color: Colors.blue.shade100,
                  child: const Icon(Icons.book, color: Colors.blue),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['author']?.toString() ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _tag(
                      data['category']?.toString() ?? '',
                      const Color(0xFFDDE8FF),
                      const Color(0xFF2563EB),
                    ),
                    _tag(
                      available ? "Disponible" : "Emprunté",
                      available
                          ? const Color(0xFFDFF5E4)
                          : const Color(0xFFFFE0E0),
                      available ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onEdit,
                        child: _smallButton(
                          "Modifier",
                          Icons.edit_outlined,
                          const Color(0xFFDDE8FF),
                          const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: onDelete,
                        child: _smallButton(
                          "Supprimer",
                          Icons.delete_outline,
                          const Color(0xFFFFE5E5),
                          Colors.red,
                        ),
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

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _smallButton(String text, IconData icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}