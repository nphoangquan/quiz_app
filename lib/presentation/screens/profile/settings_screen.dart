import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/auth_wrapper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Cài đặt',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Section
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;
                  if (user == null) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : 'U',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Settings Sections
              Text(
                'Giao diện',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Theme Setting
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildSettingItem(
                    icon: Icons.palette_outlined,
                    title: 'Chế độ tối',
                    subtitle: 'Bật/tắt giao diện tối',
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) => themeProvider.toggleTheme(),
                      activeColor: AppColors.primary,
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Account Section
              Text(
                'Tài khoản',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Sign Out
              _buildSettingItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                subtitle: 'Thoát khỏi tài khoản hiện tại',
                onTap: _showSignOutDialog,
                iconColor: Colors.orange,
              ),

              const SizedBox(height: 8),

              // Delete Account
              _buildSettingItem(
                icon: Icons.delete_forever,
                title: 'Xóa tài khoản',
                subtitle: 'Xóa vĩnh viễn tài khoản và dữ liệu',
                onTap: _showDeleteAccountDialog,
                iconColor: AppColors.error,
                isLoading: _isDeleting,
              ),

              const Spacer(),

              // App Info
              Center(
                child: Column(
                  children: [
                    Text(
                      'Quiz App',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phiên bản 1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
    bool isLoading = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        onTap: isLoading ? null : onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey),
        ),
        trailing: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : trailing ??
                  const Icon(Icons.chevron_right, color: AppColors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Text(
                'Đăng xuất',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: GoogleFonts.inter(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Đăng xuất',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: AppColors.error, size: 28),
              const SizedBox(width: 12),
              Text(
                'Xóa tài khoản',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn có chắc chắn muốn xóa tài khoản không?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hành động này sẽ:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildWarningItem('• Xóa vĩnh viễn tất cả quiz bạn đã tạo'),
              _buildWarningItem('• Xóa lịch sử làm quiz của bạn'),
              _buildWarningItem('• Xóa thông tin tài khoản'),
              _buildWarningItem('• Không thể khôi phục được'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hành động này không thể hoàn tác!',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: GoogleFonts.inter(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Xóa tài khoản',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.error),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();

      if (mounted) {
        // Navigate to auth wrapper and clear all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi đăng xuất: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.deleteAccount();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tài khoản đã được xóa thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to auth wrapper and clear all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi xóa tài khoản: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}
