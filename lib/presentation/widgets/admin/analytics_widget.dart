import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsWidget extends StatelessWidget {
  const AnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data?.docs ?? [];
        final analytics = _calculateAnalytics(users);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: _AnalyticsCard(
                      title: 'Total Users',
                      value: analytics['totalUsers'].toString(),
                      color: const Color(0xFF1976D2), // Blue
                      icon: Icons.people_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _AnalyticsCard(
                      title: 'Admin Users',
                      value: analytics['adminUsers'].toString(),
                      color: const Color(0xFF7B1FA2), // Purple
                      icon: Icons.admin_panel_settings_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _AnalyticsCard(
                      title: 'Free Users',
                      value: analytics['freeUsers'].toString(),
                      color: const Color(0xFFF57C00), // Orange
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _AnalyticsCard(
                      title: 'Pro Users',
                      value: analytics['proUsers'].toString(),
                      color: const Color(0xFF2E7D32), // Green
                      icon: Icons.star_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Charts Section
              Text(
                'Analytics Overview',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              const SizedBox(height: 16),
              _ChartCard(title: 'User Role Distribution', analytics: analytics),
              const SizedBox(height: 16),
              _ChartCard(
                title: 'Subscription Distribution',
                analytics: analytics,
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _calculateAnalytics(List<QueryDocumentSnapshot> users) {
    int totalUsers = users.length;
    int adminUsers = 0;
    int freeUsers = 0;
    int proUsers = 0;

    for (final doc in users) {
      final data = doc.data() as Map<String, dynamic>;

      // Count roles
      if ((data['role'] ?? 'user') == 'admin') {
        adminUsers++;
      }

      // Count subscriptions
      if ((data['subscriptionTier'] ?? 'free') == 'free') {
        freeUsers++;
      } else {
        proUsers++;
      }
    }

    return {
      'totalUsers': totalUsers,
      'adminUsers': adminUsers,
      'freeUsers': freeUsers,
      'proUsers': proUsers,
    };
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> analytics;

  const _ChartCard({required this.title, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildChart(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (title.contains('Role')) {
      return _buildRoleChart();
    } else {
      return _buildSubscriptionChart();
    }
  }

  Widget _buildRoleChart() {
    final totalUsers = analytics['totalUsers'] as int;
    final adminUsers = analytics['adminUsers'] as int;
    final regularUsers = totalUsers - adminUsers;

    if (totalUsers == 0) {
      return const Center(child: Text('No data available'));
    }

    final adminPercentage = (adminUsers / totalUsers) * 100;
    final userPercentage = (regularUsers / totalUsers) * 100;

    return Column(
      children: [
        _buildChartBar(
          'Admin Users',
          adminUsers,
          adminPercentage,
          const Color(0xFF7B1FA2), // Purple
        ),
        const SizedBox(height: 12),
        _buildChartBar(
          'Regular Users',
          regularUsers,
          userPercentage,
          const Color(0xFF1976D2), // Blue
        ),
      ],
    );
  }

  Widget _buildSubscriptionChart() {
    final totalUsers = analytics['totalUsers'] as int;
    final freeUsers = analytics['freeUsers'] as int;
    final proUsers = analytics['proUsers'] as int;

    if (totalUsers == 0) {
      return const Center(child: Text('No data available'));
    }

    final freePercentage = (freeUsers / totalUsers) * 100;
    final proPercentage = (proUsers / totalUsers) * 100;

    return Column(
      children: [
        _buildChartBar(
          'Free Users',
          freeUsers,
          freePercentage,
          const Color(0xFFF57C00), // Orange
        ),
        const SizedBox(height: 12),
        _buildChartBar(
          'Pro Users',
          proUsers,
          proPercentage,
          const Color(0xFF2E7D32), // Green
        ),
      ],
    );
  }

  Widget _buildChartBar(
    String label,
    int value,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '$value (${percentage.toStringAsFixed(1)}%)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
