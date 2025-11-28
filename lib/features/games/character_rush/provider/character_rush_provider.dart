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

  // Add clear history method
  Future<void> clearHistory() async {
    _scores.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoresKey);
    notifyListeners();
  }

  void startGame() {
    _resetGame();
    _isGameRunning = true;
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
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isGameRunning) {
        _gameDuration++;
        // Increase speed every 10 seconds
        if (_gameDuration % 10 == 0) {
          _currentSpeed += _settings.speedIncrement;
          if (_currentSpeed > 5.0) _currentSpeed = 5.0; // Cap max speed
        }
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void _startCharacterSpawner() {
    _characterSpawnerTimer = Timer.periodic(
      Duration(milliseconds: (2000 / _currentSpeed).round()),
      (timer) {
        if (_isGameRunning &&
            _activeCharacters.length < _settings.maxCharacters) {
          _spawnCharacter();
        } else if (!_isGameRunning) {
          timer.cancel();
        }
      },
    );
  }

  void _startPositionUpdates() {
    _positionUpdateTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60 FPS
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
    final characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final character = characters[random.nextInt(characters.length)];

    _activeCharacters.add(character);
    _characterPositions.add(
      Offset(
        random.nextDouble() * 0.8, // Random x position (0 to 0.8)
        0.0, // Start from top
      ),
    );
    notifyListeners();
  }

  void _updateCharacterPositions() {
    for (int i = _characterPositions.length - 1; i >= 0; i--) {
      final newY = _characterPositions[i].dy + (_currentSpeed * 0.005);

      if (newY > 1.0) {
        // Character reached bottom - remove it
        _activeCharacters.removeAt(i);
        _characterPositions.removeAt(i);
      } else {
        _characterPositions[i] = Offset(_characterPositions[i].dx, newY);
      }
    }
    notifyListeners();
  }

  // Public method for manual position updates (for WidgetsBinding)
  void updateCharacterPositions(Size gameAreaSize) {
    if (_isGameRunning) {
      _updateCharacterPositions();
    }
  }

  void checkCharacter(String typedChar) {
    if (!_isGameRunning) return;

    final upperChar = typedChar.toUpperCase();

    for (int i = 0; i < _activeCharacters.length; i++) {
      if (_activeCharacters[i] == upperChar) {
        // Character collected!
        _activeCharacters.removeAt(i);
        _characterPositions.removeAt(i);
        _score += (10 * _currentSpeed).round();
        _charactersCollected++;

        if (_settings.soundEnabled) {
          // Play collection sound (you can add audio later)
        }

        notifyListeners();
        return;
      }
    }
  }

  void endGame() {
    _isGameRunning = false;
    _gameTimer?.cancel();
    _characterSpawnerTimer?.cancel();
    _positionUpdateTimer?.cancel();

    // Save score if any characters were collected
    if (_charactersCollected > 0) {
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
