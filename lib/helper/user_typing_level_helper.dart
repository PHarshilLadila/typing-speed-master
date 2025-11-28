// utils/user_level_helper.dart
import 'package:flutter/material.dart';

class UserTypingLevelHelper {
  static String calculateLevel(double averageWpm, int totalTests) {
    if (totalTests < 3) return 'Beginner';

    if (averageWpm < 20) return 'Beginner';
    if (averageWpm >= 20 && averageWpm < 40) return 'Intermediate';
    if (averageWpm >= 40 && averageWpm < 60) return 'Advanced';
    if (averageWpm >= 60 && averageWpm < 80) return 'Pro';
    return 'Expert';
  }

  static String getLevelDescription(String level) {
    switch (level) {
      case 'Beginner':
        return 'Keep practicing! Start with easy texts.';
      case 'Intermediate':
        return 'Good progress! Try medium difficulty.';
      case 'Advanced':
        return 'Great speed! Challenge yourself with hard texts.';
      case 'Pro':
        return 'Excellent! You\'re among the top typists.';
      case 'Expert':
        return 'Outstanding! You\'ve mastered typing.';
      default:
        return 'Start your typing journey!';
    }
  }

  static Color getLevelColor(String level, bool isDark) {
    switch (level) {
      case 'Beginner':
        return isDark ? Colors.blue.shade300 : Colors.blue;
      case 'Intermediate':
        return isDark ? Colors.green.shade300 : Colors.green;
      case 'Advanced':
        return isDark ? Colors.orange.shade300 : Colors.orange;
      case 'Pro':
        return isDark ? Colors.purple.shade300 : Colors.purple;
      case 'Expert':
        return isDark ? Colors.red.shade300 : Colors.red;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey;
    }
  }

  static String getLevelEmoji(String level) {
    switch (level) {
      case 'Beginner':
        return '🟦';
      case 'Intermediate':
        return '🟩';
      case 'Advanced':
        return '🟧';
      case 'Pro':
        return '🟪';
      case 'Expert':
        return '🟥';
      default:
        return '⚪';
    }
  }
}
