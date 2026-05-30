import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/chat_provider.dart';
import 'screens/splash_screen.dart';

class SoulMateApp extends StatelessWidget {
  final String apiKey;
  final String iflytekAppId;
  final String iflytekApiKey;
  final String iflytekApiSecret;
  const SoulMateApp({
    super.key,
    required this.apiKey,
    required this.iflytekAppId,
    required this.iflytekApiKey,
    required this.iflytekApiSecret,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (_) => ChatProvider(
        apiKey: apiKey,
        iflytekAppId: iflytekAppId,
        iflytekApiKey: iflytekApiKey,
        iflytekApiSecret: iflytekApiSecret,
      ),
      child: MaterialApp(
        title: '彼岸花开',
        theme: AppTheme.theme(),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}