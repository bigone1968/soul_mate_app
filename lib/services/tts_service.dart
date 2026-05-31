import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class TtsService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  static const String _appId = '2127709096';
  static const String _token = '73f69906-957b-4a0b-a878-5318dbf568f1';
  static const String _apiUrl = 'https://openspeech.bytedance.com/api/v1/tts';

  String _currentVoiceType = 'BV001_streaming';

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

  bool get isPlaying => _isPlaying;

  void setVoiceType(String voiceType) {
    _currentVoiceType = voiceType;
  }

  String generateReqId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = (now % 100000).toString().padLeft(5, '0');
    return 'hualing_${now}_$random';
  }

  Future<void> speak(String text) async {
    try {
      await stop();

      if (text.trim().isEmpty) return;

      final reqId = generateReqId();
      final body = jsonEncode({
        'app': {
          'appid': _appId,
          'token': _token,
          'cluster': 'volcano_tts',
        },
        'user': {
          'uid': 'hualing_user',
        },
        'audio': {
          'voice_type': _currentVoiceType,
          'encoding': 'mp3',
          'speed_ratio': 1.0,
        },
        'request': {
          'reqid': reqId,
          'text': text,
          'operation': 'query',
        },
      });

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer; $_token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        return;
      }

      final responseData = jsonDecode(response.body);

      final baseResp = responseData['BaseResp'];
      if (baseResp != null && baseResp['StatusCode'] != 0) {
        return;
      }

      final audioData = responseData['data'];
      if (audioData == null) return;

      final audioBytes = base64Decode(audioData);
      if (audioBytes.isEmpty) return;

      await _player.play(BytesSource(audioBytes));
    } catch (_) {}
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