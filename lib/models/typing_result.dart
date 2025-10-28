class TypingResult {
  final int wpm;
  final double accuracy;
  final int correctChars;
  final int incorrectChars;
  final int totalChars;
  final Duration duration;
  final DateTime timestamp;
  final String difficulty;

  TypingResult({
    required this.wpm,
    required this.accuracy,
    required this.correctChars,
    required this.incorrectChars,
    required this.totalChars,
    required this.duration,
    required this.timestamp,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return {
      'wpm': wpm,
      'accuracy': accuracy,
      'correctChars': correctChars,
      'incorrectChars': incorrectChars,
      'totalChars': totalChars,
      'duration': duration.inSeconds,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'difficulty': difficulty,
    };
  }

  factory TypingResult.fromMap(Map<String, dynamic> map) {
    return TypingResult(
      wpm: _parseInt(map['wpm']),
      accuracy: _parseDouble(map['accuracy']),
      correctChars: _parseInt(map['correctChars']),
      incorrectChars: _parseInt(map['incorrectChars']),
      totalChars: _parseInt(map['totalChars']),
      duration: Duration(seconds: _parseInt(map['duration'])),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        _parseInt(map['timestamp']),
      ),
      difficulty: map['difficulty']?.toString() ?? 'Unknown',
    );
  }
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
