// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/character_rush/model/character_rush_model.dart';
import 'package:typing_speed_master/features/games/character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/features/games/word_master/model/word_master_model.dart';
import 'package:typing_speed_master/features/games/word_master/provider/word_master_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';

class ScoreHistoryDialog extends StatelessWidget {
  final bool isWordMaster;
  const ScoreHistoryDialog({super.key, this.isWordMaster = false});

  @override
  Widget build(BuildContext context) {
    final charRushProvider = Provider.of<CharacterRushProvider>(context);
    final wordMasterProvider = Provider.of<WordMasterProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Dialog(
      backgroundColor:
          themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.close,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (charRushProvider.scores.isNotEmpty ||
                  wordMasterProvider.scores.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          CustomDialog.showConfirmationDialog(
                            context: context,
                            title: 'Clear History',
                            content:
                                'Are you sure you want to clear all score history? This action cannot be undone.',
                            confirmText: 'Clear',
                            confirmButtonColor: Colors.red,
                            isDestructive: true,
                            onConfirm: () {
                              context.pop();
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Clear History'),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child:
                    isWordMaster == true
                        ? wordMasterProvider.scores.isEmpty
                            ? gameEmptyState(themeProvider.isDarkMode)
                            : gameScoresList(
                              charRushProvider,
                              wordMasterProvider,
                              themeProvider.isDarkMode,
                              themeProvider,
                            )
                        : charRushProvider.scores.isEmpty
                        ? gameEmptyState(themeProvider.isDarkMode)
                        : gameScoresList(
                          charRushProvider,
                          wordMasterProvider,
                          themeProvider.isDarkMode,
                          themeProvider,
                        ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget gameEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Scores Yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Play a game to see your scores here.',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget gameScoresList(
    CharacterRushProvider? charRushProvider,
    WordMasterProvider? wordMasterProvider,
    bool isDarkMode,
    ThemeProvider themeProvider,
  ) {
    final scores =
        isWordMaster == true
            ? wordMasterProvider!.scores
            : charRushProvider!.scores;

    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        if (isWordMaster == true) {
          final wordMasterScore = scores[index] as WordMasterModel;
          return gameScoreItem(
            null, // charRushScore is null for word master
            wordMasterScore,
            index + 1,
            isDarkMode,
            themeProvider,
          );
        } else {
          final charRushScore = scores[index] as CharacterRushModel;
          return gameScoreItem(
            charRushScore,
            null, // wordMasterScore is null for character rush
            index + 1,
            isDarkMode,
            themeProvider,
          );
        }
      },
    );
  }

  Widget gameScoreItem(
    CharacterRushModel? charRushScore,
    WordMasterModel? wordMasterScore,
    int rank,
    bool isDarkMode,
    ThemeProvider themeProvider,
  ) {
    // Determine which score we're working with
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
    final collectedLabel = isWordMasterScore ? 'words' : 'characters';

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
              color: charRushGetRankColor(rank, themeProvider),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
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
                    charRushScoreBadge(score, isDarkMode),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '$collected $collectedLabel collected',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${gameDuration}s',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
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
                charRushDateFormate(timestamps),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                charRushTimeFormate(timestamps),
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget charRushScoreBadge(int score, bool isDarkMode) {
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

  Color charRushGetRankColor(int rank, ThemeProvider themeProvider) {
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

  String charRushDateFormate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String charRushTimeFormate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
