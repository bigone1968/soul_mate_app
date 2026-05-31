import 'package:flutter/material.dart';
import '../widgets/dreamy_background.dart';
import '../widgets/flower_particles.dart';
import '../widgets/flower_spirit_eyes.dart';
import '../theme/app_theme.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onNavigateTo;
  final VoidCallback onNavigateToSleep;

  const HomePage({
    super.key,
    required this.onNavigateTo,
    required this.onNavigateToSleep,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DreamyBackground(),
        const FlowerParticles(particleCount: 15, opacity: 0.6),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  child: const FlowerSpiritEyes(
                    expression: Expression.happy,
                  ),
                ),
                const SizedBox(height: 10),
                _buildGreeting(),
                const SizedBox(height: 30),
                _buildFeatureGrid(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, AppTheme.accent],
                ).createShader(bounds),
                child: const Text(
                  '彼岸花开',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Text(
                '花灵伴你入梦',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppTheme.accent,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 6) greeting = '夜深了，花灵陪着你';
    else if (hour < 9) greeting = '早安，新的一天开始了';
    else if (hour < 12) greeting = '上午好，今天想聊什么';
    else if (hour < 14) greeting = '中午好，休息一下吧';
    else if (hour < 18) greeting = '下午好，愿你心情愉快';
    else if (hour < 21) greeting = '傍晚了，放松一下';
    else greeting = '晚安，花灵守护着你';

    return Text(
      greeting,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 16,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      _FeatureCard(
        icon: Icons.chat_bubble_outline,
        title: '与花灵对话',
        subtitle: '说说心里话',
        color: const Color(0xFFC0392B),
        onTap: () => widget.onNavigateTo(),
      ),
      _FeatureCard(
        icon: Icons.bedtime_outlined,
        title: '睡眠陪伴',
        subtitle: '安睡每一夜',
        color: const Color(0xFF8B4513),
        onTap: () => widget.onNavigateToSleep(),
      ),
      _FeatureCard(
        icon: Icons.self_improvement,
        title: '冥想放松',
        subtitle: '静心深呼吸',
        color: const Color(0xFF6B3A2A),
        onTap: () {},
      ),
      _FeatureCard(
        icon: Icons.settings_outlined,
        title: '设置',
        subtitle: '个性化配置',
        color: const Color(0xFF4A2A1A),
        onTap: () {
          DefaultTabController.of(context).animateTo(3);
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: features.take(2).map((f) => Expanded(child: f)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: features.skip(2).map((f) => Expanded(child: f)).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}