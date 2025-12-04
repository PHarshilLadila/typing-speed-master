// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typing_speed_master/features/games/word_master/model/word_master_model.dart';
import 'package:typing_speed_master/features/games/word_master/model/word_master_settings_model.dart';
import 'package:typing_speed_master/utils/constants.dart';

class WordMasterProvider with ChangeNotifier {
  static const String _scoresKey = 'word_master_game_scores';
  static const String _settingsKey = 'word_master_game_settings';

  int _score = 0;
  int _wordsCollected = 0;
  bool _isGameRunning = false;
  bool _isGamePaused = false;

  double _currentSpeed = 1.0;
  int _gameDuration = 0;
  Timer? _gameTimer;
  int _selectedGameTime = 60;
  Timer? _wordSpawnerTimer;
  Timer? _positionUpdateTimer;
  List<String> _activeWords = [];
  List<Offset> _wordPositions = [];
  DateTime? _gameStartTime;
  DateTime? _lastUpdateTime;
  String _currentTypedWord = '';
  bool _isWrongWord = false;
  Timer? _wrongWordTimer;
  VoidCallback? _onWordCollectedCallback;

  final List<int> _gameTimeOptions = [30, 60, 120, 180, 240, 300];

  WordMasterSettingsModel _settings = WordMasterSettingsModel(
    initialSpeed: 1.0,
    speedIncrement: 0.1,
    maxWords: 5,
    soundEnabled: true,
  );

  List<WordMasterModel> _scores = [];

  int get score => _score;
  int get wordsCollected => _wordsCollected;
  bool get isGameRunning => _isGameRunning;
  bool get isGamePaused => _isGamePaused;
  double get currentSpeed => _currentSpeed;
  int get gameDuration => _gameDuration;
  int get selectedGameTime => _selectedGameTime;
  List<int> get gameTimeOptions => _gameTimeOptions;
  List<String> get activeWords => _activeWords;
  List<Offset> get wordPositions => _wordPositions;
  WordMasterSettingsModel get settings => _settings;
  List<WordMasterModel> get scores => _scores;
  String get currentTypedWord => _currentTypedWord;
  bool get isWrongWord => _isWrongWord;

