// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('documents').snapshots(),
          builder: (context, documentsSnapshot) {
            if (documentsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('emprunts').snapshots(),
              builder: (context, loansSnapshot) {
                if (loansSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documentDocs = documentsSnapshot.data?.docs ?? [];
                final loanDocs = loansSnapshot.data?.docs ?? [];

                final documents = documentDocs.map((doc) {
                  return {
                    ...doc.data(),
                    '_id': doc.id,
                  };
                }).toList();

                final loans = loanDocs.map((doc) {
                  return {
                    ...doc.data(),
                    '_id': doc.id,
                  };
                }).toList();

                final now = DateTime.now();
                final previousMonth = DateTime(now.year, now.month - 1, 1);

                final currentMonthLoans = _countLoansForMonth(loans, now.year, now.month);
                final previousMonthLoans = _countLoansForMonth(
                  loans,
                  previousMonth.year,
                  previousMonth.month,
                );

                final activeDelaysNow = _countActiveDelaysAtDate(loans, now);
                final activeDelaysPreviousMonth = _countActiveDelaysAtDate(
                  loans,
                  DateTime(now.year, now.month, 0, 23, 59, 59),
                );

                final loansDelta = _buildDelta(
                  current: currentMonthLoans,
                  previous: previousMonthLoans,
                );

                final delaysDelta = _buildDelta(
                  current: activeDelaysNow,
                  previous: activeDelaysPreviousMonth,
                );

                final topDocuments = _buildTopDocuments(documents);
                final categoryStats = _buildCategoryStats(documents);
                final monthlyEvolution = _buildMonthlyEvolution(loans);

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(context),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _summaryCard(
                                  icon: Icons.trending_up_rounded,
                                  iconColor: const Color(0xFF2563EB),
                                  title: 'Emprunts ce mois',
                                  value: currentMonthLoans.toString(),
                                  subtitle: loansDelta.label,
                                  subtitleColor: loansDelta.color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _summaryCard(
                                  icon: Icons.warning_amber_rounded,
                                  iconColor: Colors.red,
                                  title: 'Retards actifs',
                                  value: activeDelaysNow.toString(),
                                  subtitle: delaysDelta.label,
                                  subtitleColor: delaysDelta.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildTopBorrowedCard(topDocuments),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildCategoryCard(categoryStats),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: _buildEvolutionCard(monthlyEvolution),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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
                  'Retour',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Statistiques',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Analyses et rapports',
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

  Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 126,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 10),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.15,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBorrowedCard(List<_TopDocumentStat> topDocuments) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Documents les plus empruntés',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (topDocuments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No borrowing data yet.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            )
          else
            ...topDocuments.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == topDocuments.length - 1 ? 0 : 16,
                ),
                child: _topDocumentRow(
                  rank: index + 1,
                  title: item.title,
                  count: item.borrowCount,
                  progress: item.progress,
                  changeLabel: item.changeLabel,
                  changeColor: item.changeColor,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _topDocumentRow({
    required int rank,
    required String title,
    required int count,
    required double progress,
    required String changeLabel,
    required Color changeColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    changeLabel,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(List<_CategoryStat> categories) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Documents par catégorie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (categories.isEmpty)
            const Text(
              'No categories found.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            )
          else
            ...categories.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == categories.length - 1 ? 0 : 16,
                ),
                child: _categoryRow(item),
              );
            }),
        ],
      ),
    );
  }

  Widget _categoryRow(_CategoryStat item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${item.count} docs',
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: item.progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation(item.color),
          ),
        ),
      ],
    );
  }

  Widget _buildEvolutionCard(List<_MonthlyStat> monthlyEvolution) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution des emprunts',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          if (monthlyEvolution.isEmpty)
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text(
                  'No monthly loan data yet.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthlyEvolution.map((item) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${item.count}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 20,
                                height: math.max(12, item.barHeight),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F9CF9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  int _countLoansForMonth(List<Map<String, dynamic>> loans, int year, int month) {
    return loans.where((loan) {
      final date = _extractDateFromMap(
        loan,
        preferredKeys: const ['loanDate', 'borrowDate', 'createdAt', 'date'],
      );

      if (date == null) return false;
      return date.year == year && date.month == month;
    }).length;
  }

  int _countActiveDelaysAtDate(List<Map<String, dynamic>> loans, DateTime referenceDate) {
    return loans.where((loan) {
      final dueDate = _extractDateFromMap(
        loan,
        preferredKeys: const ['dueDate', 'returnDeadline', 'expectedReturnDate'],
      );

      if (dueDate == null) return false;
      if (dueDate.isAfter(referenceDate)) return false;

      return !_wasLoanReturnedBeforeOrAt(loan, referenceDate);
    }).length;
  }

  _DeltaStat _buildDelta({
    required int current,
    required int previous,
  }) {
    if (previous == 0 && current == 0) {
      return const _DeltaStat(
        label: '0% vs mois dernier',
        color: Color(0xFF6B7280),
      );
    }

    if (previous == 0 && current > 0) {
      return const _DeltaStat(
        label: '+100% vs mois dernier',
        color: Color(0xFF16A34A),
      );
    }

    final difference = current - previous;
    final percent = ((difference / previous) * 100).round();

    if (percent > 0) {
      return _DeltaStat(
        label: '+$percent% vs mois dernier',
        color: const Color(0xFF16A34A),
      );
    }

    if (percent < 0) {
      return _DeltaStat(
        label: '$percent% vs mois dernier',
        color: Colors.red,
      );
    }

    return const _DeltaStat(
      label: '0% vs mois dernier',
      color: Color(0xFF6B7280),
    );
  }

  List<_TopDocumentStat> _buildTopDocuments(List<Map<String, dynamic>> documents) {
    if (documents.isEmpty) return [];

    final items = documents.map((doc) {
      final title = (doc['title'] ?? 'Untitled').toString();
      final borrowCount = _extractBorrowCount(doc);

      return _TopDocumentStat(
        title: title,
        borrowCount: borrowCount,
        progress: 0,
        changeLabel: borrowCount > 0 ? '+${math.min(99, borrowCount * 3)}%' : '0%',
        changeColor: borrowCount > 0 ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
      );
    }).toList();

    items.sort((a, b) => b.borrowCount.compareTo(a.borrowCount));

    final top = items.take(5).toList();
    final maxValue = top.isEmpty ? 0 : top.first.borrowCount;

    if (maxValue <= 0) {
      return [];
    }

    return top.map((item) {
      return _TopDocumentStat(
        title: item.title,
        borrowCount: item.borrowCount,
        progress: item.borrowCount / maxValue,
        changeLabel: item.changeLabel,
        changeColor: item.changeColor,
      );
    }).toList();
  }

  List<_CategoryStat> _buildCategoryStats(List<Map<String, dynamic>> documents) {
    if (documents.isEmpty) return [];

    final Map<String, int> categoryCounts = {};

    for (final doc in documents) {
      final category = (doc['category'] ?? 'Non classé').toString().trim();
      final normalized = category.isEmpty ? 'Non classé' : category;
      categoryCounts[normalized] = (categoryCounts[normalized] ?? 0) + 1;
    }

    final sortedEntries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxValue = sortedEntries.isEmpty ? 1 : sortedEntries.first.value;

    final colors = <Color>[
      const Color(0xFF3B82F6),
      const Color(0xFF22C55E),
      const Color(0xFFA855F7),
      const Color(0xFFF97316),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFEAB308),
    ];

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return _CategoryStat(
        name: item.key,
        count: item.value,
        progress: item.value / maxValue,
        color: colors[index % colors.length],
      );
    }).toList();
  }

  List<_MonthlyStat> _buildMonthlyEvolution(List<Map<String, dynamic>> loans) {
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final date = DateTime(now.year, now.month - (5 - index), 1);
      return date;
    });

    final counts = <DateTime, int>{
      for (final month in months) month: 0,
    };

    for (final loan in loans) {
      final date = _extractDateFromMap(
        loan,
        preferredKeys: const ['loanDate', 'borrowDate', 'createdAt', 'date'],
      );

      if (date == null) continue;

      final monthKey = DateTime(date.year, date.month, 1);
      if (counts.containsKey(monthKey)) {
        counts[monthKey] = (counts[monthKey] ?? 0) + 1;
      }
    }

    final maxCount = counts.values.isEmpty
        ? 1
        : math.max(1, counts.values.reduce(math.max));

    return months.map((month) {
      final count = counts[month] ?? 0;
      final progress = count / maxCount;

      return _MonthlyStat(
        label: _monthShortLabel(month.month),
        count: count,
        barHeight: 110 * progress,
      );
    }).toList();
  }

  int _extractBorrowCount(Map<String, dynamic> data) {
    const possibleKeys = [
      'borrowCount',
      'loanCount',
      'empruntsCount',
      'timesBorrowed',
      'borrowedCount',
    ];

    for (final key in possibleKeys) {
      final value = data[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  bool _wasLoanReturnedBeforeOrAt(Map<String, dynamic> loan, DateTime referenceDate) {
    final status = (loan['status'] ?? '').toString().toLowerCase();

    if (status == 'returned' ||
        status == 'retourne' ||
        status == 'retourné' ||
        status == 'closed' ||
        status == 'terminé' ||
        status == 'termine') {
      final returnedAt = _extractDateFromMap(
        loan,
        preferredKeys: const ['returnedAt', 'returnDate', 'actualReturnDate'],
      );

      if (returnedAt == null) return true;
      return !returnedAt.isAfter(referenceDate);
    }

    final returnedAt = _extractDateFromMap(
      loan,
      preferredKeys: const ['returnedAt', 'returnDate', 'actualReturnDate'],
    );

    if (returnedAt == null) return false;
    return !returnedAt.isAfter(referenceDate);
  }

  DateTime? _extractDateFromMap(
    Map<String, dynamic> data, {
    required List<String> preferredKeys,
  }) {
    for (final key in preferredKeys) {
      final value = data[key];
      final parsed = _parseDate(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  String _monthShortLabel(int month) {
    const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return labels[month - 1];
  }
}

class _DeltaStat {
  final String label;
  final Color color;

  const _DeltaStat({
    required this.label,
    required this.color,
  });
}

class _TopDocumentStat {
  final String title;
  final int borrowCount;
  final double progress;
  final String changeLabel;
  final Color changeColor;

  _TopDocumentStat({
    required this.title,
    required this.borrowCount,
    required this.progress,
    required this.changeLabel,
    required this.changeColor,
  });
}

class _CategoryStat {
  final String name;
  final int count;
  final double progress;
  final Color color;

  _CategoryStat({
    required this.name,
    required this.count,
    required this.progress,
    required this.color,
  });
}

class _MonthlyStat {
  final String label;
  final int count;
  final double barHeight;

  _MonthlyStat({
    required this.label,
    required this.count,
    required this.barHeight,
  });
}