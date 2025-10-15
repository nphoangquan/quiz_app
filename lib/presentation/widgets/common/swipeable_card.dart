import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final String? leftActionText;
  final String? rightActionText;
  final Color? leftActionColor;
  final Color? rightActionColor;

  const SwipeableCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftActionText,
    this.rightActionText,
    this.leftActionColor,
    this.rightActionColor,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  double _dragOffset = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    const threshold = 100.0;

    if (_dragOffset > threshold && widget.onSwipeRight != null) {
      _animateAndExecute(widget.onSwipeRight!);
    } else if (_dragOffset < -threshold && widget.onSwipeLeft != null) {
      _animateAndExecute(widget.onSwipeLeft!);
    } else {
      _resetPosition();
    }
  }

  void _animateAndExecute(VoidCallback action) {
    _animationController.forward().then((_) {
      action();
    });
  }

  void _resetPosition() {
    setState(() {
      _dragOffset = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_dragOffset, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                // Background actions
                if (_isDragging) _buildBackgroundActions(),

                // Main card
                GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: widget.child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundActions() {
    return Positioned.fill(
      child: Row(
        children: [
          // Left action
          if (widget.onSwipeLeft != null)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.leftActionColor ?? AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.white, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        widget.leftActionText ?? 'Xóa',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Right action
          if (widget.onSwipeRight != null)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.rightActionColor ?? AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        widget.rightActionText ?? 'Thích',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
