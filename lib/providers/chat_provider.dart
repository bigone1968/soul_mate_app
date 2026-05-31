import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/deepseek_service.dart';
import '../services/iflytek_stt_service.dart';
import '../services/tts_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> messages = [];
  bool isListening = false;
  bool isSpeaking = false;
  bool isProcessing = false;
  bool isRecording = false;
  bool continuousMode = false;
  String connectionState = 'disconnected';
  String statusText = '花灵已至';
  String currentExpression = 'neutral';
  double waveAmplitude = 0.1;
  double pupilX = 0;
  double pupilY = 0;

  late final DeepSeekService _deepSeekService;
  final TtsService _ttsService = TtsService();
  late final IflytekSttService _iflytekSttService;

  ChatProvider({
    String apiKey = '',
    String iflytekAppId = '',
    String iflytekApiKey = '',
    String iflytekApiSecret = '',
  }) {
    _deepSeekService = DeepSeekService(
      apiKey: apiKey,
      apiUrl: DeepSeekService.defaultApiUrl,
    );
    _iflytekSttService = IflytekSttService(
      appId: iflytekAppId,
      apiKey: iflytekApiKey,
      apiSecret: iflytekApiSecret,
    );
    _ttsService.onStart = () {
      isSpeaking = true;
      connectionState = 'speaking';
      statusText = '花灵正在说话...';
      waveAmplitude = 0.9;
      notifyListeners();
    };
    _ttsService.onComplete = () {
      isSpeaking = false;
      if (continuousMode) {
        connectionState = 'listening';
        statusText = '聆听中...';
        waveAmplitude = 0.7;
        notifyListeners();
        _startListenCycle();
      } else {
        connectionState = 'connected';
        statusText = '花灵已至';
        waveAmplitude = 0.1;
        notifyListeners();
      }
    };
  }

  Future<void> initialize() async {
    connectionState = 'connected';
    statusText = '花灵已至';
    waveAmplitude = 0.1;
    notifyListeners();
  }

  Future<void> toggleContinuousMode() async {
    if (continuousMode) {
      continuousMode = false;
      _iflytekSttService.cancelListenOnce();
      isRecording = false;
      isListening = false;
      isProcessing = false;
      isSpeaking = false;
      connectionState = 'connected';
      statusText = '花灵已至';
      waveAmplitude = 0.1;
      notifyListeners();
    } else {
      continuousMode = true;
      isListening = true;
      isRecording = true;
      connectionState = 'listening';
      statusText = '聆听中...';
      waveAmplitude = 0.7;
      notifyListeners();
      await _startListenCycle();
    }
  }

  Future<void> _startListenCycle() async {
    if (!continuousMode) return;

    final text = await _iflytekSttService.listenOnce();

    if (!continuousMode) return;

    if (text == null || text.isEmpty) {
      _startListenCycle();
      return;
    }

    connectionState = 'processing';
    statusText = '思考中...';
    waveAmplitude = 0.7;
    notifyListeners();

    await processUserInput(text);
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    await processUserInput(text);
  }

  Future<void> processUserInput(String text) async {
    isProcessing = true;
    connectionState = 'listening';
    statusText = '思考中...';
    waveAmplitude = 0.7;
    notifyListeners();

    final userMessage = Message(
      text: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    addMessage(userMessage);

    final response = await _deepSeekService.sendMessage(text, companionName: '花灵', userName: '主人');
    final aiText = response['text'] ?? '';
    final emotion = response['emotion'] ?? 'warm';

    setExpression(emotion);

    final aiMessage = Message(
      text: aiText,
      role: MessageRole.ai,
      timestamp: DateTime.now(),
      emotion: emotion,
    );
    addMessage(aiMessage);

    isProcessing = false;
    notifyListeners();

    if (continuousMode && aiText.isNotEmpty) {
      await _ttsService.speak(aiText);
    } else if (!continuousMode && aiText.isNotEmpty) {
      await _ttsService.speak(aiText);
    }
  }

  void addMessage(Message msg) {
    messages.add(msg);
    notifyListeners();
  }

  void updatePupilPosition(double x, double y) {
    pupilX = x;
    pupilY = y;
    notifyListeners();
  }

  void setExpression(String exp) {
    currentExpression = exp;
    notifyListeners();
  }

  @override
  void dispose() {
    continuousMode = false;
    _iflytekSttService.cancelListenOnce();
    _iflytekSttService.dispose();
    _ttsService.dispose();
    super.dispose();
  }
}