// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(),
                  const SizedBox(height: 24),
                  _buildMainManagementSection(),
                  const SizedBox(height: 24),
                  _buildStatisticsSection(),
                  const SizedBox(height: 24),
                  _buildAlertsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Administrateur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gérez les documents, les emprunts, les réservations, les utilisateurs et les statistiques de la bibliothèque.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const [
        _StatCard(
          title: 'Documents',
          value: '128',
          subtitle: 'Catalogue total',
          icon: Icons.library_books_rounded,
        ),
        _StatCard(
          title: 'Emprunts actifs',
          value: '34',
          subtitle: 'En cours',
          icon: Icons.assignment_turned_in_rounded,
        ),
        _StatCard(
          title: 'Réservations',
          value: '12',
          subtitle: 'En attente',
          icon: Icons.bookmark_added_rounded,
        ),
        _StatCard(
          title: 'Retards',
          value: '6',
          subtitle: 'À suivre',
          icon: Icons.warning_amber_rounded,
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return _SectionCard(
      title: 'Actions rapides',
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: const [
          _ActionButton(
            label: 'Ajouter document',
            icon: Icons.add_box_rounded,
          ),
          _ActionButton(
            label: 'Gérer emprunts',
            icon: Icons.swap_horiz_rounded,
          ),
          _ActionButton(
            label: 'Voir réservations',
            icon: Icons.bookmark_rounded,
          ),
          _ActionButton(
            label: 'Utilisateurs',
            icon: Icons.people_alt_rounded,
          ),
          _ActionButton(
            label: 'Notifications',
            icon: Icons.notifications_active_rounded,
          ),
          _ActionButton(
            label: 'Statistiques',
            icon: Icons.bar_chart_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildMainManagementSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SectionCard(
            title: 'Gestion des documents',
            child: Column(
              children: const [
                _InfoTile(
                  icon: Icons.menu_book_rounded,
                  title: 'Catalogue complet',
                  subtitle:
                      'Livres, magazines, DVD et supports pédagogiques',
                ),
                SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.image_rounded,
                  title: 'Couvertures et stockage',
                  subtitle:
                      'Gestion des images des documents via Firebase Storage',
                ),
                SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.search_rounded,
                  title: 'Recherche et filtres',
                  subtitle:
                      'Recherche par mots-clés, catégories et disponibilité',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SectionCard(
            title: 'Gestion des emprunts',
            child: Column(
              children: const [
                _InfoTile(
                  icon: Icons.how_to_reg_rounded,
                  title: 'Validation des emprunts',
                  subtitle:
                      'Validation des emprunts en présentiel par le bibliothécaire',
                ),
                SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.history_rounded,
                  title: 'Suivi des retours',
                  subtitle:
                      'Suivi des dates, retards et historique utilisateur',
                ),
                SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.priority_high_rounded,
                  title: 'Réservations prioritaires',
                  subtitle:
                      'Gestion des réservations pour les apprenants logés',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SectionCard(
            title: 'Statistiques clés',
            child: Column(
              children: [
                _ChartPlaceholder(
                  title: 'Livres les plus empruntés',
                  value: 'Top 5',
                  icon: Icons.auto_graph_rounded,
                ),
                const SizedBox(height: 12),
                _ChartPlaceholder(
                  title: 'Documents par catégorie',
                  value: '6 catégories',
                  icon: Icons.pie_chart_rounded,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SectionCard(
            title: 'Suivi administratif',
            child: Column(
              children: [
                _ChartPlaceholder(
                  title: 'Retards',
                  value: '6 cas',
                  icon: Icons.warning_rounded,
                ),
                const SizedBox(height: 12),
                _ChartPlaceholder(
                  title: 'Activité utilisateurs',
                  value: '48 actions',
                  icon: Icons.trending_up_rounded,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsSection() {
    return _SectionCard(
      title: 'Notifications et alertes',
      child: Column(
        children: const [
          _AlertTile(
            title: '3 documents arrivent à échéance aujourd’hui',
            subtitle: 'Prévoir l’envoi de rappels automatiques',
            icon: Icons.notifications_active,
          ),
          SizedBox(height: 12),
          _AlertTile(
            title: '2 réservations en attente de traitement',
            subtitle: 'Vérifier la disponibilité et notifier les utilisateurs',
            icon: Icons.pending_actions_rounded,
          ),
          SizedBox(height: 12),
          _AlertTile(
            title: '1 document signalé en retard',
            subtitle: 'Suivi nécessaire par le bibliothécaire',
            icon: Icons.report_problem_rounded,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ActionButton({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ChartPlaceholder({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF7FAFF),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _AlertTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}