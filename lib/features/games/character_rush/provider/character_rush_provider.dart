// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:typing_speed_master/features/games/character_rush/model/character_rush_model.dart';
// import 'package:typing_speed_master/features/games/character_rush/model/character_rush_settings_model.dart';

// class CharacterRushProvider with ChangeNotifier {
//   static const String _scoresKey = 'character_rush_game_scores';
//   static const String _settingsKey = 'character_rush_game_settings';

//   int _score = 0;
//   int _charactersCollected = 0;
//   bool _isGameRunning = false;
//   double _currentSpeed = 1.0;
//   int _gameDuration = 0;
//   Timer? _gameTimer;
//   Timer? _characterSpawnerTimer;
//   Timer? _positionUpdateTimer;
//   List<String> _activeCharacters = [];
//   List<Offset> _characterPositions = [];
//   DateTime? _gameStartTime;

//   CharacterRushSettingsModel _settings = CharacterRushSettingsModel(
//     initialSpeed: 1.0,
//     speedIncrement: 0.1,
//     maxCharacters: 5,
//     soundEnabled: true,
//   );

//   List<CharacterRushModel> _scores = [];

//   int get score => _score;
//   int get charactersCollected => _charactersCollected;
//   bool get isGameRunning => _isGameRunning;
//   double get currentSpeed => _currentSpeed;
//   int get gameDuration => _gameDuration;
//   List<String> get activeCharacters => _activeCharacters;
//   List<Offset> get characterPositions => _characterPositions;
//   CharacterRushSettingsModel get settings => _settings;
//   List<CharacterRushModel> get scores => _scores;

//   CharacterRushProvider() {
//     _loadSettings();
//     _loadScores();
//   }

//   Future<void> _loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     final settingsJson = prefs.getString(_settingsKey);

//     if (settingsJson != null) {
//       _settings = CharacterRushSettingsModel.fromJson(
//         json.decode(settingsJson),
//       );
//       _currentSpeed = _settings.initialSpeed;
//       notifyListeners();
//     }
//   }

//   Future<void> _saveSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_settingsKey, json.encode(_settings.toJson()));
//   }

//   Future<void> _loadScores() async {
//     final prefs = await SharedPreferences.getInstance();
//     final scoresJson = prefs.getStringList(_scoresKey);

//     if (scoresJson != null) {
//       _scores =
//           scoresJson
//               .map((json) => CharacterRushModel.fromJson(jsonDecode(json)))
//               .toList();
//       _scores.sort((a, b) => b.score.compareTo(a.score));
//       notifyListeners();
//     }
//   }

//   Future<void> _saveScore(CharacterRushModel score) async {
//     _scores.add(score);
//     _scores.sort((a, b) => b.score.compareTo(a.score));
//     if (_scores.length > 10) {
//       _scores = _scores.sublist(0, 10);
//     }

//     final prefs = await SharedPreferences.getInstance();
//     final scoresJson =
//         _scores.map((score) => json.encode(score.toJson())).toList();
//     await prefs.setStringList(_scoresKey, scoresJson);
//     notifyListeners();
//   }

//   void updateSettings(CharacterRushSettingsModel newSettings) {
//     _settings = newSettings;
//     _currentSpeed = _settings.initialSpeed;
//     _saveSettings();
//     notifyListeners();
//   }

//   Future<void> clearHistory() async {
//     _scores.clear();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_scoresKey);
//     notifyListeners();
//   }

//   void startGame() {
//     _resetGame();
//     _isGameRunning = true;
//     _gameStartTime = DateTime.now();
//     _startGameTimer();
//     _startCharacterSpawner();
//     _startPositionUpdates();
//     notifyListeners();
//   }

//   void _resetGame() {
//     _score = 0;
//     _charactersCollected = 0;
//     _currentSpeed = _settings.initialSpeed;
//     _gameDuration = 0;
//     _activeCharacters.clear();
//     _characterPositions.clear();
//     _gameTimer?.cancel();
//     _characterSpawnerTimer?.cancel();
//     _positionUpdateTimer?.cancel();
//     _gameStartTime = null;
//   }

//   void _startGameTimer() {
//     _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_isGameRunning) {
//         _gameDuration++;

//         // Calculate actual elapsed time from start
//         if (_gameStartTime != null) {
//           final elapsed = DateTime.now().difference(_gameStartTime!).inSeconds;
//           _gameDuration = elapsed;
//         }

