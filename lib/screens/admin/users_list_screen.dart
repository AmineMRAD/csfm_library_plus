// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchNotifier = ValueNotifier('');
  final ValueNotifier<String> _filterNotifier = ValueNotifier('Tous');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchNotifier.value = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchNotifier.dispose();
    _filterNotifier.dispose();
    super.dispose();
  }

  bool _matchesFilter(Map<String, dynamic> user, String selectedFilter) {
    final role = (user['role'] ?? '').toString();

    switch (selectedFilter) {
      case 'Admin':
        return role == 'admin';
      case 'Logés':
        return role == 'boardingStudent' || role == 'Apprenant logé';
      case 'Externes':
        return role == 'externalStudent' || role == 'Apprenant externe';
      default:
        return true;
    }
  }

  bool _matchesSearch(Map<String, dynamic> user, String query) {
    if (query.isEmpty) return true;

    final name = (user['name'] ?? '').toString().toLowerCase();
    final email = (user['email'] ?? '').toString().toLowerCase();

    return name.contains(query) || email.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];

            final allUsers = docs.map((doc) {
              final data = doc.data();
              return {
                ...data,
                '_id': doc.id,
              };
            }).toList();

            final total = allUsers.length;
            final admins = allUsers.where((u) => u['role'] == 'admin').length;
            final loges = allUsers.where((u) {
              final role = (u['role'] ?? '').toString();
              return role == 'boardingStudent' || role == 'Apprenant logé';
            }).length;
            final externes = allUsers.where((u) {
              final role = (u['role'] ?? '').toString();
              return role == 'externalStudent' || role == 'Apprenant externe';
            }).length;

            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: _buildStats(total, admins, loges, externes),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: _buildSearchAndFilters(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: _buildAddButton(),
                  ),
                ),
                ValueListenableBuilder<String>(
                  valueListenable: _searchNotifier,
                  builder: (context, searchQuery, _) {
                    return ValueListenableBuilder<String>(
                      valueListenable: _filterNotifier,
                      builder: (context, selectedFilter, _) {
                        final filteredUsers = allUsers.where((user) {
                          return _matchesSearch(user, searchQuery) &&
                              _matchesFilter(user, selectedFilter);
                        }).toList();

                        if (filteredUsers.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 42,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'No users found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Try another search or filter.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            0,
                            24,
                            MediaQuery.of(context).viewInsets.bottom + 24,
                          ),
                          sliver: SliverList.separated(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return _buildUserCard(context, user);
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB12CFF), Color(0xFF6F00D9)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Gestion des utilisateurs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gérer les comptes et les accès',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int total, int admins, int loges, int externes) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB12CFF), Color(0xFF6F00D9)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6F00D9).withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _miniStat(total.toString(), 'Total')),
          const SizedBox(width: 10),
          Expanded(child: _miniStat(admins.toString(), 'Administrateurs')),
          const SizedBox(width: 10),
          Expanded(child: _miniStat(loges.toString(), 'Logés')),
          const SizedBox(width: 10),
          Expanded(child: _miniStat(externes.toString(), 'Externes')),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<String>(
            valueListenable: _filterNotifier,
            builder: (context, selectedFilter, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('Tous', selectedFilter),
                    const SizedBox(width: 8),
                    _filterChip('Admin', selectedFilter),
                    const SizedBox(width: 8),
                    _filterChip('Logés', selectedFilter),
                    const SizedBox(width: 8),
                    _filterChip('Externes', selectedFilter),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String selectedFilter) {
    final selected = selectedFilter == label;

    return GestureDetector(
      onTap: () => _filterNotifier.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFB12CFF) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF4B5563),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter un utilisateur',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF9C1CFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    final String name = (user['name'] ?? '').toString();
    final String email = (user['email'] ?? '').toString();
    final String roleRaw = (user['role'] ?? '').toString();
    final dynamic createdAtRaw = user['createdAt'];
    final bool isActive =
        user['isActive'] is bool ? user['isActive'] as bool : true;

    final int empruntsCount = _extractLoanCount(user);
    final String createdAtText = _formatCreatedAt(createdAtRaw);

    String roleLabel;
    Color roleChipBg;
    Color accentColor;
    IconData roleIcon;

    if (roleRaw == 'admin') {
      roleLabel = 'Administrateur';
      roleChipBg = const Color(0xFFF0E2FF);
      accentColor = const Color(0xFF8B2CF5);
      roleIcon = Icons.shield_outlined;
    } else if (roleRaw == 'boardingStudent' || roleRaw == 'Apprenant logé') {
      roleLabel = 'Apprenant logé';
      roleChipBg = const Color(0xFFDCE9FF);
      accentColor = const Color(0xFF245BFF);
      roleIcon = Icons.person_outline_rounded;
    } else {
      roleLabel = 'Apprenant externe';
      roleChipBg = const Color(0xFFDDF6E5);
      accentColor = const Color(0xFF0E8A43);
      roleIcon = Icons.person_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: roleChipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              roleIcon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFDDF6E5)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isActive ? 'Actif' : 'Inactif',
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF0E8A43)
                              : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: roleChipBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '$empruntsCount ${empruntsCount > 1 ? 'emprunts' : 'emprunt'}',
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Membre depuis $createdAtText',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        text: 'Modifier',
                        icon: Icons.edit_outlined,
                        bg: const Color(0xFFEAF1FF),
                        fg: const Color(0xFF245BFF),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        text: 'Supprimer',
                        icon: Icons.delete_outline,
                        bg: const Color(0xFFFFEEEE),
                        fg: const Color(0xFFFF2B2B),
                        onTap: () {},
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

  int _extractLoanCount(Map<String, dynamic> user) {
    final possibleKeys = [
      'empruntsCount',
      'borrowCount',
      'loanCount',
      'emprunts',
    ];

    for (final key in possibleKeys) {
      final value = user[key];

      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is List) return value.length;
    }

    return 0;
  }

  String _formatCreatedAt(dynamic createdAtRaw) {
    if (createdAtRaw == null) return '--';

    DateTime? date;

    if (createdAtRaw is Timestamp) {
      date = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      date = createdAtRaw;
    } else if (createdAtRaw is String) {
      final parsed = DateTime.tryParse(createdAtRaw);
      if (parsed != null) {
        date = parsed;
      } else {
        return createdAtRaw;
      }
    }

    if (date == null) return '--';

    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
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
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}