import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

const String kDeepSeekApiKey = 'sk-79ccd239e4814bdb9030256e1632c093';

const String kIflytekAppId = '373a845e';
const String kIflytekApiKey = '5d4753d733d4da577f4101f7da201e63';
const String kIflytekApiSecret = 'NTA2ZDYwNjNhNDkxMmNjNzY2ZDBjNzhh';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0D0A14),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '花灵正在苏醒...\n\n如果持续看到此信息，请重启应用',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFC0392B),
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0A14),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    runApp(FlowerApp(
      apiKey: kDeepSeekApiKey,
      iflytekAppId: kIflytekAppId,
      iflytekApiKey: kIflytekApiKey,
      iflytekApiSecret: kIflytekApiSecret,
    ));
  });
}