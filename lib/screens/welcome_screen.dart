import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../widgets/eye_painter.dart';
import '../widgets/petal_painter.dart';
import 'chat_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late Ticker _eyeTicker;
  late AnimationController _petalController;
  late AnimationController _blinkController;
  late AnimationController _contentController;
  late AnimationController _pulseController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  List<FallingPetal>? _petals;
  double _petalTime = 0;
  double _eyeElapsed = 0;
  double _blinkProgress = 0;
  double _blinkTimer = 0;
  bool _isBlinking = false;
  double _pupilX = 0;
  double _pupilY = 0;
  bool _canTap = false;

  final List<String> _greetings = [
    '你来了，我在等',
    '彼岸花开，只为见你',
    '花灵已至，陪你入梦',
  ];
  int _greetingIndex = 0;

  @override
  void initState() {
    super.initState();

    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _eyeTicker = createTicker(_onEyeTick)..start();

    _contentController.forward();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _canTap = true);
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _greetingIndex = (_greetingIndex + 1) % _greetings.length;
        });
      }
    });
  }

  void _onEyeTick(Duration elapsed) {
    final dt = (elapsed.inMilliseconds - _eyeElapsed).clamp(0, 100) / 1000.0;
    _eyeElapsed = elapsed.inMilliseconds.toDouble();

    _blinkTimer += dt;
    if (_isBlinking) {
      _blinkProgress += dt * 6;
      if (_blinkProgress >= 1.0) {
        _isBlinking = false;
        _blinkProgress = 0;
        _blinkTimer = 0;
      }
    } else {
      if (_blinkTimer > 3.5 + Random().nextDouble() * 2.5) {
        _isBlinking = true;
        _blinkProgress = 0;
      }
    }

    final t = elapsed.inMilliseconds / 1000.0;
    _pupilX = sin(t * 0.6) * 0.3;
    _pupilY = sin(t * 0.4 + 1.0) * 0.2;

    if (mounted) setState(() {});
  }

  void _enterChat() {
    if (!_canTap) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ChatScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _eyeTicker.dispose();
    _petalController.dispose();
    _blinkController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_petals == null) {
            _petals = generatePetals(15, constraints.maxWidth, constraints.maxHeight);
          }
          return GestureDetector(
            onTap: _enterChat,
            child: AnimatedBuilder(
              animation: Listenable.merge([_petalController]),
              builder: (context, _) {
                _petalTime = _petalController.value * 100;
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0A050E),
                        Color(0xFF150810),
                        Color(0xFF0A050E),
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
                      Positioned(
                        top: constraints.maxHeight * 0.05,
                        left: 0,
                        right: 0,
                        height: constraints.maxHeight * 0.45,
                        child: CustomPaint(
                          painter: EyePainter(
                            pupilX: _pupilX,
                            pupilY: _pupilY,
                            blinkProgress: _blinkProgress,
                            expression: 'happy',
                          ),
                        ),
                      ),
                      SlideTransition(
                        position: _contentSlide,
                        child: FadeTransition(
                          opacity: _contentFade,
                          child: Positioned(
                            top: constraints.maxHeight * 0.52,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                _AnimatedGreeting(
                                  key: ValueKey(_greetingIndex),
                                  text: _greetings[_greetingIndex],
                                ),
                                const SizedBox(height: 40),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFC0392B)
                                          .withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFC0392B),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '花灵',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(0xFFC0392B)
                                              .withOpacity(0.7),
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 60),
                                if (_canTap)
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, _) {
                                      return Opacity(
                                        opacity: 0.3 +
                                            _pulseController.value * 0.5,
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.touch_app,
                                              color: const Color(0xFFC0392B)
                                                  .withOpacity(0.4),
                                              size: 28,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '轻触进入',
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedGreeting extends StatefulWidget {
  final String text;

  const _AnimatedGreeting({super.key, required this.text});

  @override
  State<_AnimatedGreeting> createState() => _AnimatedGreetingState();
}

class _AnimatedGreetingState extends State<_AnimatedGreeting>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              const Color(0xFFF5E6D3),
              const Color(0xFFE8D5C4),
              const Color(0xFFD4C4B5),
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w200,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}