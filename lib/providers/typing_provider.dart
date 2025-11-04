// import 'dart:convert';
// import 'dart:math';
// import 'dart:developer' as dev;

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/typing_result.dart';
// import '../utils/constants.dart';

// class TypingProvider with ChangeNotifier {
//   List<TypingResult> _results = [];
//   bool _isLoading = false;
//   String _selectedDifficulty = 'Easy';
//   Duration _selectedDuration = Duration(seconds: 60);
//   List<String> _currentTextPool = [];
//   int _currentTextIndex = 0;

//   List<int> typingSpeedSamples = [];
//   List<DateTime> typingTimestamps = [];
//   int _lastCharCount = 0;

//   List<TypingResult> get results => _results;
//   bool get isLoading => _isLoading;
//   String get selectedDifficulty => _selectedDifficulty;
//   Duration get selectedDuration => _selectedDuration;

//   TypingProvider() {
//     _loadResults();
//     _initializeTextPool();
//   }

//   void _initializeTextPool() {
//     _currentTextPool = List.from(
//       AppConstants.sampleTextsByDifficulty[_selectedDifficulty] ?? [],
//     );
//     _currentTextIndex = 0;
//   }

//   void setDifficulty(String difficulty) {
//     _selectedDifficulty = difficulty;
//     _initializeTextPool();
//     notifyListeners();
//   }

//   void setDuration(Duration duration) {
//     _selectedDuration = duration;
//     notifyListeners();
//   }

//   String getCurrentText() {
//     if (_currentTextPool.isEmpty) {
//       _initializeTextPool();
//     }

//     String baseText = _currentTextPool[_currentTextIndex];

//     if (_selectedDuration.inSeconds == 0) {
//       return _generateWordBasedText(baseText);
//     }

//     return baseText;
//   }

//   String _generateWordBasedText(String baseText) {
//     List<String> words = baseText.split(' ');
//     List<String> extendedText = [];

//     while (extendedText.length < AppConstants.wordBasedTestWordCount) {
//       extendedText.addAll(words);
//     }

//     extendedText =
//         extendedText.take(AppConstants.wordBasedTestWordCount).toList();
//     return extendedText.join(' ');
//   }

//   void moveToNextText() {
//     _currentTextIndex = (_currentTextIndex + 1) % _currentTextPool.length;
//     notifyListeners();
//   }

//   void recordTypingSpeedSample(int charCount, DateTime timestamp) {
//     typingTimestamps.add(timestamp);

//     if (typingTimestamps.length > 1) {
//       final timeDiff =
//           timestamp
//               .difference(typingTimestamps[typingTimestamps.length - 2])
//               .inSeconds;
//       if (timeDiff > 0) {
//         final charsTyped = charCount - _lastCharCount;
//         final instantWPM = (charsTyped / 5) / (timeDiff / 60);
//         typingSpeedSamples.add(instantWPM.round());
//       }
//     }

//     _lastCharCount = charCount;
//   }

//   double calculateConsistency() {
//     if (typingSpeedSamples.length < 2) {
//       return 100.0;
//     }

//     final mean =
//         typingSpeedSamples.reduce((a, b) => a + b) / typingSpeedSamples.length;

//     if (mean == 0) return 0.0;

//     final variance =
//         typingSpeedSamples
//             .map((x) => pow(x - mean, 2))
//             .reduce((a, b) => a + b) /
//         typingSpeedSamples.length;
//     final standardDeviation = sqrt(variance);
//     final coefficientOfVariation = (standardDeviation / mean) * 100;

//     final consistency = max(0.0, 100.0 - coefficientOfVariation);

//     return double.parse(consistency.toStringAsFixed(2));
//   }

//   void resetConsistencyTracking() {
//     typingSpeedSamples.clear();
//     typingTimestamps.clear();
//     _lastCharCount = 0;
//   }

//   Future<void> _loadResults() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final resultsString = prefs.getString('typing_results');

//       if (resultsString != null) {
//         final List<dynamic> jsonList = json.decode(resultsString);
//         _results = jsonList.map((json) => TypingResult.fromMap(json)).toList();
//       }
//     } catch (e) {
//       dev.log('Error loading results: $e');
//       await _loadResultsOldFormat();
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> _loadResultsOldFormat() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final resultsString = prefs.getString('typing_results');

