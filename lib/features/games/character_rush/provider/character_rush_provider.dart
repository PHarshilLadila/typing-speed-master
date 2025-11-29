// ignore_for_file: prefer_final_fields

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

        if (_gameStartTime != null) {
          final elapsed = DateTime.now().difference(_gameStartTime!).inSeconds;
          _gameDuration = elapsed;
        }

        if (_gameDuration >= 60) {
          endGame();
          return;
        }

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
    _positionUpdateTimer = Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      if (_isGameRunning) {
        _updateCharacterPositions();
      } else {
        timer.cancel();
      }
    });
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
      deltaTime = 0.016;
    }

    _lastUpdateTime = now;

    final List<int> charactersToRemove = [];
    bool needsNotify = false;

    for (int i = 0; i < _characterPositions.length; i++) {
      final speedFactor = _currentSpeed * 0.1 * deltaTime;
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
        _activeCharacters.removeAt(i);
        _characterPositions.removeAt(i);

        final basePoints = 10;
        final speedBonus = (_currentSpeed * 2).round();
        _score += basePoints + speedBonus;
        _charactersCollected++;

        if (_settings.soundEnabled) {}

        notifyListeners();
        return;
      }
    }
  }

  void endGame() {
    if (!_isGameRunning) return;

    _isGameRunning = false;
    _gameTimer?.cancel();
    _characterSpawnerTimer?.cancel();
    _positionUpdateTimer?.cancel();

    if (_gameStartTime != null) {
      final actualDuration =
          DateTime.now().difference(_gameStartTime!).inSeconds;
      _gameDuration = actualDuration;
    }

    if (_gameDuration >= 5) {
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
