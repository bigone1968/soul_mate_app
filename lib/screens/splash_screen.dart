import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../widgets/eye_painter.dart';
import '../widgets/petal_painter.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _petalController;
  late AnimationController _glowController;
  late AnimationController _eyeController;
  late Animation<double> _eyeOpacity;
  late Animation<double> _titleScale;
  late Animation<double> _subtitleFade;

  List<FallingPetal>? _petals;
  double _petalTime = 0;

  @override
  void initState() {
    super.initState();

    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _titleScale = Tween<double>(begin: 1.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    _eyeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _eyeOpacity = Tween<double>(begin: 0.0, end: 0.65).animate(
      CurvedAnimation(
        parent: _eyeController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _fadeController.forward();

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _eyeController.forward();
      }
    });

    Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const WelcomeScreen(),
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
    _petalController.dispose();
    _glowController.dispose();
    _eyeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_petals == null) {
            _petals = generatePetals(25, constraints.maxWidth, constraints.maxHeight);
          }
          return AnimatedBuilder(
            animation: Listenable.merge([_petalController, _glowController]),
            builder: (context, _) {
              _petalTime = _petalController.value * 100;
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A050E),
                      Color(0xFF1A0A14),
                      Color(0xFF0D0508),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: PetalPainter(
                        petals: _petals!,
                        time: _petalTime,
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, _) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.center,
                                  radius: 0.6 + _glowController.value * 0.15,
                                  colors: [
                                    Color(0xFF8B0000)
                                        .withOpacity(0.04 + _glowController.value * 0.04),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _eyeOpacity,
                      builder: (context, _) {
                        return Positioned(
                          top: constraints.maxHeight * 0.08,
                          left: 0,
                          right: 0,
                          height: constraints.maxHeight * 0.4,
                          child: Opacity(
                            opacity: _eyeOpacity.value,
                            child: CustomPaint(
                              painter: EyePainter(
                                pupilX: 0,
                                pupilY: -0.1,
                                blinkProgress: 0,
                                expression: 'neutral',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _fadeController,
                      builder: (context, _) {
                        return Positioned(
                          top: constraints.maxHeight * 0.52,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Transform.scale(
                                scale: _titleScale.value,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      const Color(0xFFE74C3C),
                                      const Color(0xFFC0392B),
                                      const Color(0xFF922B21),
                                    ],
                                    stops: [0.0, 0.5, 1.0],
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
                              const SizedBox(height: 16),
                              Opacity(
                                opacity: _subtitleFade.value,
                                child: Text(
                                  '曼珠沙华  ·  花叶永不相见',
                                  style: TextStyle(
                                    fontSize: 13,
                                    letterSpacing: 3,
                                    color: const Color(0xFF8B4513)
                                        .withOpacity(0.7),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Opacity(
                                opacity: _subtitleFade.value,
                                child: _buildLoadingDots(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: constraints.maxHeight * 0.06,
                      left: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, _) {
                          return Opacity(
                            opacity: 0.3 + _glowController.value * 0.2,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  color: const Color(0xFFC0392B)
                                      .withOpacity(0.3),
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '花灵正在苏醒...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF8A7A6B)
                                        .withOpacity(0.5),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return _Dot(index: index, controller: _glowController);
      }),
    );
  }
}

class _Dot extends AnimatedWidget {
  final int index;

  const _Dot({required this.index, required AnimationController controller})
      : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final controller = listenable as AnimationController;
    final delay = index * 0.15;
    final value = (controller.value + delay) % 1.0;
    final size = 3.0 + sin(value * pi) * 2.5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              const Color(0xFFE74C3C).withOpacity(0.6 + sin(value * pi) * 0.4),
              const Color(0xFFC0392B).withOpacity(0.2),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC0392B).withOpacity(0.3),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}