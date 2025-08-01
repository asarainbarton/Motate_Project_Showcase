class JournalEntry {
  final int? id;
  final String text;
  final String emoji;
  final String sentiment;
  final double sentimentScore;
  final DateTime createdAt;

  JournalEntry({
    this.id,
    required this.text,
    required this.emoji,
    required this.sentiment,
    required this.sentimentScore,
    required this.createdAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      text: json['text'],
      emoji: json['emoji'],
      sentiment: json['sentiment'],
      sentimentScore: json['sentiment_score'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'emoji': emoji,
    };
  }
}

class MoodCount {
  final String emoji;
  final int count;

  MoodCount(this.emoji, this.count);
}

class CommonEmotion {
  final String emoji;
  final int count;

  CommonEmotion({required this.emoji, required this.count});

  factory CommonEmotion.fromJson(Map<String, dynamic> json) {
    return CommonEmotion(
      emoji: json['emoji'],
      count: json['count'],
    );
  }
}
