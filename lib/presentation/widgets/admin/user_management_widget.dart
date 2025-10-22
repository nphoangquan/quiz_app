import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/user_role.dart';
import '../../../domain/entities/subscription_tier.dart';
import '../../providers/auth_provider.dart';

class UserManagementWidget extends StatelessWidget {
  const UserManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;
    final currentUserId = currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading users: ${snapshot.error}',
                  style: GoogleFonts.inter(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final users = snapshot.data?.docs ?? [];
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userData = userDoc.data() as Map<String, dynamic>;
            return _UserCard(
              userId: userDoc.id,
              userData: userData,
              currentUserId: currentUserId,
            );
          },
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final String? currentUserId;

  const _UserCard({
    required this.userId,
    required this.userData,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final role = UserRoleExtension.fromString(userData['role'] ?? 'user');
    final subscriptionTier = SubscriptionTierExtension.fromString(
      userData['subscriptionTier'] ?? 'free',
    );
    final stats = userData['stats'] as Map<String, dynamic>? ?? {};
    final createdAt = (userData['createdAt'] as Timestamp?)?.toDate();
    final isCurrentUser = userId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and role
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: role.isAdmin
                      ? const Color(0xFFE3F2FD) // Light blue for admin
                      : const Color(0xFFF3E5F5), // Light purple for user
                  child: Icon(
                    role.isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: role.isAdmin
                        ? const Color(0xFF1976D2) // Blue for admin
                        : const Color(0xFF7B1FA2), // Purple for user
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              userData['name'] ?? 'Unknown User',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(
                                    0xFF1976D2,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'You',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1976D2),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData['email'] ?? 'No email',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildRoleChip(role),
                const SizedBox(width: 8),
                _buildSubscriptionChip(subscriptionTier),
              ],
            ),
            const SizedBox(height: 16),

            // Stats row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Quizzes',
                      '${stats['quizzesCreated'] ?? 0}',
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem('Level', '${stats['level'] ?? 1}'),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Score',
                      '${stats['totalScore'] ?? 0}',
                    ),
                  ),
                  if (createdAt != null)
                    Expanded(
                      child: Text(
                        'Joined: ${_formatDate(createdAt)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showUserDetails(context, userId, userData),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isCurrentUser && role.isAdmin
                        ? null // Disable for current admin user
                        : () => _showRoleManagement(
                            context,
                            userId,
                            role,
                            isCurrentUser,
                          ),
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Role'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: role.isAdmin
                          ? const Color(0xFF1976D2)
                          : const Color(0xFF7B1FA2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSubscriptionManagement(
                      context,
                      userId,
                      subscriptionTier,
                    ),
                    icon: const Icon(Icons.star, size: 18),
                    label: const Text('Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subscriptionTier == SubscriptionTier.pro
                          ? const Color(0xFF2E7D32) // Green for Pro
                          : const Color(0xFFF57C00), // Orange for Free
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(UserRole role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: role.isAdmin ? const Color(0xFFE3F2FD) : const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: role.isAdmin
              ? const Color(0xFF1976D2).withValues(alpha: 0.3)
              : const Color(0xFF7B1FA2).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        role.displayName,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: role.isAdmin
              ? const Color(0xFF1976D2)
              : const Color(0xFF7B1FA2),
        ),
      ),
    );
  }

  Widget _buildSubscriptionChip(SubscriptionTier tier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tier == SubscriptionTier.pro
            ? const Color(0xFFE8F5E8) // Light green for Pro
            : const Color(0xFFFFF3E0), // Light orange for Free
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tier == SubscriptionTier.pro
              ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
              : const Color(0xFFF57C00).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        tier.displayName,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: tier == SubscriptionTier.pro
              ? const Color(0xFF2E7D32)
              : const Color(0xFFF57C00),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUserDetails(
    BuildContext context,
    String userId,
    Map<String, dynamic> userData,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'User Details',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', userData['name'] ?? 'Unknown'),
              _buildDetailRow('Email', userData['email'] ?? 'No email'),
              _buildDetailRow(
                'Role',
                UserRoleExtension.fromString(
                  userData['role'] ?? 'user',
                ).displayName,
              ),
              _buildDetailRow(
                'Subscription',
                SubscriptionTierExtension.fromString(
                  userData['subscriptionTier'] ?? 'free',
                ).displayName,
              ),
              _buildDetailRow(
                'Created',
                userData['createdAt'] != null
                    ? _formatDate((userData['createdAt'] as Timestamp).toDate())
                    : 'Unknown',
              ),
              const SizedBox(height: 12),
              Text(
                'Statistics',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ..._buildStatsDetails(
                userData['stats'] as Map<String, dynamic>? ?? {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.inter())),
        ],
      ),
    );
  }

  List<Widget> _buildStatsDetails(Map<String, dynamic> stats) {
    return [
      _buildDetailRow('Level', '${stats['level'] ?? 1}'),
      _buildDetailRow('Experience', '${stats['experience'] ?? 0}'),
      _buildDetailRow('Quizzes Created', '${stats['quizzesCreated'] ?? 0}'),
      _buildDetailRow('Quizzes Taken', '${stats['quizzesTaken'] ?? 0}'),
      _buildDetailRow('Total Score', '${stats['totalScore'] ?? 0}'),
    ];
  }

  void _showRoleManagement(
    BuildContext context,
    String userId,
    UserRole currentRole,
    bool isCurrentUser,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change User Role',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current role: ${currentRole.displayName}',
              style: GoogleFonts.inter(),
            ),
            if (isCurrentUser) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF57C00).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: const Color(0xFFF57C00),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You cannot change your own role to prevent locking yourself out.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFF57C00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Do you want to change this user\'s role?',
                style: GoogleFonts.inter(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (!isCurrentUser)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _changeUserRole(context, userId, currentRole);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentRole.isAdmin
                    ? const Color(0xFF7B1FA2)
                    : const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: Text(currentRole.isAdmin ? 'Make User' : 'Make Admin'),
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

  Future<void> _changeUserRole(
    BuildContext context,
    String userId,
    UserRole currentRole,
  ) async {
    try {
      final newRole = currentRole.isAdmin ? UserRole.user : UserRole.admin;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': newRole.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ User role changed to ${newRole.displayName}'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error changing role: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
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
