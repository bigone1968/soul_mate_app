import 'package:audioplayers/audioplayers.dart';

class TtsService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  void Function()? onComplete;
  void Function()? onStart;

  TtsService() {
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      onComplete?.call();
    });

    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _isPlaying = true;
        onStart?.call();
      } else if (state == PlayerState.stopped || state == PlayerState.completed) {
        _isPlaying = false;
      }
    });
  }

  Future<void> speak(String text) async {
    try {
      await stop();

      final encoded = Uri.encodeComponent(text);
      final urls = [
        'https://fanyi.baidu.com/gettts?lan=zh&text=$encoded&spd=3&source=web',
        'https://tts.baidu.com/text2audio?lan=zh&ie=utf-8&spd=4&text=$encoded',
      ];

      for (final url in urls) {
        try {
          await _player.play(UrlSource(url));
          _isPlaying = true;
          onStart?.call();
          return;
        } catch (_) {
          continue;
        }
      }

      _isPlaying = false;
    } catch (_) {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (_) {
      _isPlaying = false;
    }
  }

  void dispose() {
    _player.dispose();
  }
}