//       if (resultsString != null) {
//         final List<dynamic> resultsList =
//             (resultsString
//                 .split('||')
//                 .map((e) {
//                   try {
//                     return e.isNotEmpty
//                         ? Map<String, dynamic>.from(
//                           e.split(',').fold({}, (map, item) {
//                             final parts = item.split(':');
//                             if (parts.length == 2) {
//                               map[parts[0]] = parts[1];
//                             }
//                             return map;
//                           }),
//                         )
//                         : {};
//                   } catch (e) {
//                     dev.log("Error in loadResultsOldFormat => $e");
//                     return {};
//                   }
//                 })
//                 .where((map) => map.isNotEmpty)
//                 .toList());

//         _results = resultsList.map((map) => TypingResult.fromMap(map)).toList();
//       }
//     } catch (e) {
//       dev.log('Error loading old format results: $e');
//     }
//   }

//   Future<void> saveResult(TypingResult result) async {
//     _results.add(result);
//     _results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonString = json.encode(_results.map((r) => r.toMap()).toList());
//       await prefs.setString('typing_results', jsonString);
//     } catch (e) {
//       dev.log('Error saving result: $e');
//     }

//     notifyListeners();
//   }

//   void clearHistory() async {
//     _results.clear();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('typing_results');
//     notifyListeners();
//   }

//   double get averageWPM {
//     if (_results.isEmpty) return 0;
//     return _results.map((r) => r.wpm).reduce((a, b) => a + b) / _results.length;
//   }

//   double get averageAccuracy {
//     if (_results.isEmpty) return 0;
//     return _results.map((r) => r.accuracy).reduce((a, b) => a + b) /
//         _results.length;
//   }

//   double get averageConsistency {
//     if (_results.isEmpty) return 0;
//     return _results.map((r) => r.consistency).reduce((a, b) => a + b) /
//         _results.length;
//   }

//   int get totalTests => _results.length;

//   List<TypingResult> getRecentResults(int count) {
//     return _results.take(count).toList();
//   }

