class CharacterRushSettingsModel {
  final double initialSpeed;
  final double speedIncrement;
  final int maxCharacters;
  final bool soundEnabled;

  CharacterRushSettingsModel({
    required this.initialSpeed,
    required this.speedIncrement,
    required this.maxCharacters,
    required this.soundEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      "initialSpeed": initialSpeed,
      "speedIncrement": speedIncrement,
      "maxCharacters": maxCharacters,
      "soundEnabled": soundEnabled,
    };
  }

  factory CharacterRushSettingsModel.fromJson(Map<String, dynamic> json) {
    return CharacterRushSettingsModel(
      initialSpeed: json['initialSpeed'],
      speedIncrement: json['speedIncrement'],
      maxCharacters: json['maxCharacters'],
      soundEnabled: json['soundEnabled'],
    );
  }

  CharacterRushSettingsModel copyWith({
    double? initialSpeed,
    double? speedIncrement,
    int? maxCharacters,
    bool? soundEnabled,
  }) {
    return CharacterRushSettingsModel(
      initialSpeed: initialSpeed ?? this.initialSpeed,
      speedIncrement: speedIncrement ?? this.speedIncrement,
      maxCharacters: maxCharacters ?? this.maxCharacters,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}
