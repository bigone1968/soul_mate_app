import 'dart:math';
import 'package:flutter/material.dart';

class FlowerParticles extends StatefulWidget {
  final int particleCount;
  final double opacity;

  const FlowerParticles({
    super.key,
    this.particleCount = 20,
    this.opacity = 1.0,
  });

  @override
  State<FlowerParticles> createState() => _FlowerParticlesState();
}

class _FlowerParticlesState extends State<FlowerParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 100),
      vsync: this,
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    final random = Random(42);
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 2 + random.nextDouble() * 5,
        speed: 0.02 + random.nextDouble() * 0.05,
        sway: 0.2 + random.nextDouble() * 0.4,
        phase: random.nextDouble() * 2 * pi,
        opacity: 0.3 + random.nextDouble() * 0.4,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            time: _controller.value,
            opacity: widget.opacity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double sway;
  final double phase;
  final double opacity;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.sway,
    required this.phase,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;
  final double opacity;

  _ParticlePainter({
    required this.particles,
    required this.time,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = (p.x + sin(time * p.sway * 3 + p.phase) * 0.05) * size.width;
      final y = (p.y + time * p.speed) % 1.0 * size.height;
      final alpha = (p.opacity * opacity * 255).toInt();

      final paint = Paint()
        ..color = Color.fromARGB(alpha.clamp(0, 80), 0xC0, 0x39, 0x2B)
        ..style = PaintingStyle.fill;

      final path = Path();
      final s = p.size;
      path.moveTo(x, y - s);
      path.quadraticBezierTo(x + s * 0.5, y - s * 0.3, x + s * 0.3, y);
      path.quadraticBezierTo(x + s * 0.2, y + s * 0.5, x, y + s);
      path.quadraticBezierTo(x - s * 0.2, y + s * 0.3, x - s * 0.3, y);
      path.quadraticBezierTo(x - s * 0.5, y - s * 0.3, x, y - s);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}