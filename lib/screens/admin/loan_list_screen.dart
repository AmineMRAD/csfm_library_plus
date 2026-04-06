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
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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
                Text(
                  "Retour",
                  style: TextStyle(color: Colors.white),
                ),
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
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _showAddLoanDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Ajouter un emprunt",
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

  Widget _buildLoanCard(
    BuildContext context,
    EmpruntModel emprunt,
    EmpruntService service,
  ) {
    final now = DateTime.now();
    final returnDate = DateTime.tryParse(emprunt.returnDate);
    final isLate =
        !emprunt.returned && returnDate != null && returnDate.isBefore(now);

    final statusText =
        emprunt.returned ? "Retourné" : (isLate ? "En retard" : "En cours");

    final statusColor =
        emprunt.returned ? Colors.green : (isLate ? Colors.red : Colors.green);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
          ),
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
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Emprunté le :",
                      style: TextStyle(fontSize: 12),
                    ),
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
                  label: const Text("Marquer comme retourné"),
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
    final returnDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nouvel emprunt"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
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
                          decoration: const InputDecoration(
                            labelText: 'Utilisateur',
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
                          decoration: const InputDecoration(
                            labelText: 'Document',
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
                    TextField(
                      controller: returnDateController,
                      decoration: const InputDecoration(
                        labelText: 'Date de retour prévue',
                        hintText: 'Ex: 2026-04-20',
                      ),
                    ),
                  ],
                ),
              );
            },
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
                    returnDateController.text.trim().isEmpty) {
                  return;
                }

                final emprunt = EmpruntModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: selectedUserId!,
                  userName: selectedUserName ?? 'Utilisateur',
                  documentId: selectedDocumentId!,
                  documentTitle: selectedDocumentTitle ?? 'Document',
                  borrowDate: DateTime.now().toString().substring(0, 10),
                  returnDate: returnDateController.text.trim(),
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
              ),
              child: const Text(
                "Ajouter",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}