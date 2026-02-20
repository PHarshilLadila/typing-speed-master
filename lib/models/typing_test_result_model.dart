class TypingTestResultModel {
  final String? id;
  final String? userId;

  final int wpm;
  final int cpm;
  final double accuracy;
  final double consistency;
  final int correctChars;
  final int incorrectChars;
  final int totalChars;
  final Duration duration;
  final DateTime timestamp;
  final String difficulty;
  final bool isWordBasedTest;
  final int? targetWords;
  final List<int> incorrectCharPositions;
  final String originalText;
  final String userInput;

  TypingTestResultModel({
    this.id,
    this.userId,
    required this.wpm,
    this.cpm = 0,
    required this.accuracy,
    required this.consistency,
    required this.correctChars,
    required this.incorrectChars,
    required this.totalChars,
    required this.duration,
    required this.timestamp,
    required this.difficulty,
    this.isWordBasedTest = false,
    this.targetWords,
    this.incorrectCharPositions = const [],
    required this.originalText,
    required this.userInput,
  });

  /// Existing method (unchanged)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'wpm': wpm,
      'cpm': cpm,
      'accuracy': accuracy,
      'consistency': consistency,
      'correctChars': correctChars,
      'incorrectChars': incorrectChars,
      'totalChars': totalChars,
      'durationInSeconds': duration.inSeconds,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'difficulty': difficulty,
      'isWordBasedTest': isWordBasedTest,
      'targetWords': targetWords,
      'incorrectCharPositions': incorrectCharPositions,
      'originalText': originalText,
      'userInput': userInput,
    };
  }

  /// Existing factory (unchanged)
  factory TypingTestResultModel.fromMap(Map<String, dynamic> map) {
    return TypingTestResultModel(
      id: map['id']?.toString(),
      userId: map['userId'] ?? map['user_id'],
      wpm: map['wpm'] ?? 0,
      cpm: map['cpm'] ?? 0,
      accuracy: (map['accuracy'] ?? 0).toDouble(),
      consistency: (map['consistency'] ?? 0).toDouble(),
      correctChars: map['correctChars'] ?? map['correct_chars'] ?? 0,
      incorrectChars: map['incorrectChars'] ?? map['incorrect_chars'] ?? 0,
      totalChars: map['totalChars'] ?? map['total_chars'] ?? 0,
      duration: Duration(
        seconds: map['durationInSeconds'] ?? map['duration_in_seconds'] ?? 0,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      difficulty: map['difficulty'] ?? 'Unknown',
      isWordBasedTest:
          map['isWordBasedTest'] ?? map['is_word_based_test'] ?? false,
      targetWords: map['targetWords'] ?? map['target_words'],
      incorrectCharPositions: List<int>.from(
        map['incorrectCharPositions'] ?? map['incorrect_char_positions'] ?? [],
      ),
      originalText: map['originalText'] ?? map['original_text'] ?? '',
      userInput: map['userInput'] ?? map['user_input'] ?? '',
    );
  }

  /// ✅ NEW: toJson (API / Firebase / Local storage friendly)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'wpm': wpm,
      'cpm': cpm,
      'accuracy': accuracy,
      'consistency': consistency,
      'correct_chars': correctChars,
      'incorrect_chars': incorrectChars,
      'total_chars': totalChars,
      'duration_in_seconds': duration.inSeconds,
      'timestamp': timestamp.toIso8601String(),
      'difficulty': difficulty,
      'is_word_based_test': isWordBasedTest,
      'target_words': targetWords,
      'incorrect_char_positions': incorrectCharPositions,
      'original_text': originalText,
      'user_input': userInput,
    };
  }

  /// ✅ NEW: fromJson
  factory TypingTestResultModel.fromJson(Map<String, dynamic> json) {
    return TypingTestResultModel(
      id: json['id']?.toString(),
      userId: json['user_id'] ?? json['userId'],
      wpm: json['wpm'] ?? 0,
      cpm: json['cpm'] ?? 0,
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      consistency: (json['consistency'] ?? 0).toDouble(),
      correctChars: json['correct_chars'] ?? json['correctChars'] ?? 0,
      incorrectChars: json['incorrect_chars'] ?? json['incorrectChars'] ?? 0,
      totalChars: json['total_chars'] ?? json['totalChars'] ?? 0,
      duration: Duration(
        seconds: json['duration_in_seconds'] ?? json['durationInSeconds'] ?? 0,
      ),
      timestamp:
          json['timestamp'] is String
              ? DateTime.parse(json['timestamp'])
              : DateTime.fromMillisecondsSinceEpoch(
                json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
              ),
      difficulty: json['difficulty'] ?? 'Unknown',
      isWordBasedTest:
          json['is_word_based_test'] ?? json['isWordBasedTest'] ?? false,
      targetWords: json['target_words'] ?? json['targetWords'],
      incorrectCharPositions: List<int>.from(
        json['incorrect_char_positions'] ??
            json['incorrectCharPositions'] ??
            [],
      ),
      originalText: json['original_text'] ?? json['originalText'] ?? '',
      userInput: json['user_input'] ?? json['userInput'] ?? '',
    );
  }

  /// Existing Supabase method (unchanged)
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'user_id': userId,
      'wpm': wpm,
      'cpm': cpm,
      'accuracy': accuracy,
      'consistency': consistency,
      'correct_chars': correctChars,
      'incorrect_chars': incorrectChars,
      'total_chars': totalChars,
      'duration_in_seconds': duration.inSeconds,
      'difficulty': difficulty,
      'is_word_based_test': isWordBasedTest,
      'target_words': targetWords,
      'timestamp': timestamp.toIso8601String(),
      'incorrect_char_positions': incorrectCharPositions,
      'original_text': originalText,
      'user_input': userInput,
    };
  }
}
