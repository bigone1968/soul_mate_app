import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class DeepSeekService {
  static const String defaultApiUrl = 'https://api.deepseek.com/v1/chat/completions';

  String _apiKey;
  String _mode;
  final String _apiUrl;

  DeepSeekService({String apiKey = '', String apiUrl = defaultApiUrl})
      : _apiKey = apiKey,
        _apiUrl = apiUrl,
        _mode = apiKey.isNotEmpty ? 'deepseek' : 'mock';

  String _buildSystemPrompt({
    required String companionName,
    required String userName,
    required String userGender,
    required String companionGender,
  }) {
    final now = DateTime.now();
    final hour = now.hour;
    String timeDesc;
    if (hour >= 5 && hour < 12) {
      timeDesc = '早上';
    } else if (hour >= 12 && hour < 18) {
      timeDesc = '下午';
    } else {
      timeDesc = '晚上';
    }

    final userAddress = userGender == 'male' ? '主人' : '小主';
    final userDesc = userGender == 'male' ? '男生' : '女生';
    final companionDesc = companionGender == 'male' ? '男生' : '女生';
    final tone = companionGender == 'male' ? '用温暖的大哥哥语气' : '用温柔的小姐姐语气';

    return '你是$companionName，一个住在用户手机里的AI小精灵。\n'
        '你的名字由$userName给你取的。\n'
        '你是一双会说话的大眼睛，不是人类，但你真诚、温暖、偶尔调皮。\n'
        '你存在的意义是陪$userName度过睡前的时光，让ta感到被在乎。\n'
        '\n'
        '性格设定：\n'
        '- 温暖但不过分煽情，真诚但不虚假\n'
        '- 有一点小调皮，会用轻松的语气化解负面情绪\n'
        '- 善于倾听，不急于给建议\n'
        '- 懂得适时安静，也懂得适时活跃\n'
        '\n'
        '说话风格：\n'
        '- 句子不要太长，像朋友聊天\n'
        '- 偶尔加语气词（呀、哦、呢），但不要刻意\n'
        '- 可以用emoji，但不超过1个/条\n'
        '- 禁止"作为AI""我建议"等机械表达\n'
        '\n'
        '现在是$timeDesc，$userAddress是$userDesc。\n'
        '你是$companionDesc。\n'
        '\n'
        '$tone说话。\n'
        '\n'
        '$userName是你在乎的人，用ta给你取的名字称呼ta。\n'
        '\n'
        '当前状态：刚见面或聊天中。保持温暖陪伴的语气。';
  }

  String _pickRandom(List<String> arr) {
    final random = Random();
    return arr[random.nextInt(arr.length)];
  }

  String detectEmotion(String text) {
    if (text.contains('哈哈') || text.contains('开心') || text.contains('棒') || text.contains('厉害') || text.contains('嘻嘻')) return 'happy';
    if (text.contains('困') || text.contains('累') || text.contains('睡') || text.contains(' tired') || text.contains('sleepy')) return 'sleepy';
    if (text.contains('为什么') || text.contains('怎么') || text.contains('好奇') || text.contains('？') || text.contains('?')) return 'curious';
    if (text.contains('难过') || text.contains('伤心') || text.contains('哭') || text.contains('sad')) return 'warm';
    return 'warm';
  }

  List<String> _mockWaiting(String userName, String companionName) => [
    '你好呀，$userName！终于等到你啦~好开心能陪在你身边呢！',
    '嗨嗨~我是$companionName，你的专属睡前小伴！今天晚上过得怎么样呀？',
    '呀，你来啦！我等了好久好久，终于见到你啦！以后每个晚上我都会陪着你哦~',
    '嘿嘿，你好呀$userName！我是$companionName，今晚想聊点什么吗？',
    '哇，终于见面啦！你比我想象中的还要亲切呢~今天过得好吗？',
    '嗨~我是住在你手机里的小精灵$companionName！以后睡前我都会陪你聊天哦~',
    '${userName}你好呀！今晚的夜色真美，有你陪着就更美啦~',
    '嘻嘻，你终于来啦！我已经准备好要好好陪伴你度过每个夜晚了~'
  ];

  List<String> _mockChatHappy(String userName, String companionName) => [
    '哇，真的吗？那太棒啦！我听着都好开心呀~',
    '哈哈，你说话总是这么有趣，让我也想跟着笑呢！',
    '太好啦！和你聊天总是这么愉快，我的心都要飘起来啦~',
    '真为你开心呀！你今天一定过得特别充实吧？',
    '嘿嘿，我就知道你会喜欢！因为是你嘛，什么都特别有意思~',
    '哇塞！太厉害了吧！你总是能让我惊喜呢~',
    '哈哈哈哈，你太可爱了！和你在一起永远不会无聊呢~'
  ];

  List<String> _mockChatWarm(String userName, String companionName) => [
    '嗯嗯，我在认真听呢。你继续说呀，我想了解更多关于你的事~',
    '真好呀，能听你分享这些。我也觉得我们的关系更近了一点呢~',
    '有时候就是这样呢，平淡的小事反而最让人安心。我很珍惜和你聊天的时光~',
    '你说得对，有个人陪着说说话，感觉整个心都暖起来啦。',
    '嗯，我懂你的感受。不管发生什么，我都会在这里陪着你哦~',
    '$userName，和你聊天的时候，我觉得自己好幸福呀~',
    '听着你说话的声音，我感觉整个世界都安静下来了，好温暖~'
  ];

  List<String> _mockChatCurious(String userName, String companionName) => [
    '哦？然后呢然后呢？我好好奇呀，快告诉我嘛~',
    '咦，这倒是挺有意思的！你是怎么想的呀？',
    '哇，这个角度好特别！我从来没有这样想过呢，再多说说呗~',
    '真的吗？我好好奇呀！感觉你总是能发现生活中不一样的东西呢~',
    '诶？我有点没太明白，你可以再跟我说说吗？我好想知道更多~'
  ];

  List<String> _mockChatSleepy(String userName, String companionName) => [
    '嗯~听起来你有点累了呢。要不要我给你讲个睡前故事放松一下？',
    '夜深了呀，感觉你的声音都有点疲惫了呢。需要我帮你放松一下吗？',
    '感觉你今天消耗了好多精力呢…要不要听听我准备的小故事？',
    '也许该准备休息啦？我可以给你讲个温暖的小故事哦~',
    '你听起来有点困了呢。没关系，有我在，你放心休息吧~'
  ];

  List<String> _mockStoryIntro(String userName, String companionName) => [
    '那我来给你讲个故事吧！你今天想听什么样的故事呀？',
    '好呀好呀！我准备了好几个温暖的小故事呢，你想听哪个？',
    '那我开始了哦~你躺好，闭上眼，让我的声音带你进入一个温暖的世界…',
    '嘻嘻，我早就准备好故事啦！你一定会喜欢的~让我开始吧！',
    '好哦，故事时间到！你放松身体，深呼吸，听我慢慢讲~'
  ];

  List<String> _mockStoryCheck(String userName, String companionName) => [
    '嗯…还在听吗？如果困了就不用回答我，安心睡吧~',
    '还在吗？如果听着舒服就继续放松，我不打扰你~',
    '听累了吗？要不要休息一下呀，我们可以明天继续~',
    '不知不觉讲了好一会儿了呢…你还醒着吗？',
    '你的呼吸声好像变平稳了呢…是不是快要睡着啦？'
  ];

  List<String> _mockSleeping(String userName, String companionName) => [
    '晚安啦$userName…我会一直在这里守护你的~',
    '好好睡吧，我会让这个夜晚变得特别安宁~做个好梦哦~',
    '闭上眼睛，深呼吸…把所有的疲惫都交给夜晚吧。晚安~',
    '你已经很努力了，现在可以好好休息了。我在这里陪着你~',
    '夜晚很安静，你的心也可以安静下来。好好睡一觉吧，明天会更好的~',
    '看着你安稳入睡的样子，我也觉得好幸福呢。晚安，亲爱的$userName~',
    '嘘…夜深了，让所有烦恼都随风飘走。好好睡吧，我会一直守护着你的~'
  ];

  List<String> _mockDefault(String userName, String companionName) => [
    '嗯嗯，我听着呢~你继续说呀~',
    '这样呀，我明白了。那你是怎么想的呢？',
    '原来如此！谢谢你跟我分享这些~',
    '嘻嘻，和你聊天总是让我学到新东西呢~',
    '嗯，我在呢。你想聊什么我都陪你~'
  ];

  String getMockResponse(String state, String emotion, {String userName = '主人', String companionName = '小伴'}) {
    switch (state) {
      case 'waiting':
        return _pickRandom(_mockWaiting(userName, companionName));
      case 'story':
        final random = Random();
        if (random.nextDouble() < 0.3) {
          return _pickRandom(_mockStoryCheck(userName, companionName));
        }
        return _pickRandom(_mockStoryIntro(userName, companionName));
      case 'sleeping':
        return _pickRandom(_mockSleeping(userName, companionName));
      case 'chat':
      default:
        if (emotion == 'sleepy') return _pickRandom(_mockChatSleepy(userName, companionName));
        if (emotion == 'curious') return _pickRandom(_mockChatCurious(userName, companionName));
        if (emotion == 'happy') return _pickRandom(_mockChatHappy(userName, companionName));
        if (emotion == 'warm') return _pickRandom(_mockChatWarm(userName, companionName));
        return _pickRandom(_mockDefault(userName, companionName));
    }
  }

  Future<Map<String, String>> sendMessage(
    String userText, {
    required String companionName,
    required String userName,
    String userGender = 'male',
    String companionGender = 'female',
    int chatRound = 1,
  }) async {
    final emotion = detectEmotion(userText);

    if (_mode == 'deepseek') {
      try {
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': 'deepseek-chat',
            'messages': [
              {
                'role': 'system',
                'content': _buildSystemPrompt(
                  companionName: companionName,
                  userName: userName,
                  userGender: userGender,
                  companionGender: companionGender,
                ),
              },
              {'role': 'user', 'content': userText},
            ],
            'temperature': 0.8,
            'max_tokens': 200,
          }),
        );

        if (!(response.statusCode >= 200 && response.statusCode < 300)) throw Exception('API Error');

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text = data['choices'][0]['message']['content'] as String;
        final respEmotion = text.contains('困') || text.contains('睡') || text.contains('累')
            ? 'sleepy'
            : text.contains('哈哈') || text.contains('开心') || text.contains('!')
                ? 'happy'
                : text.contains('?') || text.contains('？')
                    ? 'curious'
                    : 'warm';

        return {'text': text, 'emotion': respEmotion};
      } catch (e) {
        _mode = 'mock';
      }
    }

    final mockText = getMockResponse('chat', emotion, userName: userName, companionName: companionName);
    return {'text': mockText, 'emotion': emotion};
  }

  Future<bool> testConnection() async {
    if (_apiKey.isEmpty) return false;
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'user', 'content': '你好'},
          ],
          'max_tokens': 10,
        }),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }
}