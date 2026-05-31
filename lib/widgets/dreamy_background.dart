import 'dart:math';
import 'package:flutter/material.dart';

class DreamyBackground extends StatefulWidget {
  final double opacity;

  const DreamyBackground({super.key, this.opacity = 1.0});

  @override
  State<DreamyBackground> createState() => _DreamyBackgroundState();
}

class _DreamyBackgroundState extends State<DreamyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF0A050E),
                  const Color(0xFF150A18),
                  _controller.value,
                )!,
                Color.lerp(
                  const Color(0xFF1A0A14),
                  const Color(0xFF200A18),
                  _controller.value,
                )!,
                Color.lerp(
                  const Color(0xFF0D0508),
                  const Color(0xFF10060A),
                  _controller.value,
                )!,
              ],
            ),
          ),
          child: _buildStars(),
        );
      },
    );
  }

  Widget _buildStars() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stars = <Widget>[];
        final random = Random(42);
        for (int i = 0; i < 30; i++) {
          final x = random.nextDouble() * constraints.maxWidth;
          final y = random.nextDouble() * constraints.maxHeight;
          final size = 1.0 + random.nextDouble() * 2.0;
          final phase = random.nextDouble() * 2 * pi;
          stars.add(
            Positioned(
              left: x,
              top: y,
              child: _TwinklingStar(size: size, phase: phase),
            ),
          );
        }
        return Stack(children: stars);
      },
    );
  }
}

class _TwinklingStar extends StatefulWidget {
  final double size;
  final double phase;

  const _TwinklingStar({required this.size, required this.phase});

  @override
  State<_TwinklingStar> createState() => _TwinklingStarState();
}

class _TwinklingStarState extends State<_TwinklingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
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
      builder: (context, child) {
        final opacity = 0.2 +
            0.8 * ((sin(_controller.value * pi * 2 + widget.phase) + 1) / 2);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity * 0.6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(opacity * 0.3),
                blurRadius: widget.size * 2,
              ),
            ],
          ),
        );
      },
    );
  }
}