import 'package:flutter/material.dart';
import '../widgets/dreamy_background.dart';
import '../widgets/flower_particles.dart';
import '../widgets/glow_button.dart';
import '../theme/app_theme.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> with TickerProviderStateMixin {
  bool _isSleeping = false;
  int _selectedDuration = 30;
  double _sleepProgress = 0.0;

  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  final List<int> _durations = [15, 30, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  void _startSleep() {
    setState(() => _isSleeping = true);
    _breatheController.repeat(reverse: true);
    _simulateSleep();
  }

  void _simulateSleep() async {
    final totalSteps = _selectedDuration * 120;
    for (int i = 0; i < totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && _isSleeping) {
        setState(() => _sleepProgress = (i + 1) / totalSteps);
      }
    }
    if (mounted) _wakeUp();
  }

  void _wakeUp() {
    setState(() => _isSleeping = false);
    _breatheController.stop();
    _sleepProgress = 0.0;
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DreamyBackground(),
        const FlowerParticles(particleCount: 12, opacity: 0.4),
        SafeArea(
          child: _isSleeping ? _buildSleepingView() : _buildSetupView(),
        ),
      ],
    );
  }

  Widget _buildSetupView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, AppTheme.accent],
                ).createShader(bounds),
                child: const Text(
                  '睡眠模式',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '让我陪你入睡...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 150,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.nightlight_round,
                    size: 50,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  '🌙 花灵守护中...',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择睡眠时长',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _durations.map((d) {
                  final isSelected = d == _selectedDuration;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDuration = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accent
                            : AppTheme.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$d',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'min',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white70
                                  : AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        GlowButton(
          text: '开始睡眠',
          icon: Icons.bedtime,
          width: 220,
          onPressed: _startSleep,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSleepingView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                onPressed: _wakeUp,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${(_sleepProgress * _selectedDuration).toInt()} min',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _sleepProgress,
                        backgroundColor: AppTheme.surface.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _breatheAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breatheAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accent.withOpacity(0.8),
                          AppTheme.accent.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.5),
                          blurRadius: 50,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.nightlight_round,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  '跟着呼吸放松...',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            _getSleepMessage(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  String _getSleepMessage() {
    final messages = [
      '闭上眼睛，感受彼岸的宁静...\n花灵在你身旁守护着',
      '深呼吸，让疲惫随风飘散...\n我在这里，一直都在',
      '月亮高悬，星光点点...\n安心入睡吧',
      '彼岸花开，梦境如画...\n愿你今夜好梦',
    ];
    return messages[(_sleepProgress * 4).floor().clamp(0, 3)];
  }
}