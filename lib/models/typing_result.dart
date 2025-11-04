class TypingResult {
  final int wpm;
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

  TypingResult({
    required this.wpm,
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
  });

  Map<String, dynamic> toMap() {
    return {
      'wpm': wpm,
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
    };
  }

  factory TypingResult.fromMap(Map<String, dynamic> map) {
    return TypingResult(
      wpm: map['wpm'],
      accuracy: map['accuracy'].toDouble(),
      consistency: map['consistency'].toDouble(),
      correctChars: map['correctChars'],
      incorrectChars: map['incorrectChars'],
      totalChars: map['totalChars'],
      duration: Duration(seconds: map['durationInSeconds']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      difficulty: map['difficulty'],
      isWordBasedTest: map['isWordBasedTest'] ?? false,
      targetWords: map['targetWords'],
    );
  }
}
