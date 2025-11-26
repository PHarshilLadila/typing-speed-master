import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:typing_speed_master/providers/activity_provider.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import '../models/typing_result.dart';
import '../utils/constants.dart';

class TypingProvider with ChangeNotifier {
  List<TypingResult> _results = [];
  bool _isLoading = false;
  String _selectedDifficulty = 'Easy';
  Duration _selectedDuration = Duration(seconds: 60);
  List<String> _currentTextPool = [];
  int _currentTextIndex = 0;
  Random random = Random();

  List<int> typingSpeedSamples = [];
  List<DateTime> typingTimestamps = [];
  int _lastCharCount = 0;
  String _currentOriginalText = '';
  String _currentUserInput = '';

  List<TypingResult> get results => _results;
  bool get isLoading => _isLoading;
  String get selectedDifficulty => _selectedDifficulty;
  Duration get selectedDuration => _selectedDuration;
  String get currentOriginalText => _currentOriginalText;
  String get currentUserInput => _currentUserInput;

  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isUserLoggedIn = false;

  TypingProvider() {
    _loadResults();
    _initializeTextPool();
    _checkAuthState();
  }

  void _checkAuthState() async {
    final session = _supabase.auth.currentSession;
    _isUserLoggedIn = session != null;

    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      _isUserLoggedIn = session != null;
      dev.log('Auth state changed: User logged in: $_isUserLoggedIn');

      if (_isUserLoggedIn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {});
      }
    });
  }

  void _initializeTextPool() {
    final availableTexts =
        AppConstants.sampleTextsByDifficulty[_selectedDifficulty] ?? [];

    if (availableTexts.isEmpty) {
      _currentTextPool = [
        "No text available for this difficulty. Please select another difficulty level.",
      ];
    } else {
      _currentTextPool = List.from(availableTexts);
      _currentTextPool.shuffle(random);
    }

    _currentTextIndex = 0;
    // _currentOriginalText = getCurrentText();
    dev.log(
      'Initialized text pool for $_selectedDifficulty with ${_currentTextPool.length} texts',
    );
  }

  void setDifficulty(String difficulty) {
    if (_selectedDifficulty != difficulty) {
      _selectedDifficulty = difficulty;
      dev.log('Difficulty changed to: $difficulty');
      _initializeTextPool();
      notifyListeners();
    }
  }

  void setDuration(Duration duration) {
    _selectedDuration = duration;
    notifyListeners();
  }

  String getCurrentText() {
    if (_currentTextPool.isEmpty) {
      _initializeTextPool();
    }

    if (_currentTextIndex >= _currentTextPool.length) {
      _currentTextIndex = 0;
    }

    String baseText = _currentTextPool[_currentTextIndex];
    String generatedText;

    // Word-based test માટે
    if (_selectedDuration.inSeconds == 0) {
      generatedText = _generateWordBasedText(baseText);
    } else {
      // Time-based test માટે - duration પ્રમાણે text extend કરો
      generatedText = _generateTimeBasedText(
        baseText,
        _selectedDuration.inSeconds,
      );
    }

    // ✅ CRITICAL FIX: Generated text ને _currentOriginalText માં save કરો
    // આથી comparison સમયે સાચો text use થશે
    _currentOriginalText = generatedText;

    return generatedText;
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

  String _generateTimeBasedText(String baseText, int durationSeconds) {
    // Average typing speed: 40 WPM
    // Conservative estimate: 40 WPM (0.67 words per second)
    // Safety margin: 1.5x for comfortable typing
    int estimatedWordsNeeded = ((durationSeconds * 0.67) * 1.5).ceil();

    // Minimum words based on duration (1 word per 2 seconds)
    int minWords = (durationSeconds / 2).ceil();
    estimatedWordsNeeded =
        estimatedWordsNeeded < minWords ? minWords : estimatedWordsNeeded;

    List<String> words = baseText.split(' ');

    // જો base text પહેલેથી જ પૂરતું લાંબું છે
    if (words.length >= estimatedWordsNeeded) {
      return baseText;
    }

    // Text ને repeat કરીને પૂરતું લાંબુ બનાવો
    List<String> extendedText = [];
    int repetitions = (estimatedWordsNeeded / words.length).ceil() + 1;

    for (int i = 0; i < repetitions; i++) {
      extendedText.addAll(words);

      // જો પૂરતા words થઈગયા હોય તો break
      if (extendedText.length >= estimatedWordsNeeded) {
        break;
      }
    }

    // Exact needed words લો
    extendedText = extendedText.take(estimatedWordsNeeded).toList();
    return extendedText.join(' ');
  }

  void moveToNextText() {
    _currentTextIndex = (_currentTextIndex + 1) % _currentTextPool.length;
    // getCurrentText() automatically updates _currentOriginalText
    getCurrentText();
    dev.log(
      'Moved to next text. Index: $_currentTextIndex, Difficulty: $_selectedDifficulty',
    );
    notifyListeners();
  }

  void getRandomText() {
    if (_currentTextPool.isNotEmpty) {
      _currentTextIndex = random.nextInt(_currentTextPool.length);
      // getCurrentText() automatically updates _currentOriginalText
      getCurrentText();
      dev.log(
        'Selected random text. Index: $_currentTextIndex, Difficulty: $_selectedDifficulty',
      );
      notifyListeners();
    }
  }

  void updateUserInput(String userInput) {
    _currentUserInput = userInput;
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
    _currentUserInput = '';
  }

  List<int> calculateIncorrectCharPositions(
    String userInput,
    String originalText,
  ) {
    List<int> incorrectPositions = [];

    int minLength =
        userInput.length < originalText.length
            ? userInput.length
            : originalText.length;

    for (int i = 0; i < minLength; i++) {
      if (userInput[i] != originalText[i]) {
        incorrectPositions.add(i);
      }
    }

    for (int i = originalText.length; i < userInput.length; i++) {
      incorrectPositions.add(i);
    }

    return incorrectPositions;
  }

  Future<void> saveResultWithErrorTracking(
    String userInput,
    String originalText,
  ) async {
    final endTime = DateTime.now();
    final duration =
        _selectedDuration.inSeconds == 0
            ? endTime.difference(DateTime.now().subtract(Duration(seconds: 1)))
            : _selectedDuration;

    final words = userInput.split(' ').where((word) => word.isNotEmpty).length;
    final wpm =
        _selectedDuration.inSeconds == 0
            ? (words / (duration.inSeconds / 60)).round()
            : (words / (_selectedDuration.inSeconds / 60)).round();

    final incorrectCharPositions = calculateIncorrectCharPositions(
      userInput,
      originalText,
    );

    int correctChars = userInput.length - incorrectCharPositions.length;
    int incorrectChars = incorrectCharPositions.length;
    int totalChars = userInput.length;

    final accuracy = totalChars > 0 ? (correctChars / totalChars) * 100 : 0.0;
    final consistency = calculateConsistency();

    final result = TypingResult(
      wpm: wpm,
      accuracy: accuracy,
      consistency: consistency,
      correctChars: correctChars,
      incorrectChars: incorrectChars,
      totalChars: totalChars,
      duration: duration,
      timestamp: DateTime.now(),
      difficulty: _selectedDifficulty,
      isWordBasedTest: _selectedDuration.inSeconds == 0,
      targetWords:
          _selectedDuration.inSeconds == 0
              ? AppConstants.wordBasedTestWordCount
              : null,
      incorrectCharPositions: incorrectCharPositions,
      originalText: originalText,
      userInput: userInput,
    );

    await saveResult(result);
  }

  Future<void> _loadResults() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = _supabase.auth.currentSession;
      _isUserLoggedIn = session != null;

      if (_isUserLoggedIn) {
        await _loadResultsFromSupabase();
      } else {
        await _loadResultsFromLocal();
      }
    } catch (e) {
      dev.log('Error loading results: $e');
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

      _results =
          response.map((json) => _typingResultFromSupabaseJson(json)).toList();
      dev.log('Loaded ${_results.length} results from Supabase');

      await _saveAllResultsToLocal();
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
      if (_isUserLoggedIn) {
        await _saveResultToSupabase(result);

        final user = _supabase.auth.currentUser;
        if (user != null) {
          dev.log('🔥 Recording activity for heatmap...');
          final activityProvider = _getActivityProvider();
          if (activityProvider != null) {
            await activityProvider.recordActivity(user.id);
            dev.log('✅ Activity recorded in heatmap');
          } else {
            dev.log('❌ ActivityProvider not found - creating temporary one');
            final tempActivityProvider = ActivityProvider();
            await tempActivityProvider.recordActivity(user.id);
          }
        }

        dev.log('🔄 Attempting to update user stats...');
        await _updateUserStatsDirectly(result);

        final authProvider = _getAuthProvider();
        if (authProvider != null) {
          await authProvider.updateUserStats(result);
        }
      } else {
        dev.log('User not logged in - skipping activity recording');
      }
    } catch (e) {
      dev.log('Error saving result: $e');
    }

    await _saveAllResultsToLocal();
    notifyListeners();
  }

  AuthProvider? _getAuthProvider() {
    try {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        return Provider.of<AuthProvider>(context, listen: false);
      } else {
        dev.log('Context is null or not mounted');
      }
    } catch (e) {
      dev.log('Error getting auth provider: $e');
    }
    return null;
  }

  ActivityProvider? _getActivityProvider() {
    try {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        return Provider.of<ActivityProvider>(context, listen: false);
      }
    } catch (e) {
      dev.log('Error getting activity provider: $e');
    }
    return null;
  }

  Future<void> deleteHistoryEntry(TypingResult result) async {
    try {
      _results.remove(result);
      await _saveAllResultsToLocal();

      notifyListeners();

      if (_isUserLoggedIn) {
        final user = _supabase.auth.currentUser;

        if (user != null && result.id != null) {
          dev.log(
            'Attempting to delete from Supabase - User: ${user.id}, Result ID: ${result.id}',
          );

          final response =
              await _supabase
                  .from('typing_results')
                  .delete()
                  .eq('id', result.id!)
                  .eq('user_id', user.id)
                  .select();

          dev.log('Supabase delete response: $response');

          if (response.isNotEmpty) {
            dev.log(
              'Successfully deleted history entry from Supabase. Deleted record: ${response[0]['id']}',
            );
          } else if (response.isEmpty) {
            dev.log('No record found to delete');
          } else {
            dev.log('Unexpected null response from Supabase delete');
          }
        } else {
          dev.log(
            'Cannot delete from Supabase: ${result.id == null ? 'Result ID is null' : 'User not logged in'}',
          );
        }
      }
    } catch (e) {
      dev.log("Error deleting history entry: $e");

      _results.add(result);
      await _saveAllResultsToLocal();
      notifyListeners();

      dev.log('Failed to delete: ${e.toString()}');
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
        'incorrect_char_positions': result.incorrectCharPositions,
        'original_text': result.originalText,
        'user_input': result.userInput,
      };

      dev.log('Attempting to save to Supabase: $resultData');

      final response =
          await _supabase.from('typing_results').insert(resultData).select();

      dev.log('Supabase insert response: $response');

      if (response.isNotEmpty) {
        final savedResult = response[0];
        final supabaseId = savedResult['id']?.toString();

        final updatedResult = TypingResult(
          id: supabaseId,
          userId: user.id,
          wpm: result.wpm,
          accuracy: result.accuracy,
          consistency: result.consistency,
          correctChars: result.correctChars,
          incorrectChars: result.incorrectChars,
          totalChars: result.totalChars,
          duration: result.duration,
          timestamp: result.timestamp,
          difficulty: result.difficulty,
          isWordBasedTest: result.isWordBasedTest,
          targetWords: result.targetWords,
          incorrectCharPositions: result.incorrectCharPositions,
          originalText: result.originalText,
          userInput: result.userInput,
        );

        final index = _results.indexWhere(
          (r) => r.timestamp == result.timestamp && r.id == null,
        );
        if (index != -1) {
          _results[index] = updatedResult;
        }

        await _saveAllResultsToLocal();

        dev.log('Result saved to Supabase successfully with ID: $supabaseId');
      } else {
        dev.log('Supabase insert returned empty response');
      }
    } catch (e) {
      dev.log('Error saving result to Supabase: $e');
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

      final testResponse = await _supabase
          .from('typing_results')
          .select('count')
          .limit(1);

      dev.log('Supabase connection test: $testResponse');
    } catch (e) {
      dev.log('Supabase connection test failed: $e');
    }
  }

  void clearHistory() async {
    _results.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('typing_results');

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

  TypingResult _typingResultFromSupabaseJson(Map<String, dynamic> json) {
    List<int> incorrectPositions = [];
    if (json['incorrect_char_positions'] != null) {
      if (json['incorrect_char_positions'] is List) {
        incorrectPositions = List<int>.from(json['incorrect_char_positions']);
      }
    }

    return TypingResult(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
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
      incorrectCharPositions: incorrectPositions,
      originalText: json['original_text'] ?? '',
      userInput: json['user_input'] ?? '',
    );
  }

  TypingResult? getResultByTimestamp(DateTime timestamp) {
    try {
      return _results.firstWhere(
        (result) =>
            result.timestamp.millisecondsSinceEpoch ==
            timestamp.millisecondsSinceEpoch,
      );
    } catch (e) {
      return null;
    }
  }

  String getOriginalTextForResult(TypingResult result) {
    return result.originalText;
  }

  String getUserInputForResult(TypingResult result) {
    return result.userInput;
  }

  void resetCurrentTest() {
    _currentUserInput = '';
    resetConsistencyTracking();
    // getCurrentText() automatically updates _currentOriginalText
    getCurrentText();
    notifyListeners();
  }

  Future<void> _updateUserStatsDirectly(TypingResult result) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        dev.log('No user found for stats update');
        return;
      }

      dev.log('🔄 Starting direct stats update for user: ${user.id}');

      Map<String, dynamic> currentProfile;
      try {
        final response =
            await _supabase
                .from('profiles')
                .select()
                .eq('id', user.id)
                .single();

        currentProfile = response;
        dev.log('✅ Current profile fetched: ${currentProfile['email']}');
      } catch (e) {
        dev.log('Error fetching current profile: $e');
        return;
      }

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      int currentStreak = currentProfile['current_streak'] ?? 0;
      int longestStreak = currentProfile['longest_streak'] ?? 0;
      DateTime? lastActivityDate =
          currentProfile['last_activity_date'] != null
              ? DateTime.parse(currentProfile['last_activity_date'])
              : null;

      dev.log(
        '📅 Streak calculation - Last activity: $lastActivityDate, Today: $today',
      );

      if (lastActivityDate != null) {
        if (_isSameDay(lastActivityDate, today)) {
          dev.log('🔄 Already updated today, keeping streak: $currentStreak');
        } else if (_isSameDay(lastActivityDate, yesterday)) {
          currentStreak++;
          dev.log('🔥 Consecutive day! New streak: $currentStreak');
        } else {
          currentStreak = 1;
          dev.log('💥 Streak broken! Reset to: $currentStreak');
        }
      } else {
        currentStreak = 1;
        dev.log('🎯 First activity! Starting streak: $currentStreak');
      }

      longestStreak =
          currentStreak > longestStreak ? currentStreak : longestStreak;

      final previousTotalTests = currentProfile['total_tests'] ?? 0;
      final previousTotalWords = currentProfile['total_words'] ?? 0;
      final previousAverageWpm =
          (currentProfile['average_wpm'] ?? 0).toDouble();
      final previousAverageAccuracy =
          (currentProfile['average_accuracy'] ?? 0).toDouble();

      final totalTests = previousTotalTests + 1;
      final totalWords = previousTotalWords + result.wpm;
      final averageWpm =
          ((previousAverageWpm * previousTotalTests) + result.wpm) / totalTests;
      final averageAccuracy =
          ((previousAverageAccuracy * previousTotalTests) + result.accuracy) /
          totalTests;

      dev.log('🧮 Stats calculation:');
      dev.log('   - Tests: $previousTotalTests → $totalTests');
      dev.log(
        '   - WPM: ${previousAverageWpm.toStringAsFixed(1)} → ${averageWpm.toStringAsFixed(1)}',
      );
      dev.log(
        '   - Accuracy: ${previousAverageAccuracy.toStringAsFixed(1)} → ${averageAccuracy.toStringAsFixed(1)}',
      );

      final updates = {
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'last_activity_date': today.toIso8601String(),
        'total_tests': totalTests,
        'total_words': totalWords,
        'average_wpm': averageWpm,
        'average_accuracy': averageAccuracy,
        'updated_at': today.toIso8601String(),
      };

      dev.log('💾 Direct update to Supabase: $updates');

      final response =
          await _supabase
              .from('profiles')
              .update(updates)
              .eq('id', user.id)
              .select();

      dev.log(
        '✅ Direct update response: ${response.isNotEmpty ? "SUCCESS" : "EMPTY"}',
      );

      if (response.isNotEmpty) {
        dev.log('🎉 User stats updated successfully in Supabase!');

        final authProvider = _getAuthProvider();
        if (authProvider != null) {
          await authProvider.fetchUserProfile(user.id);
          dev.log('🔄 Forced profile refresh in AuthProvider');
        }
      }
    } catch (e) {
      dev.log('💥 Error in direct stats update: $e');
      if (e is PostgrestException) {
        dev.log('💥 Postgrest error: ${e.message}');
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
