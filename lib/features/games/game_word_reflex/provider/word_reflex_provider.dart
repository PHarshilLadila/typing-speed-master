import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/word_reflex_model.dart';
import '../model/word_reflex_dataset.dart';

enum GameStage { setup, reading, hide, input, result, history }

class WordReflexProvider with ChangeNotifier {
  static const String _scoresKey = 'word_reflex_scores';
  static const String _readingTimeKey = 'word_reflex_reading_time';
  static const String _typingTimeKey = 'word_reflex_typing_time';
  static const String _wordLengthKey = 'word_reflex_word_length';

  final SupabaseClient _supabase = Supabase.instance.client;

  // Game Settings
  final List<int> _timeOptions = [30, 60, 120, 180, 240, 300, 400, 600];
  int _selectedGameTime = 60;

  // New Settings
  int _readingTime = 5; // Default 5s
  int _typingTime = 8; // Default 8s
  String _wordLengthMode = 'Mix'; // Default Mix

  // Game State
  GameStage _stage = GameStage.setup;
  int _score = 0;
  int _streak = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _timeouts = 0;
  int _remainingGameTime = 0;
  int _remainingRoundTime = 0;
  int _eyeButtonUses = 3;
  bool _isEyeButtonActive = false;

  Timer? _gameTimer;
  Timer? _roundTimer;

  WordReflexRound? _currentRound;
  List<String> _currentOptions = [];
  List<WordReflexRoundResult> _currentGameResults = [];

  List<WordReflexResult> _history = [];
  bool _isLoadingHistory = false;

  // Getters
  List<int> get timeOptions => _timeOptions;
  int get selectedGameTime => _selectedGameTime;
  int get readingTime => _readingTime;
  int get typingTime => _typingTime;
  String get wordLengthMode => _wordLengthMode;

  GameStage get stage => _stage;
  int get score => _score;
  int get streak => _streak;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _wrongAnswers;
  int get timeouts => _timeouts;
  int get remainingGameTime => _remainingGameTime;
  int get remainingRoundTime => _remainingRoundTime;
  int get eyeButtonUses => _eyeButtonUses;
  bool get isEyeButtonActive => _isEyeButtonActive;
  WordReflexRound? get currentRound => _currentRound;
  List<String> get currentOptions => _currentOptions;
  List<WordReflexResult> get history => _history;
  bool get isLoadingHistory => _isLoadingHistory;

