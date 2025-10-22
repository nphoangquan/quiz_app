import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/subscription_tier.dart';

class SubscriptionManagementWidget extends StatelessWidget {
  const SubscriptionManagementWidget({super.key});

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
        final freeUsers = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['subscriptionTier'] ?? 'free') == 'free';
        }).toList();

        final proUsers = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['subscriptionTier'] ?? 'free') == 'pro';
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Free Users',
                      value: freeUsers.length.toString(),
                      color: const Color(0xFFF57C00), // Orange
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pro Users',
                      value: proUsers.length.toString(),
                      color: const Color(0xFF2E7D32), // Green
                      icon: Icons.star_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Free users section
              Text(
                'Free Users (${freeUsers.length})',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              const SizedBox(height: 16),
              ...freeUsers.map(
                (doc) =>
                    _SubscriptionCard(doc: doc, tier: SubscriptionTier.free),
              ),

              const SizedBox(height: 32),

              // Pro users section
              Text(
                'Pro Users (${proUsers.length})',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              const SizedBox(height: 16),
              ...proUsers.map(
                (doc) =>
                    _SubscriptionCard(doc: doc, tier: SubscriptionTier.pro),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
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
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 32,
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
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final SubscriptionTier tier;

  const _SubscriptionCard({required this.doc, required this.tier});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tier == SubscriptionTier.pro
              ? const Color(0xFF2E7D32).withValues(alpha: 0.2)
              : const Color(0xFFF57C00).withValues(alpha: 0.2),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: tier == SubscriptionTier.pro
                ? const Color(0xFFE8F5E8)
                : const Color(0xFFFFF3E0),
            child: Icon(
              tier == SubscriptionTier.pro ? Icons.star : Icons.person,
              color: tier == SubscriptionTier.pro
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFF57C00),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'Unknown User',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['email'] ?? 'No email',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showSubscriptionManagement(context, doc.id, tier),
            style: ElevatedButton.styleFrom(
              backgroundColor: tier == SubscriptionTier.pro
                  ? const Color(0xFFD32F2F) // Red for downgrade
                  : const Color(0xFF2E7D32), // Green for upgrade
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              tier == SubscriptionTier.pro ? 'Downgrade' : 'Upgrade',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionManagement(
    BuildContext context,
    String userId,
    SubscriptionTier currentTier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Subscription',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Current plan: ${currentTier.displayName}\n\nDo you want to change this user\'s subscription?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _changeUserSubscription(context, userId, currentTier);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: currentTier == SubscriptionTier.pro
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFF57C00),
              foregroundColor: Colors.white,
            ),
            child: Text(
              currentTier == SubscriptionTier.pro
                  ? 'Downgrade to Free'
                  : 'Upgrade to Pro',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeUserSubscription(
    BuildContext context,
    String userId,
    SubscriptionTier currentTier,
  ) async {
    try {
      final newTier = currentTier == SubscriptionTier.pro
          ? SubscriptionTier.free
          : SubscriptionTier.pro;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'subscriptionTier': newTier.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ User subscription changed to ${newTier.displayName}',
            ),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error changing subscription: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }
}
