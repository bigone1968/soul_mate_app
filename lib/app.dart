import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/splash_screen.dart';

class FlowerApp extends StatelessWidget {
  final String apiKey;
  final String iflytekAppId;
  final String iflytekApiKey;
  final String iflytekApiSecret;

  const FlowerApp({
    super.key,
    required this.apiKey,
    required this.iflytekAppId,
    required this.iflytekApiKey,
    required this.iflytekApiSecret,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            apiKey: apiKey,
            iflytekAppId: iflytekAppId,
            iflytekApiKey: iflytekApiKey,
            iflytekApiSecret: iflytekApiSecret,
          ),
        ),
      ],
      child: MaterialApp(
        title: '彼岸花开',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A050E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFC0392B),
            secondary: Color(0xFFE74C3C),
          ),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF0D0508),
            selectedItemColor: Color(0xFFC0392B),
            unselectedItemColor: Color(0xFF8A7A6B),
            type: BottomNavigationBarType.fixed,
            elevation: 20,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}