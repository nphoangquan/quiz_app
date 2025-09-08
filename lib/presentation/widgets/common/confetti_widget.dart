import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final int particleCount;
  final Duration duration;

  const ConfettiWidget({
    super.key,
    this.particleCount = 50,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _initializeParticles();
    _animationController.forward();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      return ConfettiParticle(
        x: random.nextDouble() * 400 - 200, // Random x position
        y: -random.nextDouble() * 100 - 50, // Start above screen
        velocityX:
            (random.nextDouble() - 0.5) * 100, // Random horizontal velocity
        velocityY: random.nextDouble() * 200 + 100, // Downward velocity
        color: _getRandomColor(),
        size: random.nextDouble() * 8 + 4, // Random size between 4-12
        rotation: random.nextDouble() * 2 * math.pi, // Random initial rotation
        rotationSpeed: (random.nextDouble() - 0.5) * 4, // Random rotation speed
        shape:
            ConfettiShape.values[random.nextInt(ConfettiShape.values.length)],
      );
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            animationValue: _animationController.value,
          ),
          size: const Size(400, 400),
        );
      },
    );
  }
}

enum ConfettiShape { circle, square, triangle, star }

class ConfettiParticle {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final ConfettiShape shape;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double animationValue;
  final double gravity = 200; // Gravity acceleration

  ConfettiPainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1 - animationValue * 0.7)
        ..style = PaintingStyle.fill;

      // Calculate current position based on physics
      final currentX = particle.x + particle.velocityX * animationValue;
      final currentY =
          particle.y +
          particle.velocityY * animationValue +
          0.5 * gravity * animationValue * animationValue;

      // Skip if particle is out of bounds
      if (currentY > size.height + 50) continue;

      // Calculate current rotation
      final currentRotation =
          particle.rotation +
          particle.rotationSpeed * animationValue * 2 * math.pi;

      // Save canvas state
      canvas.save();

      // Translate to particle position
      canvas.translate(size.width / 2 + currentX, currentY);

      // Rotate
      canvas.rotate(currentRotation);

      // Draw particle based on shape
      switch (particle.shape) {
        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;

        case ConfettiShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;

        case ConfettiShape.triangle:
          _drawTriangle(canvas, paint, particle.size);
          break;

        case ConfettiShape.star:
          _drawStar(canvas, paint, particle.size);
          break;
      }

      // Restore canvas state
      canvas.restore();
    }
  }

  void _drawTriangle(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final halfSize = size / 2;

    path.moveTo(0, -halfSize); // Top point
    path.lineTo(-halfSize, halfSize); // Bottom left
    path.lineTo(halfSize, halfSize); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi) / 5;
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final x = radius * math.cos(angle - math.pi / 2);
      final y = radius * math.sin(angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
