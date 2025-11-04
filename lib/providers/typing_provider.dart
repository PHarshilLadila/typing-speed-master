import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/typing_result.dart';
import '../utils/constants.dart';

class TypingProvider with ChangeNotifier {
  List<TypingResult> _results = [];
  bool _isLoading = false;
  String _selectedDifficulty = 'Easy';
  Duration _selectedDuration = Duration(seconds: 60);
  List<String> _currentTextPool = [];
  int _currentTextIndex = 0;

  List<int> typingSpeedSamples = [];
  List<DateTime> typingTimestamps = [];
  int _lastCharCount = 0;

  List<TypingResult> get results => _results;
  bool get isLoading => _isLoading;
  String get selectedDifficulty => _selectedDifficulty;
  Duration get selectedDuration => _selectedDuration;

  TypingProvider() {
    _loadResults();
    _initializeTextPool();
  }

  void _initializeTextPool() {
    _currentTextPool = List.from(
      AppConstants.sampleTextsByDifficulty[_selectedDifficulty] ?? [],
    );
    _currentTextIndex = 0;
  }

  void setDifficulty(String difficulty) {
    _selectedDifficulty = difficulty;
    _initializeTextPool();
    notifyListeners();
  }

  void setDuration(Duration duration) {
    _selectedDuration = duration;
    notifyListeners();
  }

  String getCurrentText() {
    if (_currentTextPool.isEmpty) {
      _initializeTextPool();
    }

    String baseText = _currentTextPool[_currentTextIndex];

    if (_selectedDuration.inSeconds == 0) {
      return _generateWordBasedText(baseText);
    }

    return baseText;
  }

  String _generateWordBasedText(String baseText) {
    List<String> words = baseText.split(' ');
    List<String> extendedText = [];

    while (extendedText.length < AppConstants.wordBasedTestWordCount) {
      extendedText.addAll(words);
    }

    extendedText =
        extendedText.take(AppConstants.wordBasedTestWordCount).toList();
    return extendedText.join(' ');
  }

  void moveToNextText() {
    _currentTextIndex = (_currentTextIndex + 1) % _currentTextPool.length;
    notifyListeners();
  }

  void recordTypingSpeedSample(int charCount, DateTime timestamp) {
    typingTimestamps.add(timestamp);

    if (typingTimestamps.length > 1) {
      final timeDiff =
          timestamp
              .difference(typingTimestamps[typingTimestamps.length - 2])
              .inSeconds;
      if (timeDiff > 0) {
        final charsTyped = charCount - _lastCharCount;
        final instantWPM = (charsTyped / 5) / (timeDiff / 60);
        typingSpeedSamples.add(instantWPM.round());
      }
    }

    _lastCharCount = charCount;
  }

  double calculateConsistency() {
    if (typingSpeedSamples.length < 2) {
      return 100.0;
    }

    final mean =
        typingSpeedSamples.reduce((a, b) => a + b) / typingSpeedSamples.length;

    if (mean == 0) return 0.0;

    final variance =
        typingSpeedSamples
            .map((x) => pow(x - mean, 2))
            .reduce((a, b) => a + b) /
        typingSpeedSamples.length;
    final standardDeviation = sqrt(variance);
    final coefficientOfVariation = (standardDeviation / mean) * 100;

    final consistency = max(0.0, 100.0 - coefficientOfVariation);

    return double.parse(consistency.toStringAsFixed(2));
  }

  void resetConsistencyTracking() {
    typingSpeedSamples.clear();
    typingTimestamps.clear();
    _lastCharCount = 0;
  }

  Future<void> _loadResults() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsString = prefs.getString('typing_results');

      if (resultsString != null) {
        final List<dynamic> jsonList = json.decode(resultsString);
        _results = jsonList.map((json) => TypingResult.fromMap(json)).toList();
      }
    } catch (e) {
      dev.log('Error loading results: $e');
      await _loadResultsOldFormat();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadResultsOldFormat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsString = prefs.getString('typing_results');

      if (resultsString != null) {
        final List<dynamic> resultsList =
            (resultsString
                .split('||')
                .map((e) {
                  try {
                    return e.isNotEmpty
                        ? Map<String, dynamic>.from(
                          e.split(',').fold({}, (map, item) {
                            final parts = item.split(':');
                            if (parts.length == 2) {
                              map[parts[0]] = parts[1];
                            }
                            return map;
                          }),
                        )
                        : {};
                  } catch (e) {
                    dev.log("Error in loadResultsOldFormat => $e");
                    return {};
                  }
                })
                .where((map) => map.isNotEmpty)
                .toList());

        _results = resultsList.map((map) => TypingResult.fromMap(map)).toList();
      }
    } catch (e) {
      dev.log('Error loading old format results: $e');
    }
  }

  Future<void> saveResult(TypingResult result) async {
    _results.add(result);
    _results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_results.map((r) => r.toMap()).toList());
      await prefs.setString('typing_results', jsonString);
    } catch (e) {
      dev.log('Error saving result: $e');
    }

    notifyListeners();
  }

  void clearHistory() async {
    _results.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('typing_results');
    notifyListeners();
  }

  double get averageWPM {
    if (_results.isEmpty) return 0;
    return _results.map((r) => r.wpm).reduce((a, b) => a + b) / _results.length;
  }

  double get averageAccuracy {
    if (_results.isEmpty) return 0;
    return _results.map((r) => r.accuracy).reduce((a, b) => a + b) /
        _results.length;
  }

  double get averageConsistency {
    if (_results.isEmpty) return 0;
    return _results.map((r) => r.consistency).reduce((a, b) => a + b) /
        _results.length;
  }

  int get totalTests => _results.length;

  List<TypingResult> getRecentResults(int count) {
    return _results.take(count).toList();
  }

  List<TypingResult> getAllRecentResults() {
    return _results.toList();
  }
}