//   List<TypingResult> getAllRecentResults() {
//     return _results.toList();
//   }
// }
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isUserLoggedIn = false;

  TypingProvider() {
    _loadResults();
    _initializeTextPool();
    _checkAuthState();
  }

  void _checkAuthState() async {
    // Check initial auth state
    final session = _supabase.auth.currentSession;
    _isUserLoggedIn = session != null;

    // Listen for auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      _isUserLoggedIn = session != null;
      dev.log('Auth state changed: User logged in: $_isUserLoggedIn');

      if (_isUserLoggedIn) {
        // Sync local data to Supabase when user logs in
        WidgetsBinding.instance.addPostFrameCallback((_) {
          syncLocalResultsToSupabase();
        });
      }
    });
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
      // Check if user is logged in
      final session = _supabase.auth.currentSession;
      _isUserLoggedIn = session != null;

      if (_isUserLoggedIn) {
        await _loadResultsFromSupabase();
      } else {
        await _loadResultsFromLocal();
      }
    } catch (e) {
      dev.log('Error loading results: $e');
      // Fallback to local storage
      await _loadResultsFromLocal();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadResultsFromSupabase() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        await _loadResultsFromLocal();
        return;
      }

      dev.log('Loading results from Supabase for user: ${user.id}');

      final response = await _supabase
          .from('typing_results')
          .select()
          .eq('user_id', user.id)
          .order('timestamp', ascending: false);

      if (response != null && response is List) {
        _results =
            response
                .map((json) => _typingResultFromSupabaseJson(json))
                .toList();
        dev.log('Loaded ${_results.length} results from Supabase');

        // Also save to local storage for offline access
        await _saveAllResultsToLocal();
      }
    } catch (e) {
      dev.log('Error loading results from Supabase: $e');
      await _loadResultsFromLocal();
    }
  }

  Future<void> _loadResultsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsString = prefs.getString('typing_results');

      if (resultsString != null) {
        final List<dynamic> jsonList = json.decode(resultsString);
        _results = jsonList.map((json) => TypingResult.fromMap(json)).toList();
        dev.log('Loaded ${_results.length} results from local storage');
      }
    } catch (e) {
      dev.log('Error loading local results: $e');
      await _loadResultsOldFormat();
    }
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
      // Always save to local storage first
      await _saveResultToLocal(result);

      // If user is logged in, also save to Supabase
      if (_isUserLoggedIn) {
        await _saveResultToSupabase(result);
      }
    } catch (e) {
      dev.log('Error saving result: $e');
    }

    notifyListeners();
  }

  Future<void> _saveResultToLocal(TypingResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_results.map((r) => r.toMap()).toList());
      await prefs.setString('typing_results', jsonString);
      dev.log('Result saved to local storage');
    } catch (e) {
      dev.log('Error saving result to local: $e');
    }
  }

  Future<void> _saveAllResultsToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_results.map((r) => r.toMap()).toList());
      await prefs.setString('typing_results', jsonString);
      dev.log('All results saved to local storage');
    } catch (e) {
      dev.log('Error saving all results to local: $e');
    }
  }

  Future<void> _saveResultToSupabase(TypingResult result) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        dev.log('No user found, skipping Supabase save');
        return;
      }

      // Check if we have a valid session
      final session = _supabase.auth.currentSession;
      if (session == null) {
        dev.log('No active session, skipping Supabase save');
        return;
      }

      final resultData = {
        'user_id': user.id,
        'wpm': result.wpm,
        'accuracy': result.accuracy,
        'consistency': result.consistency,
        'correct_chars': result.correctChars,
        'incorrect_chars': result.incorrectChars,
        'total_chars': result.totalChars,
        'duration_in_seconds': result.duration.inSeconds,
        'difficulty': result.difficulty,
        'is_word_based_test': result.isWordBasedTest,
        'target_words': result.targetWords,
        'timestamp': result.timestamp.toIso8601String(),
      };

      dev.log('Attempting to save to Supabase: $resultData');

      final response =
          await _supabase
              .from('typing_results')
              .insert(resultData)
              .select(); // Add .select() to get the inserted data back

      dev.log('Supabase insert response: $response');

      if (response != null && response.isNotEmpty) {
        dev.log(
          'Result saved to Supabase successfully with ID: ${response[0]['id']}',
        );
      } else {
        dev.log('Supabase insert returned empty response');
      }
    } catch (e) {
      dev.log('Error saving result to Supabase: $e');
      // Log more details about the error
      if (e is PostgrestException) {
        dev.log('Postgrest error details: ${e.message}');
      }
    }
  }

  Future<void> verifySupabaseConnection() async {
    try {
      final user = _supabase.auth.currentUser;
      dev.log('Current user: ${user?.id}');

      final session = _supabase.auth.currentSession;
      dev.log('Current session: ${session != null}');

      // Test a simple query to verify connection
      final testResponse = await _supabase
          .from('typing_results')
          .select('count')
          .limit(1);

      dev.log('Supabase connection test: $testResponse');
    } catch (e) {
      dev.log('Supabase connection test failed: $e');
    }
  }

  Future<void> syncLocalResultsToSupabase() async {
    if (!_isUserLoggedIn) {
      dev.log('User not logged in, skipping sync');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsString = prefs.getString('typing_results');

      if (resultsString != null) {
        final List<dynamic> jsonList = json.decode(resultsString);
        final localResults =
            jsonList.map((json) => TypingResult.fromMap(json)).toList();

        dev.log('Syncing ${localResults.length} local results to Supabase');

        // Upload each local result to Supabase
        for (final result in localResults) {
          await _saveResultToSupabase(result);
        }

        dev.log(
          'Successfully synced ${localResults.length} local results to Supabase',
        );

        // Reload results from Supabase to get the complete set
        await _loadResultsFromSupabase();
      }
    } catch (e) {
      dev.log('Error syncing local results to Supabase: $e');
    }
  }

  void clearHistory() async {
    _results.clear();

    try {
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('typing_results');

      // Clear Supabase data if user is logged in
      if (_isUserLoggedIn) {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          await _supabase
              .from('typing_results')
              .delete()
              .eq('user_id', user.id);
          dev.log('Cleared Supabase history for user: ${user.id}');
        }
      }
    } catch (e) {
      dev.log('Error clearing history: $e');
    }

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

  // Helper method to convert Supabase JSON to TypingResult
  TypingResult _typingResultFromSupabaseJson(Map<String, dynamic> json) {
    return TypingResult(
      wpm: json['wpm'],
      accuracy: (json['accuracy'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
      correctChars: json['correct_chars'],
      incorrectChars: json['incorrect_chars'],
      totalChars: json['total_chars'],
      duration: Duration(seconds: json['duration_in_seconds']),
      timestamp: DateTime.parse(json['timestamp']),
      difficulty: json['difficulty'],
      isWordBasedTest: json['is_word_based_test'] ?? false,
      targetWords: json['target_words'],
    );
  }
}
