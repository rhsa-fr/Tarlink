class BotMessageModel {
  final String id;
  final String sender; // 'user' or 'bot'
  final String text;
  final DateTime createdAt;

  const BotMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  bool get isUser => sender == 'user';
}