  WordReflexProvider() {
    _loadSettings();
    _loadHistory();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.signedOut) {
        _loadHistory();
      }
    });
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _readingTime = prefs.getInt(_readingTimeKey) ?? 5;
    _typingTime = prefs.getInt(_typingTimeKey) ?? 8;
    _wordLengthMode = prefs.getString(_wordLengthKey) ?? 'Mix';
    notifyListeners();
  }

  void _loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('game_word_reflex')
            .select()
            .eq('user_id', user.id)
            .order('timestamp', ascending: false);

        _history =
            response.map((data) {
              return WordReflexResult(
                score: data['score'],
                correctAnswers: data['correct_answers'],
                wrongAnswers: data['wrong_answers'],
                streak: data['streak'],
                timeouts: data['timeouts'],
                totalRounds: data['total_rounds'],
                gameDuration: data['game_duration'],
                timestamp: DateTime.parse(data['timestamp']),
                roundResults:
                    (data['round_results'] as List)
                        .map((e) => WordReflexRoundResult.fromJson(e))
                        .toList(),
              );
            }).toList();
      } else {
        final prefs = await SharedPreferences.getInstance();
        final historyJson = prefs.getStringList(_scoresKey);
        if (historyJson != null) {
          _history =
              historyJson
                  .map((item) => WordReflexResult.fromJson(json.decode(item)))
                  .toList();
          _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        }
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings({
    required int readingTime,
    required int typingTime,
    required String wordLengthMode,
  }) async {
    _readingTime = readingTime;
    _typingTime = typingTime;
    _wordLengthMode = wordLengthMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_readingTimeKey, _readingTime);
    await prefs.setInt(_typingTimeKey, _typingTime);
    await prefs.setString(_wordLengthKey, _wordLengthMode);
    notifyListeners();
  }

  void _saveResult() async {
    final result = WordReflexResult(
      score: _score,
      correctAnswers: _correctAnswers,
      wrongAnswers: _wrongAnswers,
      streak: _streak,
      timeouts: _timeouts,
      totalRounds: _correctAnswers + _wrongAnswers + _timeouts,
      gameDuration: _selectedGameTime,
      timestamp: DateTime.now(),
      roundResults: List.from(_currentGameResults),
    );

    _history.insert(0, result);
    if (_history.length > 20) _history.removeLast();

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final totalQuestions = _correctAnswers + _wrongAnswers;
        final accuracy =
            totalQuestions > 0 ? (_correctAnswers / totalQuestions) * 100 : 0.0;

        await _supabase.from('game_word_reflex').insert({
          'user_id': user.id,
          'score': _score,
          'correct_answers': _correctAnswers,
          'wrong_answers': _wrongAnswers,
          'streak': _streak,
          'timeouts': _timeouts,
          'total_rounds': _correctAnswers + _wrongAnswers + _timeouts,
          'game_duration': _selectedGameTime,
          'accuracy': accuracy,
          'round_results': _currentGameResults.map((e) => e.toJson()).toList(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Error saving to Supabase: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _scoresKey,
      _history.map((item) => json.encode(item.toJson())).toList(),
    );
    notifyListeners();
  }

  void setSelectedTime(int seconds) {
    _selectedGameTime = seconds;
    notifyListeners();
  }

  void startGame() {
    _score = 0;
    _streak = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _timeouts = 0;
    _eyeButtonUses = 5;
    _remainingGameTime = _selectedGameTime;
    _stage = GameStage.reading;
    _currentGameResults = [];

    _startNextRound();
    _startGameTimer();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingGameTime > 0) {
        _remainingGameTime--;
        notifyListeners();
      } else {
        _endGame();
      }
    });
  }

  void _startNextRound() {
    final random = math.Random();

    // Filter dataset based on word length
    List<WordReflexRound> filteredList =
        wordReflexDataset.where((round) {
          int len = round.mainWord.length;
          if (_wordLengthMode == 'Short') return len <= 5;
          if (_wordLengthMode == 'Medium') return len >= 6 && len <= 8;
          if (_wordLengthMode == 'Long') return len > 8;
          return true; // Mix
        }).toList();

    // Fallback if filter returns empty (shouldn't happen with standard dataset but for safety)
    if (filteredList.isEmpty) filteredList = wordReflexDataset;

    _currentRound = filteredList[random.nextInt(filteredList.length)];

    // Mix options: 1 synonym + 1 similar + 1 related
    _currentOptions = [
      _currentRound!.synonyms[random.nextInt(_currentRound!.synonyms.length)],
      _currentRound!.similarLooking,
      _currentRound!.relatedButWrong,
    ];
    _currentOptions.shuffle();

    _stage = GameStage.reading;
    _remainingRoundTime = _readingTime; // Use dynamic setting
    notifyListeners();

    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingRoundTime > 0) {
        _remainingRoundTime--;
        notifyListeners();
      } else {
        _startInputPhase();
      }
    });
  }

  void _startInputPhase() {
    _stage = GameStage.input;
    _remainingRoundTime = _typingTime; // Use dynamic setting
    notifyListeners();

    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingRoundTime > 0) {
        _remainingRoundTime--;
        notifyListeners();
      } else {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    _timeouts++;
    _score = math.max(0, _score - 7);
    _streak = 0;

    // Record timeout result
    if (_currentRound != null) {
      // Find the correct synonym from current options (or just take the first from main list)
      // Usually, we want to know what was the correct answer *available* to the user.
      // Since synonyms is a list, we can just grab one valid one.
      String correctSynonym = _currentRound!.synonyms.first;
      // Or better, find which one was in _currentOptions
      for (var opt in _currentOptions) {
        if (_currentRound!.synonyms.contains(opt)) {
          correctSynonym = opt;
          break;
        }
      }

      _currentGameResults.add(
        WordReflexRoundResult(
          mainWord: _currentRound!.mainWord,
          correctAnswer: correctSynonym,
          userAnswer: "Time Out",
          isCorrect: false,
        ),
      );
    }
    _startNextRound();
  }

  void checkAnswer(String answer) {
    if (_stage != GameStage.input) return;

    final normalizedAnswer = answer.trim().toLowerCase();
    bool isCorrect = _currentRound!.synonyms.any(
      (s) => s.toLowerCase() == normalizedAnswer,
    );

    if (isCorrect) {
      _correctAnswers++;
      int basePoints = 10;
      int speedBonus = _remainingRoundTime; // More points for faster answer
      _score += basePoints + speedBonus;
      _streak++;
    } else {
      _wrongAnswers++;
      _score = math.max(0, _score - 5);
      _streak = 0;
    }

    // Record result
    String correctSynonym = _currentRound!.synonyms.first;
    for (var opt in _currentOptions) {
      if (_currentRound!.synonyms.any(
        (s) => s.toLowerCase() == opt.toLowerCase(),
      )) {
        correctSynonym = opt;
        break;
      }
    }

    _currentGameResults.add(
      WordReflexRoundResult(
        mainWord: _currentRound!.mainWord,
        correctAnswer: correctSynonym,
        userAnswer: answer,
        isCorrect: isCorrect,
      ),
    );

    _startNextRound();
  }

  void useEyeButton() {
    if (_eyeButtonUses > 0 &&
        _stage == GameStage.input &&
        !_isEyeButtonActive) {
      _eyeButtonUses--;
      _score = math.max(0, _score - 5);
      _isEyeButtonActive = true;
      notifyListeners();

      Timer(const Duration(milliseconds: 1500), () {
        _isEyeButtonActive = false;
        notifyListeners();
      });
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _roundTimer?.cancel();
    _stage = GameStage.result;
    _saveResult();
    notifyListeners();
  }

  void resetToSetup() {
    _gameTimer?.cancel();
    _roundTimer?.cancel();
    _stage = GameStage.setup;
    notifyListeners();
  }

  void showHistory() {
    _gameTimer?.cancel();
    _roundTimer?.cancel();
    _stage = GameStage.history;
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _roundTimer?.cancel();
    super.dispose();
  }
}
 /*
-- Word Reflex ગેમના ડેટા સ્ટોર કરવા માટેનું ટેબલ
CREATE TABLE IF NOT EXISTS game_word_reflex (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    score INTEGER NOT NULL,
    correct_answers INTEGER NOT NULL,
    wrong_answers INTEGER NOT NULL,
    streak INTEGER NOT NULL,
    timeouts INTEGER NOT NULL,
    total_rounds INTEGER NOT NULL,
    game_duration INTEGER NOT NULL,
    accuracy NUMERIC NOT NULL,
    round_results JSONB NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS (Row Level Security) સેટિંગ્સ - જેથી યુઝર ફક્ત પોતાના જ ડેટા જોઈ અને સેવ કરી શકે
ALTER TABLE game_word_reflex ENABLE ROW LEVEL SECURITY;

-- પોલિસી: ડેટા ઇન્સર્ટ કરવા માટે
CREATE POLICY "Users can insert their own game data" 
ON game_word_reflex FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- પોલિસી: ફક્ત પોતાના ડેટા જોવા માટે
CREATE POLICY "Users can view their own game data" 
ON game_word_reflex FOR SELECT 
USING (auth.uid() = user_id);

-- પોલિસી: પોતાનો ડેટા ડિલીટ કરવા માટે
CREATE POLICY "Users can delete their own game data"
ON game_word_reflex FOR DELETE
USING (auth.uid() = user_id);

 */