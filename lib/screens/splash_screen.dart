import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/dreamy_background.dart';
import '../widgets/flower_particles.dart';
import '../widgets/flower_spirit_eyes.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _titleFade;
  late Animation<double> _titleScale;
  late Animation<double> _subtitleFade;
  late Animation<double> _eyeFade;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );
    _titleScale = Tween<double>(begin: 1.3, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.35, 0.7, curve: Curves.easeIn)),
    );
    _eyeFade = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)),
    );

    _fadeController.forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DreamyBackground(),
          const FlowerParticles(particleCount: 25, opacity: 0.8),
          AnimatedBuilder(
            animation: _eyeFade,
            builder: (context, _) {
              return Opacity(
                opacity: _eyeFade.value,
                child: const Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 220,
                    child: FlowerSpiritEyes(
                      expression: Expression.happy,
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_fadeController, _glowController]),
            builder: (context, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  Opacity(
                    opacity: _titleFade.value,
                    child: Transform.scale(
                      scale: _titleScale.value,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            const Color(0xFFE74C3C),
                            const Color(0xFFC0392B),
                            const Color(0xFF922B21),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          '彼岸花开',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: _subtitleFade.value,
                    child: Text(
                      '花灵 · 伴你入梦',
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 3,
                        color: const Color(0xFF8B4513).withOpacity(0.7),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  Opacity(
                    opacity: 0.3 + _glowController.value * 0.2,
                    child: Column(
                      children: [
                        Icon(Icons.keyboard_arrow_up,
                            color: const Color(0xFFC0392B).withOpacity(0.3), size: 20),
                        const SizedBox(height: 4),
                        Text(
                          '花灵正在苏醒...',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF8A7A6B).withOpacity(0.5),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}