enum MessageRole {
  user,
  ai;

  String toJson() => name;

  static MessageRole fromJson(String json) {
    switch (json) {
      case 'user':
        return MessageRole.user;
      case 'ai':
        return MessageRole.ai;
      default:
        throw ArgumentError('Invalid MessageRole: $json');
    }
  }
}

class Message {
  final String text;
  final MessageRole role;
  final DateTime timestamp;
  final String? emotion;

  const Message({
    required this.text,
    required this.role,
    required this.timestamp,
    this.emotion,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] as String,
      role: MessageRole.fromJson(json['role'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      emotion: json['emotion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'role': role.toJson(),
      'timestamp': timestamp.toIso8601String(),
      if (emotion != null) 'emotion': emotion,
    };
  }

  Message copyWith({
    String? text,
    MessageRole? role,
    DateTime? timestamp,
    String? emotion,
  }) {
    return Message(
      text: text ?? this.text,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      emotion: emotion ?? this.emotion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          role == other.role &&
          timestamp == other.timestamp &&
          emotion == other.emotion;

  @override
  int get hashCode =>
      text.hashCode ^ role.hashCode ^ timestamp.hashCode ^ emotion.hashCode;

  @override
  String toString() =>
      'Message(text: $text, role: $role, timestamp: $timestamp, emotion: $emotion)';
}