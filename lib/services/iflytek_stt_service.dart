import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class IflytekSttService {
  final String appId;
  final String apiKey;
  final String apiSecret;

  final AudioRecorder _recorder = AudioRecorder();
  String? _recordedPath;
  bool _isRecording = false;
  StreamSubscription<List<int>>? _streamSub;
  WebSocketChannel? _channel;
  bool _streamCancelled = false;

  IflytekSttService({
    required this.appId,
    required this.apiKey,
    required this.apiSecret,
  });

  bool get isRecording => _isRecording;

  Future<bool> startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return false;

      final tempDir = Directory.systemTemp;
      _recordedPath = '${tempDir.path}/iflytek_audio_${DateTime.now().millisecondsSinceEpoch}.pcm';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _recordedPath!,
      );

      _isRecording = true;
      return true;
    } catch (e) {
      _isRecording = false;
      return false;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    _isRecording = false;

    try {
      final path = await _recorder.stop();
      final audioPath = path ?? _recordedPath;
      if (audioPath == null) return null;

      final file = File(audioPath);
      if (!await file.exists()) return null;

      final pcmData = await file.readAsBytes();
      await file.delete();

      if (pcmData.length < 3200) return null;

      return await _recognize(pcmData);
    } catch (e) {
      return null;
    }
  }

  Future<String?> listenOnce() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return null;

    try {
      final url = _buildAuthUrl();
      _channel = WebSocketChannel.connect(Uri.parse(url));

      String result = '';
      final completer = Completer<String?>();
      _streamCancelled = false;
      bool isFirstFrame = true;

      _channel!.stream.listen(
        (data) {
          try {
            final msg = json.decode(data as String);
            final code = msg['code'] as int?;
            if (code != null && code != 0) {
              if (!completer.isCompleted) completer.complete(null);
              return;
            }
            if (msg['data'] != null && msg['data']['result'] != null) {
              result += _parseResult(msg['data']['result']);
            }
            if (msg['data'] != null && msg['data']['status'] == 2) {
              if (!completer.isCompleted) {
                completer.complete(result.isNotEmpty ? result : null);
              }
            }
          } catch (_) {
            if (!completer.isCompleted) {
              completer.complete(result.isNotEmpty ? result : null);
            }
          }
        },
        onError: (_) {
          if (!completer.isCompleted) {
            completer.complete(result.isNotEmpty ? result : null);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(result.isNotEmpty ? result : null);
          }
        },
      );

      _isRecording = true;
      final audioStream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      _streamSub = audioStream.listen(
        (chunk) {
          if (completer.isCompleted || _streamCancelled) return;
          final frame = <String, dynamic>{};
          if (isFirstFrame) {
            frame['common'] = {'app_id': appId};
            frame['business'] = {
              'language': 'zh_cn',
              'domain': 'iat',
              'accent': 'mandarin',
              'vad_eos': 3000,
              'dwa': 'wpgs',
            };
            frame['data'] = {
              'status': 0,
              'format': 'audio/L16;rate=16000',
              'encoding': 'raw',
              'audio': base64.encode(chunk),
            };
            isFirstFrame = false;
          } else {
            frame['data'] = {
              'status': 1,
              'format': 'audio/L16;rate=16000',
              'encoding': 'raw',
              'audio': base64.encode(chunk),
            };
          }
          _channel?.sink.add(json.encode(frame));
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete(null);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete(null);
        },
      );

      final transcript = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => null,
      );

      _streamCancelled = true;
      await _streamSub?.cancel();
      _streamSub = null;
      await _recorder.stop();
      _isRecording = false;
      _channel?.sink.close();
      _channel = null;

      return transcript;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }

  void cancelListenOnce() {
    _streamCancelled = true;
    _streamSub?.cancel();
    _streamSub = null;
    if (_isRecording) {
      _recorder.stop();
      _isRecording = false;
    }
    _channel?.sink.close();
    _channel = null;
  }

  Future<String?> _recognize(List<int> pcmData) async {
    final url = _buildAuthUrl();
    WebSocketChannel? channel;

    try {
      channel = WebSocketChannel.connect(Uri.parse(url));

      String result = '';
      final completer = Completer<String?>();

      const frameSize = 8000;
      final totalFrames = (pcmData.length / frameSize).ceil();

      channel!.stream.listen(
        (data) {
          try {
            final msg = json.decode(data as String);
            final code = msg['code'] as int?;
            if (code != null && code != 0) {
              completer.complete(null);
              return;
            }
            if (msg['data'] != null && msg['data']['result'] != null) {
              result += _parseResult(msg['data']['result']);
            }
            if (msg['data'] != null && msg['data']['status'] == 2) {
              completer.complete(result.isNotEmpty ? result : null);
            }
          } catch (_) {
            completer.complete(result.isNotEmpty ? result : null);
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.complete(result.isNotEmpty ? result : null);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(result.isNotEmpty ? result : null);
          }
        },
      );

      for (int i = 0; i < totalFrames; i++) {
        final start = i * frameSize;
        final end = start + frameSize > pcmData.length ? pcmData.length : start + frameSize;
        final frameData = pcmData.sublist(start, end);
        final isFirst = i == 0;
        final isLast = i == totalFrames - 1;

        final Map<String, dynamic> frame = {};

        if (isFirst) {
          frame['common'] = {'app_id': appId};
          frame['business'] = {
            'language': 'zh_cn',
            'domain': 'iat',
            'accent': 'mandarin',
            'vad_eos': 3000,
            'dwa': 'wpgs',
          };
        }

        frame['data'] = {
          'status': isLast ? 2 : (isFirst ? 0 : 1),
          'format': 'audio/L16;rate=16000',
          'encoding': 'raw',
          'audio': base64.encode(frameData),
        };

        channel.sink.add(json.encode(frame));
      }

      final transcript = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => null,
      );
      return transcript;
    } catch (e) {
      return null;
    } finally {
      channel?.sink.close();
    }
  }

  String _buildAuthUrl() {
    final host = 'iat-api.xfyun.cn';
    final date = _formatHttpDate(DateTime.now().toUtc());
    final signatureOrigin = 'host: $host\ndate: $date\nGET /v2/iat HTTP/1.1';

    final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    final digest = hmacSha256.convert(utf8.encode(signatureOrigin));
    final signature = base64.encode(digest.bytes);

    final authorization =
        'api_key="$apiKey", algorithm="hmac-sha256", headers="host date request-line", signature="$signature"';
    final encodedAuth = base64.encode(utf8.encode(authorization));

    return 'wss://$host/v2/iat?authorization=$encodedAuth&date=${Uri.encodeComponent(date)}&host=$host';
  }

  String _formatHttpDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final d = date;
    final day = days[d.weekday - 1];
    final month = months[d.month - 1];
    final tz = 'GMT';

    return '$day, ${d.day.toString().padLeft(2, '0')} $month ${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')} $tz';
  }

  String _parseResult(Map<String, dynamic> result) {
    final ws = result['ws'] as List<dynamic>?;
    if (ws == null) return '';

    String text = '';
    for (final w in ws) {
      final cw = (w as Map<String, dynamic>)['cw'] as List<dynamic>?;
      if (cw != null && cw.isNotEmpty) {
        text += (cw[0] as Map<String, dynamic>)['w'] as String? ?? '';
      }
    }
    return text;
  }

  void dispose() {
    if (_isRecording) {
      _recorder.stop();
      _isRecording = false;
    }
    _recorder.dispose();
  }
}