//         // Increase speed every 15 seconds (instead of 10) for longer gameplay
//         if (_gameDuration % 15 == 0 && _gameDuration > 0) {
//           _currentSpeed += _settings.speedIncrement;
//           if (_currentSpeed > 5.0) _currentSpeed = 5.0;
//           notifyListeners();
//         }
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   void _startCharacterSpawner() {
//     // Fixed: Use a more controlled spawn rate based on current speed
//     final spawnInterval = Duration(
//       milliseconds: (2500 / _currentSpeed).round(),
//     );

//     _characterSpawnerTimer = Timer.periodic(spawnInterval, (timer) {
//       if (_isGameRunning &&
//           _activeCharacters.length < _settings.maxCharacters) {
//         _spawnCharacter();
//       } else if (!_isGameRunning) {
//         timer.cancel();
//       }
//     });
//   }

//   void _startPositionUpdates() {
//     _positionUpdateTimer = Timer.periodic(
//       const Duration(
//         milliseconds: 30,
//       ), // Increased frequency for smoother movement
//       (timer) {
//         if (_isGameRunning) {
//           _updateCharacterPositions();
//         } else {
//           timer.cancel();
//         }
//       },
//     );
//   }

//   void _spawnCharacter() {
//     final random = Random();
//     final characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
//     final character = characters[random.nextInt(characters.length)];

//     // Fixed: Ensure minimum distance between characters
//     double newX;
//     bool positionValid;
//     int attempts = 0;

//     do {
//       newX = random.nextDouble() * 0.7; // Reduced range for better spacing
//       positionValid = true;

//       // Check if new position is too close to existing characters
//       for (final position in _characterPositions) {
//         if ((position.dx - newX).abs() < 0.15) {
//           // Minimum horizontal spacing
//           positionValid = false;
//           break;
//         }
//       }

//       attempts++;
//     } while (!positionValid && attempts < 10);

//     _activeCharacters.add(character);
//     _characterPositions.add(
//       Offset(newX, -0.05),
//     ); // Start closer to top for smoother entry
//     notifyListeners();
//   }

//   // Update only the _updateCharacterPositions method in CharacterRushProvider
//   void _updateCharacterPositions() {
//     final List<int> charactersToRemove = [];
//     bool needsNotify = false;

//     for (int i = 0; i < _characterPositions.length; i++) {
//       // Fixed: Smoother speed calculation with consistent frame rate
//       final speedFactor =
//           _currentSpeed * 0.002; // Further reduced for smoother movement
//       final newY = _characterPositions[i].dy + speedFactor;

//       if (newY > 1.2) {
//         // Increased threshold for removal (below bottom)
//         charactersToRemove.add(i);
//       } else {
//         _characterPositions[i] = Offset(_characterPositions[i].dx, newY);
//         needsNotify = true;
//       }
//     }

//     // Remove characters that went below the bottom
//     for (int i = charactersToRemove.length - 1; i >= 0; i--) {
//       final index = charactersToRemove[i];
//       _activeCharacters.removeAt(index);
//       _characterPositions.removeAt(index);
//       needsNotify = true;
//     }

//     if (needsNotify) {
//       notifyListeners();
//     }
//   }

//   void checkCharacter(String typedChar) {
//     if (!_isGameRunning || typedChar.isEmpty) return;

//     final upperChar = typedChar.toUpperCase();

//     for (int i = 0; i < _activeCharacters.length; i++) {
//       if (_activeCharacters[i] == upperChar) {
//         // Character collected!
//         _activeCharacters.removeAt(i);
//         _characterPositions.removeAt(i);

//         // Fixed: Better scoring system
//         final basePoints = 10;
//         final speedBonus = (_currentSpeed * 2).round();
//         _score += basePoints + speedBonus;
//         _charactersCollected++;

//         if (_settings.soundEnabled) {
//           // Play collection sound
//         }

//         notifyListeners();
//         return;
//       }
//     }

//     // Fixed: Penalty for wrong character (optional)
//     // _score = (_score - 2).clamp(0, double.maxFinite.toInt());
//     // notifyListeners();
//   }

//   void endGame() {
//     if (!_isGameRunning) return;

//     _isGameRunning = false;
//     _gameTimer?.cancel();
//     _characterSpawnerTimer?.cancel();
//     _positionUpdateTimer?.cancel();

//     // Fixed: Ensure proper game duration calculation
//     if (_gameStartTime != null) {
//       final actualDuration =
//           DateTime.now().difference(_gameStartTime!).inSeconds;
//       _gameDuration = actualDuration;
//     }

//     // Save score if game was played for reasonable time
//     if (_gameDuration >= 5) {
//       // At least 5 seconds of gameplay
//       final gameScore = CharacterRushModel(
//         score: _score,
//         charactersCollected: _charactersCollected,
//         timestamps: DateTime.now(),
//         gameDuration: _gameDuration,
//       );
//       _saveScore(gameScore);
//     }

//     notifyListeners();
//   }

//   // Add method to manually end game when too many characters missed
//   void checkGameOver() {
//     // Game over if too many characters reach bottom in short time
//     // This is a safety mechanism, main game end is still manual/auto
//   }

//   @override
//   void dispose() {
//     _gameTimer?.cancel();
//     _characterSpawnerTimer?.cancel();
//     _positionUpdateTimer?.cancel();
//     super.dispose();
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typing_speed_master/features/games/character_rush/model/character_rush_model.dart';
import 'package:typing_speed_master/features/games/character_rush/model/character_rush_settings_model.dart';

class CharacterRushProvider with ChangeNotifier {
  static const String _scoresKey = 'character_rush_game_scores';
  static const String _settingsKey = 'character_rush_game_settings';

  int _score = 0;
  int _charactersCollected = 0;
  bool _isGameRunning = false;
  double _currentSpeed = 1.0;
  int _gameDuration = 0;
  Timer? _gameTimer;
  Timer? _characterSpawnerTimer;
  Timer? _positionUpdateTimer;
  List<String> _activeCharacters = [];
  List<Offset> _characterPositions = [];
  DateTime? _gameStartTime;
  DateTime? _lastUpdateTime;

  CharacterRushSettingsModel _settings = CharacterRushSettingsModel(
    initialSpeed: 1.0,
    speedIncrement: 0.1,
    maxCharacters: 5,
    soundEnabled: true,
  );

  List<CharacterRushModel> _scores = [];

  int get score => _score;
  int get charactersCollected => _charactersCollected;
  bool get isGameRunning => _isGameRunning;
  double get currentSpeed => _currentSpeed;
  int get gameDuration => _gameDuration;
  List<String> get activeCharacters => _activeCharacters;
  List<Offset> get characterPositions => _characterPositions;
  CharacterRushSettingsModel get settings => _settings;
  List<CharacterRushModel> get scores => _scores;

  CharacterRushProvider() {
    _loadSettings();
    _loadScores();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson != null) {
      _settings = CharacterRushSettingsModel.fromJson(
        json.decode(settingsJson),
      );
      _currentSpeed = _settings.initialSpeed;
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(_settings.toJson()));
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scoresJson = prefs.getStringList(_scoresKey);

    if (scoresJson != null) {
      _scores =
          scoresJson
              .map((json) => CharacterRushModel.fromJson(jsonDecode(json)))
              .toList();
      _scores.sort((a, b) => b.score.compareTo(a.score));
      notifyListeners();
    }
  }

  Future<void> _saveScore(CharacterRushModel score) async {
    _scores.add(score);
    _scores.sort((a, b) => b.score.compareTo(a.score));
    if (_scores.length > 10) {
      _scores = _scores.sublist(0, 10);
    }

    final prefs = await SharedPreferences.getInstance();
    final scoresJson =
        _scores.map((score) => json.encode(score.toJson())).toList();
    await prefs.setStringList(_scoresKey, scoresJson);
    notifyListeners();
  }

  void updateSettings(CharacterRushSettingsModel newSettings) {
    _settings = newSettings;
    _currentSpeed = _settings.initialSpeed;
    _saveSettings();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _scores.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoresKey);
    notifyListeners();
  }

  void startGame() {
    _resetGame();
    _isGameRunning = true;
    _gameStartTime = DateTime.now();
    _lastUpdateTime = DateTime.now();
    _startGameTimer();
    _startCharacterSpawner();
    _startPositionUpdates();
    notifyListeners();
  }

  void _resetGame() {
    _score = 0;
    _charactersCollected = 0;
    _currentSpeed = _settings.initialSpeed;
    _gameDuration = 0;
    _activeCharacters.clear();
    _characterPositions.clear();
    _gameTimer?.cancel();
    _characterSpawnerTimer?.cancel();
    _positionUpdateTimer?.cancel();
    _gameStartTime = null;
    _lastUpdateTime = null;
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isGameRunning) {
        _gameDuration++;

        // Calculate actual elapsed time from start
        if (_gameStartTime != null) {
          final elapsed = DateTime.now().difference(_gameStartTime!).inSeconds;
          _gameDuration = elapsed;
        }

        // FIXED: Auto end game after 60 seconds (1 minute)
        if (_gameDuration >= 60) {
          endGame();
          return;
        }

        // Increase speed every 15 seconds for longer gameplay
        if (_gameDuration % 15 == 0 && _gameDuration > 0) {
          _currentSpeed += _settings.speedIncrement;
          if (_currentSpeed > 5.0) _currentSpeed = 5.0;
          notifyListeners();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _startCharacterSpawner() {
    final spawnInterval = Duration(
      milliseconds: (2500 / _currentSpeed).round(),
    );

    _characterSpawnerTimer = Timer.periodic(spawnInterval, (timer) {
      if (_isGameRunning &&
          _activeCharacters.length < _settings.maxCharacters) {
        _spawnCharacter();
      } else if (!_isGameRunning) {
        timer.cancel();
      }
    });
  }

  void _startPositionUpdates() {
    _positionUpdateTimer = Timer.periodic(
      const Duration(milliseconds: 16), // 60 FPS for butter smooth animation
      (timer) {
        if (_isGameRunning) {
          _updateCharacterPositions();
        } else {
          timer.cancel();
        }
      },
    );
  }

  void _spawnCharacter() {
    final random = Random();
    final characters =
        'KZUPLHBRAMXCEOVGQNWTSFDIYJ'; // ABCDEFGHIJKLMNOPQRSTUVWXYZ
    final character = characters[random.nextInt(characters.length)];

    double newX;
    bool positionValid;
    int attempts = 0;

    do {
      newX = random.nextDouble() * 0.7;
      positionValid = true;

      for (final position in _characterPositions) {
        if ((position.dx - newX).abs() < 0.15) {
          positionValid = false;
          break;
        }
      }
      attempts++;
    } while (!positionValid && attempts < 10);

    _activeCharacters.add(character);
    _characterPositions.add(Offset(newX, -0.1));
    notifyListeners();
  }

  void _updateCharacterPositions() {
    final now = DateTime.now();
    final double deltaTime;

    if (_lastUpdateTime != null) {
      deltaTime = now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
    } else {
      deltaTime = 0.016; // Default to 60 FPS
    }

    _lastUpdateTime = now;

    final List<int> charactersToRemove = [];
    bool needsNotify = false;

    for (int i = 0; i < _characterPositions.length; i++) {
      // FIXED: Use delta time for frame-rate independent smooth movement
      final speedFactor =
          _currentSpeed * 0.1 * deltaTime; // Adjusted for smoothness
      final newY = _characterPositions[i].dy + speedFactor;

      if (newY > 1.2) {
        charactersToRemove.add(i);
      } else {
        _characterPositions[i] = Offset(_characterPositions[i].dx, newY);
        needsNotify = true;
      }
    }

    for (int i = charactersToRemove.length - 1; i >= 0; i--) {
      final index = charactersToRemove[i];
      _activeCharacters.removeAt(index);
      _characterPositions.removeAt(index);
      needsNotify = true;
    }

    if (needsNotify) {
      notifyListeners();
    }
  }

  void checkCharacter(String typedChar) {
    if (!_isGameRunning || typedChar.isEmpty) return;

    final upperChar = typedChar.toUpperCase();

    for (int i = 0; i < _activeCharacters.length; i++) {
      if (_activeCharacters[i] == upperChar) {
        // Character collected!
        _activeCharacters.removeAt(i);
        _characterPositions.removeAt(i);

        // Fixed: Better scoring system
        final basePoints = 10;
        final speedBonus = (_currentSpeed * 2).round();
        _score += basePoints + speedBonus;
        _charactersCollected++;

        if (_settings.soundEnabled) {
          // Play collection sound
        }

        notifyListeners();
        return;
      }
    }

    // Fixed: Penalty for wrong character (optional)
    // _score = (_score - 2).clamp(0, double.maxFinite.toInt());
    // notifyListeners();
  }

  void endGame() {
    if (!_isGameRunning) return;

    _isGameRunning = false;
    _gameTimer?.cancel();
    _characterSpawnerTimer?.cancel();
    _positionUpdateTimer?.cancel();

    // Fixed: Ensure proper game duration calculation
    if (_gameStartTime != null) {
      final actualDuration =
          DateTime.now().difference(_gameStartTime!).inSeconds;
      _gameDuration = actualDuration;
    }

    // Save score if game was played for reasonable time
    if (_gameDuration >= 5) {
      // At least 5 seconds of gameplay
      final gameScore = CharacterRushModel(
        score: _score,
        charactersCollected: _charactersCollected,
        timestamps: DateTime.now(),
        gameDuration: _gameDuration,
      );
      _saveScore(gameScore);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _characterSpawnerTimer?.cancel();
    _positionUpdateTimer?.cancel();
    super.dispose();
  }
}
