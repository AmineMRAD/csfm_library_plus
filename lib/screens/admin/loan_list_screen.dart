// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/emprunt_model.dart';
import '../../services/emprunt_service.dart';

class LoanListScreen extends StatelessWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final empruntService = EmpruntService();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<List<EmpruntModel>>(
                stream: empruntService.getEmprunts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final emprunts = snapshot.data ?? [];

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildAddButton(context),
                      const SizedBox(height: 16),
                      if (emprunts.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text("Aucun emprunt disponible"),
                          ),
                        )
                      else ...[
                        ...emprunts.map(
                          (emprunt) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildLoanCard(
                              context,
                              emprunt,
                              empruntService,
                            ),
                          ),
                        ),
                        _buildSummary(emprunts),
                      ],
                    ],
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
                Text("Retour", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Gestion des emprunts",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Suivez les emprunts actifs",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showAddLoanDialog(context),
        icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
        label: const Text(
          "Ajouter un emprunt",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanCard(
    BuildContext context,
    EmpruntModel emprunt,
    EmpruntService service,
  ) {
    final now = DateTime.now();
    final returnDate = DateTime.tryParse(emprunt.returnDate);
    final isLate =
        !emprunt.returned && returnDate != null && returnDate.isBefore(now);

    final statusText = emprunt.returned
        ? "Retourné"
        : (isLate ? "En retard" : "En cours");

    final statusColor = emprunt.returned
        ? Colors.green
        : (isLate ? Colors.red : Colors.green);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  emprunt.userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            emprunt.documentTitle,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Emprunté le :", style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      emprunt.borrowDate,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Retour prévu :",
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emprunt.returnDate,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isLate ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: emprunt.returned
                      ? null
                      : () async {
                          await service.markAsReturned(emprunt);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Document marqué comme retourné'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text("retourné"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await service.cancelEmprunt(emprunt);

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emprunt annulé avec succès'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text("Annuler"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(List<EmpruntModel> emprunts) {
    final actifs = emprunts.where((e) => !e.returned).length;
    final completes = emprunts.where((e) => e.returned).length;

    final now = DateTime.now();
    final enRetard = emprunts.where((e) {
      final d = DateTime.tryParse(e.returnDate);
      return !e.returned && d != null && d.isBefore(now);
    }).length;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(actifs.toString(), "Actifs", Colors.blue),
          _summaryItem(enRetard.toString(), "En retard", Colors.red),
          _summaryItem(completes.toString(), "Complétés", Colors.green),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Future<void> _showAddLoanDialog(BuildContext context) async {
    final empruntService = EmpruntService();

    String? selectedUserId;
    String? selectedUserName;
    String? selectedDocumentId;
    String? selectedDocumentTitle;
    DateTime? selectedReturnDate;

    String formatDate(DateTime date) {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '${date.year}-$month-$day';
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.library_books_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Nouvel emprunt",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        final users = snapshot.data?.docs ?? [];

                        return DropdownButtonFormField<String>(
                          value: selectedUserId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Utilisateur',
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: users.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            return DropdownMenuItem<String>(
                              value: data['uid'],
                              child: Text(data['name'] ?? ''),
                              onTap: () {
                                selectedUserName = data['name'];
                              },
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedUserId = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('documents')
                          .where('available', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final documents = snapshot.data?.docs ?? [];

                        return DropdownButtonFormField<String>(
                          value: selectedDocumentId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Document',
                            prefixIcon: const Icon(Icons.menu_book_outlined),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: documents.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            return DropdownMenuItem<String>(
                              value: data['id'],
                              child: Text(data['title'] ?? ''),
                              onTap: () {
                                selectedDocumentTitle = data['title'];
                              },
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedDocumentId = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final now = DateTime.now();

                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: now.add(const Duration(days: 14)),
                          firstDate: now,
                          lastDate: DateTime(now.year + 2),
                        );

                        if (pickedDate != null) {
                          setStateDialog(() {
                            selectedReturnDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedReturnDate == null
                                    ? 'Choisir la date de retour prévue'
                                    : formatDate(selectedReturnDate!),
                                style: TextStyle(
                                  color: selectedReturnDate == null
                                      ? const Color(0xFF6B7280)
                                      : const Color(0xFF111827),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedUserId == null ||
                        selectedDocumentId == null ||
                        selectedReturnDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez remplir tous les champs'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final today = DateTime.now();
                    final todayOnly = DateTime(
                      today.year,
                      today.month,
                      today.day,
                    );
                    final returnOnly = DateTime(
                      selectedReturnDate!.year,
                      selectedReturnDate!.month,
                      selectedReturnDate!.day,
                    );

                    if (returnOnly.isBefore(todayOnly)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La date de retour ne peut pas être dans le passé',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final emprunt = EmpruntModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: selectedUserId!,
                      userName: selectedUserName ?? 'Utilisateur',
                      documentId: selectedDocumentId!,
                      documentTitle: selectedDocumentTitle ?? 'Document',
                      borrowDate: formatDate(DateTime.now()),
                      returnDate: formatDate(selectedReturnDate!),
                      returned: false,
                    );

                    await empruntService.addEmprunt(emprunt);

                    if (!context.mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emprunt ajouté avec succès'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Ajouter",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
