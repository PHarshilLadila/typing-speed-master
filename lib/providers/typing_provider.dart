import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/typing_result.dart';
import '../utils/constants.dart';

class TypingProvider with ChangeNotifier {
  List<TypingResult> _results = [];
  bool _isLoading = false;
  String _selectedDifficulty = 'Medium';
  Duration _selectedDuration = Duration(seconds: 60);

  List<TypingResult> get results => _results;
  bool get isLoading => _isLoading;
  String get selectedDifficulty => _selectedDifficulty;
  Duration get selectedDuration => _selectedDuration;

  TypingProvider() {
    _loadResults();
  }

  void setDifficulty(String difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  void setDuration(Duration duration) {
    _selectedDuration = duration;
    notifyListeners();
  }

  String getCurrentText() {
    final index =
        _selectedDifficulty == 'Easy'
            ? 0
            : _selectedDifficulty == 'Medium'
            ? 1
            : 2;
    return AppConstants.sampleTexts[index % AppConstants.sampleTexts.length];
  }

  Future<void> _loadResults() async {
    _isLoading = true;
    notifyListeners();

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
                    return {};
                  }
                })
                .where((map) => map.isNotEmpty)
                .toList());

        _results = resultsList.map((map) => TypingResult.fromMap(map)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading results: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveResult(TypingResult result) async {
    _results.add(result);
    _results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsString = _results
          .map(
            (r) =>
                r.toMap().entries.map((e) => '${e.key}:${e.value}').join(','),
          )
          .join('||');

      await prefs.setString('typing_results', resultsString);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving result: $e');
      }
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

  int get totalTests => _results.length;

  List<TypingResult> getRecentResults(int count) {
    return _results.take(count).toList();
  }

  List<TypingResult> getAllRecentResults() {
    return _results.toList();
  }
}
