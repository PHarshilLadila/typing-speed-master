class WordMasterModel {
  final int score;
  final int wordCollected;
  final DateTime timestamps;
  final int gameDuration;

  WordMasterModel({
    required this.score,
    required this.wordCollected,
    required this.gameDuration,
    required this.timestamps,
  });

  Map<String, dynamic> toJson() {
    return {
      "score": score,
      "wordCollected": wordCollected,
      "timestamps": timestamps,
      "gameDuration": gameDuration,
    };
  }

  factory WordMasterModel.fromJson(Map<String, dynamic> json) {
    return WordMasterModel(
      score: json['score'],
      wordCollected: json['wordCollected'],
      gameDuration: json['gameDuration'],
      timestamps: json['timestamps'],
    );
  }
}
