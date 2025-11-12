// class TypingResult {
//   final int wpm;
//   final double accuracy;
//   final double consistency;
//   final int correctChars;
//   final int incorrectChars;
//   final int totalChars;
//   final Duration duration;
//   final DateTime timestamp;
//   final String difficulty;
//   final bool isWordBasedTest;
//   final int? targetWords;

//   TypingResult({
//     required this.wpm,
//     required this.accuracy,
//     required this.consistency,
//     required this.correctChars,
//     required this.incorrectChars,
//     required this.totalChars,
//     required this.duration,
//     required this.timestamp,
//     required this.difficulty,
//     this.isWordBasedTest = false,
//     this.targetWords,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'wpm': wpm,
//       'accuracy': accuracy,
//       'consistency': consistency,
//       'correctChars': correctChars,
//       'incorrectChars': incorrectChars,
//       'totalChars': totalChars,
//       'durationInSeconds': duration.inSeconds,
//       'timestamp': timestamp.millisecondsSinceEpoch,
//       'difficulty': difficulty,
//       'isWordBasedTest': isWordBasedTest,
//       'targetWords': targetWords,
//     };
//   }

//   factory TypingResult.fromMap(Map<String, dynamic> map) {
//     return TypingResult(
//       wpm: map['wpm'],
//       accuracy: map['accuracy'].toDouble(),
//       consistency: map['consistency'].toDouble(),
//       correctChars: map['correctChars'],
//       incorrectChars: map['incorrectChars'],
//       totalChars: map['totalChars'],
//       duration: Duration(seconds: map['durationInSeconds']),
//       timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
//       difficulty: map['difficulty'],
//       isWordBasedTest: map['isWordBasedTest'] ?? false,
//       targetWords: map['targetWords'],
//     );
//   }
//   Map<String, dynamic> toSupabaseJson() {
//     return {
//       'wpm': wpm,
//       'accuracy': accuracy,
//       'consistency': consistency,
//       'correct_chars': correctChars,
//       'incorrect_chars': incorrectChars,
//       'total_chars': totalChars,
//       'duration_in_seconds': duration.inSeconds,
//       'difficulty': difficulty,
//       'is_word_based_test': isWordBasedTest,
//       'target_words': targetWords,
//       'timestamp': timestamp.toIso8601String(),
//     };
//   }
// }

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
  final List<int> incorrectCharPositions;
  final String originalText; // Store the original text
  final String userInput; // Store the user's typed input

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
    this.incorrectCharPositions = const [],
    required this.originalText,
    required this.userInput,
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
      'incorrectCharPositions': incorrectCharPositions,
      'originalText': originalText,
      'userInput': userInput,
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
      incorrectCharPositions: List<int>.from(
        map['incorrectCharPositions'] ?? [],
      ),
      originalText: map['originalText'] ?? '',
      userInput: map['userInput'] ?? '',
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'wpm': wpm,
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
