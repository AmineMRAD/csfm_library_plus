// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'category_documents_screen.dart';
import 'my_reservations_screen.dart';
import 'my_loans_screen.dart';
import 'loan_history_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  Future<void> _showStudentProfileSheet(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    if (currentUser == null) return;

    final authService = AuthService();
    final userData = await authService.getUserData(currentUser.uid);

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final name = userData?.name ?? 'Utilisateur';
        final email = userData?.email ?? currentUser.email ?? '--';
        final role = _roleLabel(userData?.role);

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Mon profil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(sheetContext),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _profileRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Nom complet',
                    value: name,
                  ),
                  const SizedBox(height: 14),
                  _profileRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    value: email,
                  ),
                  const SizedBox(height: 14),
                  _profileRow(
                    icon: Icons.badge_outlined,
                    label: 'Rôle',
                    value: role,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        if (!sheetContext.mounted) return;
                        Navigator.pop(sheetContext);

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.boardingStudent:
        return 'Apprenant logé';
      case UserRole.externalStudent:
        return 'Apprenant externe';
      default:
        return 'Utilisateur';
    }
  }

  Widget _profileRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _buildHeader(context, currentUid),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStatsRow(context, currentUid),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCategoriesCard(context),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRecommendedSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? currentUid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
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
      margin: const EdgeInsets.all(8),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: currentUid == null
            ? null
            : FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUid)
                  .snapshots(),
        builder: (context, snapshot) {
          final userData = snapshot.data?.data();
          final name = (userData?['name'] ?? 'Apprenant').toString();
          final roleRaw = (userData?['role'] ?? 'externalStudent').toString();

          String subtitle;
          if (roleRaw == 'boardingStudent') {
            subtitle = 'Apprenant logé';
          } else if (roleRaw == 'externalStudent') {
            subtitle = 'Apprenant externe';
          } else {
            subtitle = 'Utilisateur';
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, $name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showStudentProfileSheet(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                      ),
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
                child: const TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un document...',
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 15,
                    ),
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
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, String? currentUid) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _studentStatCard(
              title: 'Emprunts',
              color: const Color(0xFF2563EB),
              icon: Icons.menu_book_outlined,
              stream: currentUid == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('emprunts')
                        .where('userId', isEqualTo: currentUid)
                        .where('returned', isEqualTo: false)
                        .snapshots(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyLoansScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _studentStatCard(
              title: 'Réservations',
              color: const Color(0xFFF97316),
              icon: Icons.calendar_today_outlined,
              stream: currentUid == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('reservations')
                        .where('userId', isEqualTo: currentUid)
                        .snapshots(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyReservationsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _studentStatCard(
              title: 'Historique',
              color: const Color(0xFF16A34A),
              icon: Icons.description_outlined,
              stream: currentUid == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('emprunts')
                        .where('userId', isEqualTo: currentUid)
                        .snapshots(),
              countReturnedOnly: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoanHistoryScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentStatCard({
    required String title,
    required Color color,
    required IconData icon,
    required Stream<QuerySnapshot<Map<String, dynamic>>>? stream,
    bool countReturnedOnly = false,
    VoidCallback? onTap,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        int count;
        if (countReturnedOnly) {
          count = docs.where((doc) => doc.data()['returned'] == true).length;
        } else {
          count = docs.length;
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 14),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesCard(BuildContext context) {
    final categories = [
      ('Informatique', Icons.computer_outlined),
      ('Mathématiques', Icons.calculate_outlined),
      ('Histoire', Icons.history_edu_outlined),
      ('Sciences', Icons.science_outlined),
      ('Langues', Icons.language_outlined),
      ('Magazine', Icons.menu_book_outlined),
      ('DVD', Icons.album_outlined),
      ('Supports Pédagogiques', Icons.school_outlined),
    ];

    Widget categoryCard(String title, IconData icon) {
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('documents')
            .where('category', isEqualTo: title)
            .snapshots(),
        builder: (context, snapshot) {
          final count = snapshot.data?.docs.length ?? 0;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryDocumentsScreen(category: title),
                ),
              );
            },
            child: Container(
              height: 150,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28, color: const Color(0xFF2563EB)),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget twoColumnGrid(List<(String, IconData)> items) {
      return Column(
        children: [
          for (int i = 0; i < items.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Expanded(child: categoryCard(items[i].$1, items[i].$2)),
                  const SizedBox(width: 12),
                  if (i + 1 < items.length)
                    Expanded(
                      child: categoryCard(
                        items[i + 1].$1,
                        items[i + 1].$2),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
        ],
      );
    }

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
            'Catégories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 18),
          twoColumnGrid(categories),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('documents')
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommandés pour vous',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 14),
            if (docs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: const Text(
                  'Aucun document disponible pour le moment.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
              )
            else
              ...docs.map((doc) {
                final data = doc.data();
                final title = (data['title'] ?? '').toString();
                final author = (data['author'] ?? '').toString();
                final category = (data['category'] ?? '').toString();
                final available = data['available'] == true;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _recommendedCard(
                    title: title,
                    author: author,
                    category: category,
                    available: available,
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _recommendedCard({
    required String title,
    required String author,
    required String category,
    required bool available,
  }) {
    return Container(
      width: double.infinity,
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
        children: [
          Container(
            width: 64,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE8FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 30,
              color: Color(0xFF3B82F6),
            ),
          ),
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
                        category.isEmpty ? 'Document' : category,
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
                        available ? 'Disponible' : 'Indisponible',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
