import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/google_sign_in_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // App Logo and Title
              _buildHeader(),

              const SizedBox(height: 60),

              // Welcome Text
              _buildWelcomeText(),

              const SizedBox(height: 40),

              // Google Sign-In Button
              _buildGoogleSignInButton(context),

              const Spacer(),

              // Terms and Privacy
              _buildTermsText(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.quiz, size: 50, color: AppColors.white),
        ),

        const SizedBox(height: 24),

        // App Name
        Text(
          AppConstants.appName,
          style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        // Tagline
        Text(
          'Learn • Practice • Master',
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Chào mừng bạn!',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Đăng nhập để bắt đầu hành trình học tập\ncủa bạn với QuizApp',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.grey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            // Google Sign-In Button
            GoogleSignInButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () => authProvider.signInWithGoogle(),
              isLoading: authProvider.isLoading,
            ),

            const SizedBox(height: 16),

            // Error Message
            if (authProvider.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authProvider.errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => authProvider.clearError(),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTermsText() {
    return Text(
      'Bằng cách đăng nhập, bạn đồng ý với\nĐiều khoản sử dụng và Chính sách bảo mật',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 12,
        color: AppColors.grey,
        height: 1.4,
      ),
    );
  }
}
