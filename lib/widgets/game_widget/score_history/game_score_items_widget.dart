// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:typing_speed_master/features/games/character_rush/model/character_rush_model.dart';
import 'package:typing_speed_master/features/games/word_master/model/word_master_model.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class GameScoreItem extends StatelessWidget {
  final CharacterRushModel? charRushScore;
  final WordMasterModel? wordMasterScore;
  final int rank;
  final bool isDarkMode;
  final ThemeProvider themeProvider;

  const GameScoreItem({
    super.key,
    required this.charRushScore,
    required this.wordMasterScore,
    required this.rank,
    required this.isDarkMode,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isWordMasterScore = wordMasterScore != null;

    final score =
        isWordMasterScore ? wordMasterScore!.score : charRushScore!.score;

    final collected =
        isWordMasterScore
            ? wordMasterScore!.wordCollected
            : charRushScore!.charactersCollected;

    final gameDuration =
        isWordMasterScore
            ? wordMasterScore!.gameDuration
            : charRushScore!.gameDuration;

    final timestamps =
        isWordMasterScore
            ? wordMasterScore!.timestamps
            : charRushScore!.timestamps;

    final collectedLabel = isWordMasterScore ? "words" : "characters";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getGamesRankColor(rank, themeProvider),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$rank",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Score: $score',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    gamesScoreBadge(score, isDarkMode),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      "$collected $collectedLabel collected",
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      "${gameDuration}s",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                gameDateFormate(timestamps),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                gameTimeFormate(timestamps),
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget gamesScoreBadge(int score, bool isDarkMode) {
    Color color;
    String text;

    if (score >= 1000) {
      color = Colors.amber;
      text = 'AMAZING!';
    } else if (score >= 500) {
      color = Colors.purple;
      text = 'GREAT!';
    } else if (score >= 200) {
      color = Colors.amber;
      text = 'GOOD!';
    } else {
      color = Colors.green;
      text = 'NICE!';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color getGamesRankColor(int rank, ThemeProvider themeProvider) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return themeProvider.primaryColor;
    }
  }

  String gameDateFormate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String gameTimeFormate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
