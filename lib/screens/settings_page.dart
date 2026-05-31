import 'package:flutter/material.dart';
import '../widgets/dreamy_background.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppTheme.background),
        const DreamyBackground(),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      '设置',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSection('提醒设置'),
                    _buildSwitchTile(
                      icon: Icons.notifications_outlined,
                      title: '推送通知',
                      subtitle: '接收晚安提醒和花灵消息',
                      value: _notificationsEnabled,
                      onChanged: (v) => setState(() => _notificationsEnabled = v),
                    ),
                    _buildSwitchTile(
                      icon: Icons.volume_up_outlined,
                      title: '声音',
                      subtitle: '花灵语音和背景音乐',
                      value: _soundEnabled,
                      onChanged: (v) => setState(() => _soundEnabled = v),
                    ),
                    _buildSwitchTile(
                      icon: Icons.vibration,
                      title: '振动',
                      subtitle: '触摸反馈',
                      value: _vibrationEnabled,
                      onChanged: (v) => setState(() => _vibrationEnabled = v),
                    ),
                    const SizedBox(height: 30),
                    _buildSection('关于'),
                    _buildTapTile(
                      icon: Icons.info_outline,
                      title: '关于彼岸花开',
                      subtitle: '版本 1.0.0',
                      onTap: () => _showAbout(context),
                    ),
                    _buildTapTile(
                      icon: Icons.privacy_tip_outlined,
                      title: '隐私政策',
                      subtitle: '了解我们如何保护你的隐私',
                      onTap: () {},
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.accent),
        ),
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accent,
        ),
      ),
    );
  }

  Widget _buildTapTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.accent),
        ),
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('彼岸花开', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本 1.0.0', style: TextStyle(color: AppTheme.textSecondary)),
            SizedBox(height: 10),
            Text(
              '一款温暖的情感陪伴APP\n由花灵守护你的每一个夜晚',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}