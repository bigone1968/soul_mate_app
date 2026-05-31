import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/dreamy_background.dart';
import '../widgets/flower_particles.dart';
import '../widgets/flower_spirit_eyes.dart';
import '../widgets/wave_painter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  late Ticker _eyeTicker;
  late AnimationController _waveController;
  StreamSubscription? _gyroscopeSubscription;
  bool _hasGyroscope = false;
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

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _eyeTicker = createTicker(_onEyeTick)..start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize();
    });
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

    if (mounted) setState(() {});
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

  @override
  void dispose() {
    _eyeTicker.dispose();
    _waveController.dispose();
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

    final expression = chatProvider.currentExpression == 'sleepy'
        ? Expression.sleepy
        : chatProvider.currentExpression == 'curious'
            ? Expression.curious
            : chatProvider.currentExpression == 'happy'
                ? Expression.happy
                : Expression.neutral;

    return Stack(
      children: [
        const DreamyBackground(),
        const FlowerParticles(particleCount: 10, opacity: 0.4),
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(chatProvider),
              SizedBox(
                height: 180,
                child: FlowerSpiritEyes(
                  pupilX: chatProvider.pupilX,
                  pupilY: chatProvider.pupilY,
                  blinkProgress: _blinkProgress,
                  expression: expression,
                ),
              ),
              _buildWaveArea(chatProvider),
              Expanded(child: _buildChatArea(chatProvider)),
              _buildInputArea(chatProvider),
            ],
          ),
        ),
      ],
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
            style: const TextStyle(fontSize: 12, color: Color(0xFFD4C4B5), letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveArea(ChatProvider chatProvider) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 30,
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
                            : '点击话筒开始对话',
            style: const TextStyle(fontSize: 11, color: Color(0xFF8A7A6B)),
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
            Icon(Icons.spa, size: 32, color: const Color(0xFFC0392B).withOpacity(0.3)),
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
                    ? [BoxShadow(color: const Color(0xFFE74C3C).withOpacity(0.5), blurRadius: 20, spreadRadius: 4)]
                    : null,
              ),
              child: Icon(
                chatProvider.isListening || chatProvider.continuousMode ? Icons.headset_mic : Icons.mic,
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: Color(0xFFF5E6D3), fontSize: 14),
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
              decoration: const BoxDecoration(color: Color(0xFFC0392B), shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}