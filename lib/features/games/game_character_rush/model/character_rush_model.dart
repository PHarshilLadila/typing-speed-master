class CharacterRushModel {
  final int score;
  final int charactersCollected;
  final DateTime timestamps;
  final int gameDuration;

  CharacterRushModel({
    required this.score,
    required this.charactersCollected,
    required this.gameDuration,
    required this.timestamps,
  });

  Map<String, dynamic> toJson() {
    return {
      "score": score,
      "charactersCollected": charactersCollected,
      "timestamps": timestamps.toIso8601String(),
      "gameDuration": gameDuration,
    };
  }

  factory CharacterRushModel.fromJson(Map<String, dynamic> json) {
    return CharacterRushModel(
      score: json['score'],
      charactersCollected: json['charactersCollected'],
      gameDuration: json['gameDuration'],
      timestamps: DateTime.parse(json['timestamps']),
    );
  }
}
