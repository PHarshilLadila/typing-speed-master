class WordReflexRound {
  final String mainWord;
  final List<String> synonyms;
  final String similarLooking;
  final String relatedButWrong;

  WordReflexRound({
    required this.mainWord,
    required this.synonyms,
    required this.similarLooking,
    required this.relatedButWrong,
  });

  Map<String, dynamic> toJson() => {
    'mainWord': mainWord,
    'synonyms': synonyms,
    'similarLooking': similarLooking,
    'relatedButWrong': relatedButWrong,
  };

  factory WordReflexRound.fromJson(Map<String, dynamic> json) =>
      WordReflexRound(
        mainWord: json['mainWord'],
        synonyms: List<String>.from(json['synonyms']),
        similarLooking: json['similarLooking'],
        relatedButWrong: json['relatedButWrong'],
      );
}

class WordReflexResult {
  final int score;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeouts;
  final int totalRounds;
  final int gameDuration;
  final int streak;
  final DateTime timestamp;
  final List<WordReflexRoundResult> roundResults;

  WordReflexResult({
    required this.score,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeouts,
    required this.totalRounds,
    required this.gameDuration,
    required this.streak,
    required this.timestamp,
    required this.roundResults,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'correctAnswers': correctAnswers,
    'wrongAnswers': wrongAnswers,
    'timeouts': timeouts,
    'totalRounds': totalRounds,
    'gameDuration': gameDuration,
    'streak': streak,
    'timestamp': timestamp.toIso8601String(),
    'roundResults': roundResults.map((e) => e.toJson()).toList(),
  };

  factory WordReflexResult.fromJson(Map<String, dynamic> json) =>
      WordReflexResult(
        score: json['score'],
        correctAnswers: json['correctAnswers'],
        wrongAnswers: json['wrongAnswers'],
        timeouts: json['timeouts'],
        totalRounds: json['totalRounds'],
        gameDuration: json['gameDuration'],
        streak: json['streak'],
        timestamp: DateTime.parse(json['timestamp']),
        roundResults:
            (json['roundResults'] as List<dynamic>?)
                ?.map((e) => WordReflexRoundResult.fromJson(e))
                .toList() ??
            [],
      );
}

class WordReflexRoundResult {
  final String mainWord;
  final String correctAnswer;
  final String userAnswer;
  final bool isCorrect;

  WordReflexRoundResult({
    required this.mainWord,
    required this.correctAnswer,
    required this.userAnswer,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
    'mainWord': mainWord,
    'correctAnswer': correctAnswer,
    'userAnswer': userAnswer,
    'isCorrect': isCorrect,
  };

  factory WordReflexRoundResult.fromJson(Map<String, dynamic> json) =>
      WordReflexRoundResult(
        mainWord: json['mainWord'],
        correctAnswer: json['correctAnswer'],
        userAnswer: json['userAnswer'],
        isCorrect: json['isCorrect'],
      );
}
