import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class ParallaxHeroSection extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;

  const ParallaxHeroSection({
    super.key,
    required this.scrollController,
    required this.child,
  });

  @override
  State<ParallaxHeroSection> createState() => _ParallaxHeroSectionState();
}

class _ParallaxHeroSectionState extends State<ParallaxHeroSection> {
  double _offset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _offset = widget.scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      child: Stack(
        children: [
          // Background with parallax effect
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, _offset * 0.5), // Parallax effect
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.primary.withValues(alpha: 0.05),
                          ]
                        : [
                            AppColors.primary.withValues(alpha: 0.05),
                            AppColors.primary.withValues(alpha: 0.02),
                          ],
                  ),
                ),
                child: CustomPaint(painter: _ParallaxPainter(isDarkMode)),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, _offset * 0.3), // Slower parallax for content
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParallaxPainter extends CustomPainter {
  final bool isDarkMode;

  _ParallaxPainter(this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw some decorative shapes
    final path = Path();

    // Circle 1
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      size.width * 0.15,
      paint..color = AppColors.primary.withValues(alpha: 0.05),
    );

    // Circle 2
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      size.width * 0.1,
      paint..color = AppColors.primary.withValues(alpha: 0.08),
    );

    // Triangle
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.2, size.height * 0.9);
    path.close();
    canvas.drawPath(
      path,
      paint..color = AppColors.primary.withValues(alpha: 0.06),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeroWelcomeContent extends StatelessWidget {
  final String userName;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const HeroWelcomeContent({
    super.key,
    required this.userName,
    this.onSearchTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Welcome text
          Text(
            'Chào mừng trở lại!',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy khám phá những quiz thú vị',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),

          const Spacer(),

          // Search and filter buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.search,
                  label: 'Tìm kiếm',
                  onTap: onSearchTap,
                ),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                context,
                icon: Icons.tune,
                label: 'Lọc',
                onTap: onFilterTap,
                isCompact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isCompact = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            if (!isCompact) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
