import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/subscription_tier.dart';
import '../../providers/auth_provider.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Nâng cấp lên Pro',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(context),

              const SizedBox(height: 32),

              // Current Plan Info
              _buildCurrentPlanSection(context),

              const SizedBox(height: 32),

              // Plans Comparison
              _buildPlansSection(context),

              const SizedBox(height: 32),

              // FAQ Section
              _buildFAQSection(context),

              const SizedBox(height: 32),

              // Footer
              _buildFooterSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.star, size: 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Nâng cấp lên Pro',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mở khóa tất cả tính năng cao cấp',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isPro = authProvider.isPro;
        final user = authProvider.user;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isPro ? Icons.check_circle : Icons.info_outline,
                    color: isPro ? Colors.green : Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isPro ? 'Gói hiện tại: Pro' : 'Gói hiện tại: Free',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!isPro && user != null) ...[
                Text(
                  'Bạn đã sử dụng ${user.stats.quizzesCreated}/${SubscriptionTier.free.quizLimit} quizzes',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      user.stats.quizzesCreated /
                      SubscriptionTier.free.quizLimit,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI generations hôm nay: ${user.usageLimits.aiGenerationsToday}/${SubscriptionTier.free.aiGenerationDailyLimit}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ] else if (isPro) ...[
                Text(
                  'Bạn đang sử dụng gói Pro với đầy đủ tính năng!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlansSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'So sánh gói',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildPlanCard(context, SubscriptionTier.free),
        const SizedBox(height: 16),
        _buildPlanCard(context, SubscriptionTier.pro),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionTier tier) {
    final isPro = tier.isPro;
    final authProvider = context.watch<AuthProvider>();
    final isCurrentPlan =
        (isPro && authProvider.isPro) || (!isPro && authProvider.isFree);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPro ? AppColors.primary : Colors.grey[300]!,
          width: isPro ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPro
                ? AppColors.primary.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isPro ? AppColors.primary : Colors.grey[100],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      isPro ? Icons.star : Icons.person,
                      color: isPro ? Colors.white : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tier.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isPro ? Colors.white : Colors.black,
                      ),
                    ),
                    if (isPro) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'POPULAR',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tier.priceMonthly,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isPro ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '/tháng',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isPro ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Features
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: tier.features
                  .map((feature) => _buildFeatureItem(feature))
                  .toList(),
            ),
          ),

          // Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: isCurrentPlan
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        'Gói hiện tại',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: isPro
                          ? () => _navigateToPayment(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPro
                            ? AppColors.primary
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isPro ? 'Nâng cấp ngay' : 'Miễn phí',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu hỏi thường gặp',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildFAQItem(
          'Tôi có thể hủy subscription bất cứ lúc nào không?',
          'Có, bạn có thể hủy subscription bất cứ lúc nào. Tài khoản sẽ được chuyển về gói Free sau khi hết hạn.',
        ),
        _buildFAQItem(
          'Tôi có thể dùng thử Pro không?',
          'Hiện tại chúng tôi chưa có chế độ dùng thử. Bạn có thể nâng cấp và hủy trong vòng 7 ngày để được hoàn tiền.',
        ),
        _buildFAQItem(
          'Dữ liệu của tôi có được bảo vệ không?',
          'Có, tất cả dữ liệu của bạn được mã hóa và bảo vệ an toàn. Chúng tôi không chia sẻ thông tin cá nhân với bên thứ ba.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.security, color: Colors.grey[600], size: 32),
          const SizedBox(height: 12),
          Text(
            'Thanh toán an toàn',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Chúng tôi sử dụng Stripe để xử lý thanh toán một cách an toàn và bảo mật.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToPayment(BuildContext context) {
    Navigator.pushNamed(context, '/payment');
  }
}
