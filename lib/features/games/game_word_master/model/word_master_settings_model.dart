class WordMasterSettingsModel {
  final double initialSpeed;
  final double speedIncrement;
  final int maxWords;
  final bool soundEnabled;

  WordMasterSettingsModel({
    required this.initialSpeed,
    required this.speedIncrement,
    required this.maxWords,
    required this.soundEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      "initialSpeed": initialSpeed,
      "speedIncrement": speedIncrement,
      "maxWords": maxWords,
      "soundEnabled": soundEnabled,
    };
  }

  factory WordMasterSettingsModel.fromJson(Map<String, dynamic> json) {
    return WordMasterSettingsModel(
      initialSpeed: json['initialSpeed'],
      speedIncrement: json['speedIncrement'],
      maxWords: json['maxWords'],
      soundEnabled: json['soundEnabled'],
    );
  }

  WordMasterSettingsModel copyWith({
    double? initialSpeed,
    double? speedIncrement,
    int? maxWords,
    bool? soundEnabled,
  }) {
    return WordMasterSettingsModel(
      initialSpeed: initialSpeed ?? this.initialSpeed,
      speedIncrement: speedIncrement ?? this.speedIncrement,
      maxWords: maxWords ?? this.maxWords,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}
