import 'dart:ui' show VoidCallback;
import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  String _lastResult = '';
  String _lastPartialResult = '';
  String? _lastError;

  String? get lastError => _lastError;

  Future<bool> initialize() async {
    _lastError = null;
    try {
      _initialized = await _speech.initialize(
        onError: (error) {
          final errorMsg = error.toString();
          _lastError = errorMsg;
          if (errorMsg.contains('permission_denied') || errorMsg.contains('not_available')) {
            _initialized = false;
          }
        },
        onStatus: (status) {
          if (status == 'notListening' || status == 'error') {
            _initialized = false;
          }
        },
      );
      if (!_initialized) {
        if (_lastError == null) {
          _lastError = '语音识别初始化失败';
        }
      } else if (!_speech.isAvailable) {
        _lastError = '设备不支持语音识别';
        _initialized = false;
      }
      return _initialized && _speech.isAvailable;
    } catch (e) {
      _initialized = false;
      _lastError = e.toString();
      return false;
    }
  }

  bool get isListening => _speech.isListening;

  bool get isAvailable => _speech.isAvailable;

  double get currentSoundLevel => _speech.lastSoundLevel;

  Future<void> startListening({
    required Function(String text) onResult,
    Function(String text)? onPartialResult,
    VoidCallback? onSoundLevelChange,
    VoidCallback? onError,
  }) async {
    if (!_initialized) {
      final success = await initialize();
      if (!success) {
        onError?.call();
        return;
      }
    }

    if (isListening) {
      await stopListening();
    }

    try {
      await _speech.listen(
        localeId: 'zh_CN',
        onResult: (result) {
          if (result.finalResult) {
            _lastResult = result.recognizedWords;
            onResult(_lastResult);
          } else {
            _lastPartialResult = result.recognizedWords;
            onPartialResult?.call(_lastPartialResult);
          }
        },
        onSoundLevelChange: (level) {
          onSoundLevelChange?.call();
        },
        listenFor: const Duration(seconds: 10),
        partialResults: true,
      );
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('permission_denied') || errorMsg.contains('not_available')) {
        _initialized = false;
      }
      onError?.call();
    }
  }

  Future<void> stopListening() async {
    if (isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancel() async {
    if (isListening) {
      await _speech.cancel();
    }
  }

  void dispose() {
    _speech.cancel();
  }
}