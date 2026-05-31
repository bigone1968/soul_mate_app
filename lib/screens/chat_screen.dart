import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/eye_painter.dart';
import '../widgets/wave_painter.dart';
import '../widgets/petal_painter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  late Ticker _eyeTicker;
  late AnimationController _waveController;
  late AnimationController _petalController;
  late AnimationController _sleepOverlayController;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  bool _hasGyroscope = false;
  bool _sleepMode = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;

  double _blinkProgress = 0.0;
  double _blinkTimer = 0.0;
  bool _isBlinking = false;
  double _pupilTargetX = 0.0;
  double _pupilTargetY = 0.0;
  double _currentPupilX = 0.0;
  double _currentPupilY = 0.0;
  double _eyeElapsed = 0.0;

  List<FallingPetal>? _petals;
  double _petalTime = 0;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();

    _sleepOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _eyeTicker = createTicker(_onEyeTick)..start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize();
      _setupGyroscope();
    });
  }

  void _setupGyroscope() {
    try {
      _gyroscopeSubscription = gyroscopeEventStream().listen(
        (event) {
          if (!_hasGyroscope) {
            setState(() => _hasGyroscope = true);
          }
          _pupilTargetX += (event.y * 0.01).clamp(-0.1, 0.1);
          _pupilTargetY += (event.x * 0.01).clamp(-0.1, 0.1);
          _pupilTargetX = _pupilTargetX.clamp(-1.0, 1.0);
          _pupilTargetY = _pupilTargetY.clamp(-1.0, 1.0);
        },
        onError: (error) {
          _hasGyroscope = false;
        },
      );
    } catch (e) {
      _hasGyroscope = false;
    }
  }

  void _onEyeTick(Duration elapsed) {
    final dt = (elapsed.inMilliseconds - _eyeElapsed).clamp(0, 100) / 1000.0;
    _eyeElapsed = elapsed.inMilliseconds.toDouble();

    _blinkTimer += dt;
    if (_isBlinking) {
      _blinkProgress += dt * 8;
      if (_blinkProgress >= 1.0) {
        _isBlinking = false;
        _blinkProgress = 0.0;
        _blinkTimer = 0.0;
      }
    } else {
      if (_blinkTimer > 3.0 + Random().nextDouble() * 2.0) {
        _isBlinking = true;
        _blinkProgress = 0.0;
      }
    }

    if (!_hasGyroscope) {
      final t = elapsed.inMilliseconds / 1000.0;
      _pupilTargetX = sin(t * 0.7) * 0.5;
      _pupilTargetY = sin(t * 0.5 + 1.2) * 0.3;
    }

    _currentPupilX += (_pupilTargetX - _currentPupilX) * 0.1;
    _currentPupilY += (_pupilTargetY - _currentPupilY) * 0.1;

    if (mounted) {
      context.read<ChatProvider>().updatePupilPosition(
        _currentPupilX,
        _currentPupilY,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleSleepMode() {
    if (_sleepMode) {
      _sleepOverlayController.reverse();
      setState(() => _sleepMode = false);
      context.read<ChatProvider>().setExpression('neutral');
    } else {
      _sleepOverlayController.forward();
      setState(() => _sleepMode = true);
      context.read<ChatProvider>().setExpression('sleepy');
    }
  }

  @override
  void dispose() {
    _eyeTicker.dispose();
    _waveController.dispose();
    _petalController.dispose();
    _sleepOverlayController.dispose();
    _gyroscopeSubscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    if (chatProvider.messages.length != _lastMessageCount &&
        chatProvider.messages.isNotEmpty) {
      _lastMessageCount = chatProvider.messages.length;
      _scrollToBottom();
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(chatProvider),
                _buildCompanionArea(chatProvider),
                _buildWaveArea(chatProvider),
                Expanded(child: _buildChatArea(chatProvider)),
                _buildInputArea(chatProvider),
              ],
            ),
          ),
          if (_sleepMode)
            _buildSleepOverlay(chatProvider),
        ],
      ),
    );
  }

  Widget _buildTopBar(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: chatProvider.connectionState == 'speaking'
                  ? const Color(0xFFE74C3C)
                  : chatProvider.connectionState == 'listening'
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFFC0392B),
              boxShadow: [
                BoxShadow(
                  color: (chatProvider.connectionState == 'speaking'
                          ? const Color(0xFFE74C3C)
                          : chatProvider.connectionState == 'listening'
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFC0392B))
                      .withOpacity(0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            chatProvider.statusText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFD4C4B5),
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _toggleSleepMode,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _sleepMode
                    ? const Color(0xFFC0392B).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _sleepMode ? Icons.nightlight_round : Icons.nightlight,
                size: 18,
                color: _sleepMode
                    ? const Color(0xFFC0392B)
                    : const Color(0xFF8A7A6B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanionArea(ChatProvider chatProvider) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 160,
        maxHeight: 260,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _petalController,
            builder: (context, _) {
              _petalTime = _petalController.value * 100;
              if (_petals == null) {
                _petals = generatePetals(8, constraints.maxWidth, constraints.maxHeight);
              }
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: PetalPainter(
                      petals: _petals!,
                      time: _petalTime,
                    ),
                  ),
                  ...List.generate(12, (index) {
                    final seed = index * 137.5;
                    final x = (seed * 7.3) % constraints.maxWidth;
                    final y = (seed * 11.7) % constraints.maxHeight;
                    final size = 1.0 + (seed % 3) * 0.5;
                    final phase = (seed * 0.1) % (pi * 2);
                    return Positioned(
                      left: x,
                      top: y,
                      child: _TwinklingStar(size: size, phase: phase),
                    );
                  }),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: EyePainter(
                        pupilX: chatProvider.pupilX,
                        pupilY: chatProvider.pupilY,
                        blinkProgress: _blinkProgress,
                        expression: _sleepMode ? 'sleepy' : chatProvider.currentExpression,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.bottomCenter,
                          radius: 0.8,
                          colors: [
                            Color(0x55C0392B),
                            Color(0x00C0392B),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWaveArea(ChatProvider chatProvider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: CustomPaint(
              painter: WavePainter(
                amplitude: chatProvider.waveAmplitude,
                phase: _waveController.value * 2 * pi,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            chatProvider.isRecording
                ? '录音中...'
                : chatProvider.continuousMode
                    ? '连续对话中，点击按钮停止'
                    : chatProvider.isListening
                        ? '聆听中...'
                        : chatProvider.isSpeaking
                            ? '花灵正在说话...'
                            : _sleepMode
                                ? '花灵陪着你入眠...'
                                : '点击话筒开始对话',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8A7A6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(ChatProvider chatProvider) {
    if (chatProvider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.spa,
              size: 32,
              color: const Color(0xFFC0392B).withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              '彼岸花开，花灵在听',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A7A6B),
                letterSpacing: 2,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return ChatBubble(
          message: message,
          showTimestamp: index == chatProvider.messages.length - 1,
        );
      },
    );
  }

  Widget _buildInputArea(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8, top: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<ChatProvider>().toggleContinuousMode();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: chatProvider.isListening || chatProvider.continuousMode
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFFC0392B),
                  width: chatProvider.isListening || chatProvider.continuousMode ? 2.5 : 2,
                ),
                boxShadow: chatProvider.isListening || chatProvider.continuousMode
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE74C3C).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                chatProvider.isListening || chatProvider.continuousMode
                    ? Icons.headset_mic
                    : Icons.mic,
                color: chatProvider.isListening || chatProvider.continuousMode
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFFC0392B),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '输入文字...',
                filled: true,
                fillColor: const Color(0xFF1A1525),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFFF5E6D3),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final text = _textController.text;
              if (text.isNotEmpty) {
                context.read<ChatProvider>().sendTextMessage(text);
                _textController.clear();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFC0392B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepOverlay(ChatProvider chatProvider) {
    return AnimatedBuilder(
      animation: _sleepOverlayController,
      builder: (context, _) {
        return IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF050208).withOpacity(0.3 + _sleepOverlayController.value * 0.5),
                  const Color(0xFF0A050E).withOpacity(0.5 + _sleepOverlayController.value * 0.4),
                ],
              ),
            ),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Opacity(
                  opacity: 0.5 + _sleepOverlayController.value * 0.3,
                  child: Column(
                    children: [
                      Icon(
                        Icons.nights_stay,
                        size: 32,
                        color: const Color(0xFF8A7A6B).withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '晚安',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 8,
                          color: Color(0xFFD4C4B5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '花灵会一直守护着你',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 3,
                          color: Color(0xFF8A7A6B),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _SleepBreathingRing(
                        controller: _sleepOverlayController,
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
                Opacity(
                  opacity: _sleepOverlayController.value,
                  child: GestureDetector(
                    onTap: _toggleSleepMode,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFC0392B).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '轻触唤醒',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A7A6B),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
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
      vsync: this,
      duration: const Duration(seconds: 3),
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
        final opacity = 0.3 +
            0.7 *
                ((sin(_controller.value * pi * 2 + widget.phase) + 1) / 2);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _SleepBreathingRing extends StatelessWidget {
  final AnimationController controller;

  const _SleepBreathingRing({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          width: 60 + controller.value * 20,
          height: 60 + controller.value * 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFC0392B).withOpacity(0.1 + controller.value * 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Container(
              width: 40 + controller.value * 15,
              height: 40 + controller.value * 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC0392B).withOpacity(0.15 + controller.value * 0.15),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 20 + controller.value * 10,
                  height: 20 + controller.value * 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFC0392B).withOpacity(0.1 + controller.value * 0.08),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}