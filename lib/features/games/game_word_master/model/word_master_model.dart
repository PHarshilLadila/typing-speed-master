class WordMasterModel {
  final int score;
  final int wordCollected;
  final DateTime timestamps;
  final int gameDuration;

  WordMasterModel({
    required this.score,
    required this.wordCollected,
    required this.timestamps,
    required this.gameDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      "score": score,
      "wordCollected": wordCollected,
      "timestamps": timestamps.toIso8601String(),
      "gameDuration": gameDuration,
    };
  }

  factory WordMasterModel.fromJson(Map<String, dynamic> json) {
    return WordMasterModel(
      score: json['score'],
      wordCollected: json['wordCollected'],
      timestamps: DateTime.parse(json['timestamps']),
      gameDuration: json['gameDuration'],
    );
  }
}