  WordMasterProvider() {
    _loadSettings();
    _loadScores();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson != null) {
      _settings = WordMasterSettingsModel.fromJson(json.decode(settingsJson));
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
              .map((json) => WordMasterModel.fromJson(jsonDecode(json)))
              .toList();
      _scores.sort((a, b) => b.score.compareTo(a.score));
      notifyListeners();
    }
  }

  Future<void> _saveScore(WordMasterModel score) async {
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

  void updateTypedWord(String value) {
    if (!_isGameRunning || _isGamePaused) return;

    _currentTypedWord = value;

    _checkForExactMatch();
    _checkForWrongWord();

    notifyListeners();
  }

  // void _checkForExactMatch() {
  //   if (_currentTypedWord.isEmpty) return;

  //   for (int i = 0; i < _activeWords.length; i++) {
  //     if (_activeWords[i] == _currentTypedWord) {
  //       // Word matched successfully
  //       _activeWords.removeAt(i);
  //       _wordPositions.removeAt(i);

  //       final basePoints = 10;
  //       final speedBonus = (_currentSpeed * 2).round();
  //       _score += basePoints + speedBonus;
  //       _wordsCollected++;

  //       // Reset typed word
  //       _currentTypedWord = '';
  //       _isWrongWord = false;

  //       if (_settings.soundEnabled) {
  //         // Play success sound
  //       }

  //       notifyListeners();
  //       return;
  //     }
  //   }
  // }

  void setWordCollectedCallback(VoidCallback callback) {
    _onWordCollectedCallback = callback;
  }

  // In WordMasterProvider, update _checkForExactMatch method:
  void _checkForExactMatch() {
    if (_currentTypedWord.isEmpty) return;

    for (int i = 0; i < _activeWords.length; i++) {
      if (_activeWords[i] == _currentTypedWord) {
        // Word matched successfully
        _activeWords.removeAt(i);
        _wordPositions.removeAt(i);

        final basePoints = 10;
        final speedBonus = (_currentSpeed * 2).round();
        _score += basePoints + speedBonus;
        _wordsCollected++;

        // Call the callback to clear text field
        if (_onWordCollectedCallback != null) {
          _onWordCollectedCallback!();
        }

        // Reset typed word
        _currentTypedWord = '';
        _isWrongWord = false;

        if (_settings.soundEnabled) {
          // Play success sound
        }

        notifyListeners();
        return;
      }
    }
  }

  void _checkForWrongWord() {
    if (_currentTypedWord.isEmpty) {
      _isWrongWord = false;
      return;
    }

    bool hasMatchingPrefix = false;

    for (final word in _activeWords) {
      if (word.startsWith(_currentTypedWord)) {
        hasMatchingPrefix = true;
        break;
      }
    }

    _isWrongWord = !hasMatchingPrefix && _currentTypedWord.isNotEmpty;

    if (_isWrongWord) {
      _wrongWordTimer?.cancel();
      _wrongWordTimer = Timer(const Duration(milliseconds: 500), () {
        _isWrongWord = false;
        notifyListeners();
      });
    }

    notifyListeners();
  }

  void clearTypedWord() {
    _currentTypedWord = '';
    _isWrongWord = false;
    notifyListeners();
  }

  // Also update the checkWords method to use the new approach:
  void checkWords(String value) {
    updateTypedWord(value);
  }

  void updateSettings(WordMasterSettingsModel newSettings) {
    _settings = newSettings;
    _currentSpeed = _settings.initialSpeed;
    _saveSettings();
    notifyListeners();
  }

  void updateGameTime(int newTime) {
    _selectedGameTime = newTime;
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
    _isGamePaused = false;
    _isGameRunning = true;
    _gameStartTime = DateTime.now();
    _lastUpdateTime = DateTime.now();
    _startGameTimer();
    _startWordSpawner();
    _startPositionUpdates();
    notifyListeners();
  }

  void pauseGame() {
    if (_isGameRunning && !_isGamePaused) {
      _isGamePaused = true;
      _gameTimer?.cancel();
      _wordSpawnerTimer?.cancel();
      _positionUpdateTimer?.cancel();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_isGameRunning && _isGamePaused) {
      _isGamePaused = false;
      _lastUpdateTime = DateTime.now();
      _startGameTimer();
      _startWordSpawner();
      _startPositionUpdates();
      notifyListeners();
    }
  }

  void _resetGame() {
    _score = 0;
    _wordsCollected = 0;
    _currentSpeed = _settings.initialSpeed;
    _gameDuration = 0;
    _activeWords.clear();
    _wordPositions.clear();
    _gameTimer?.cancel();
    _wordSpawnerTimer?.cancel();
    _positionUpdateTimer?.cancel();
    _gameStartTime = null;
    _lastUpdateTime = null;
    _isGamePaused = false;
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isGameRunning && !_isGamePaused) {
        _gameDuration++;

        if (_gameStartTime != null) {
          final elapsed = DateTime.now().difference(_gameStartTime!).inSeconds;
          _gameDuration = elapsed;
        }

        if (_gameDuration >= _selectedGameTime) {
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

  void _startWordSpawner() {
    final spawnInterval = Duration(
      milliseconds: (2500 / _currentSpeed).round(),
    );

    _wordSpawnerTimer = Timer.periodic(spawnInterval, (timer) {
      if (_isGameRunning &&
          !_isGamePaused &&
          _activeWords.length < _settings.maxWords) {
        _spawnWord();
      } else if (!_isGameRunning) {
        timer.cancel();
      }
    });
  }

  void _startPositionUpdates() {
    _positionUpdateTimer = Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      if (_isGameRunning && !_isGamePaused) {
        _updateWordPositions();
      } else {
        timer.cancel();
      }
    });
  }

  void _spawnWord() {
    final random = Random();
    final List<String> words =
        AppConstants.easyWords + AppConstants.mediumWords;
    final word = words[random.nextInt(words.length)];

    double newX;
    bool positionValid;
    int attempts = 0;

    do {
      newX = random.nextDouble() * 0.7;
      positionValid = true;

      for (final position in _wordPositions) {
        if ((position.dx - newX).abs() < 0.15) {
          positionValid = false;
          break;
        }
      }
      attempts++;
    } while (!positionValid && attempts < 10);

    _activeWords.add(word);
    _wordPositions.add(Offset(newX, -0.1));
    notifyListeners();
  }

  void _updateWordPositions() {
    final now = DateTime.now();
    final double deltaTime;

    if (_lastUpdateTime != null) {
      deltaTime = now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
    } else {
      deltaTime = 0.016;
    }

    _lastUpdateTime = now;

    final List<int> wordsToRemove = [];
    bool needsNotify = false;

    for (int i = 0; i < _wordPositions.length; i++) {
      final speedFactor = _currentSpeed * 0.1 * deltaTime;
      final newY = _wordPositions[i].dy + speedFactor;

      if (newY > 1.2) {
        wordsToRemove.add(i);
      } else {
        _wordPositions[i] = Offset(_wordPositions[i].dx, newY);
        needsNotify = true;
      }
    }

    for (int i = wordsToRemove.length - 1; i >= 0; i--) {
      final index = wordsToRemove[i];
      _activeWords.removeAt(index);
      _wordPositions.removeAt(index);
      needsNotify = true;
    }

    if (needsNotify) {
      notifyListeners();
    }
  }

  // void checkWords(String typedWord) {
  //   if (!_isGameRunning || _isGamePaused || typedWord.isEmpty) return;

  //   final upperWord = typedWord.toUpperCase();

  //   for (int i = 0; i < _activeWords.length; i++) {
  //     if (_activeWords[i] == upperWord) {
  //       _activeWords.removeAt(i);
  //       _wordPositions.removeAt(i);

  //       final basePoints = 10;
  //       final speedBonus = (_currentSpeed * 2).round();
  //       _score += basePoints + speedBonus;
  //       _wordsCollected++;

  //       if (_settings.soundEnabled) {}

  //       notifyListeners();
  //       return;
  //     }
  //   }
  // }

  void endGame() {
    if (!_isGameRunning) return;

    _isGameRunning = false;
    _isGamePaused = false;
    _gameTimer?.cancel();
    _wordSpawnerTimer?.cancel();
    _positionUpdateTimer?.cancel();

    if (_gameStartTime != null) {
      final actualDuration =
          DateTime.now().difference(_gameStartTime!).inSeconds;
      _gameDuration = actualDuration;
    }

    if (_gameDuration >= 5) {
      final gameScore = WordMasterModel(
        score: _score,
        wordCollected: _wordsCollected,
        timestamps: DateTime.now(),
        gameDuration: _gameDuration,
      );
      _saveScore(gameScore);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _wrongWordTimer?.cancel();
    _gameTimer?.cancel();
    _wordSpawnerTimer?.cancel();
    _positionUpdateTimer?.cancel();
    super.dispose();
  }
}
