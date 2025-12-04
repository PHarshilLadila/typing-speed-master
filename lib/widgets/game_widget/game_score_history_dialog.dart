// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/features/games/word_master/provider/word_master_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';
import 'package:typing_speed_master/widgets/game_widget/score_history/game_empty_state_widget.dart';
import 'package:typing_speed_master/widgets/game_widget/score_history/game_scores_list_widget.dart';

class GameScoreHistoryDialog extends StatelessWidget {
  final bool isWordMaster;
  const GameScoreHistoryDialog({super.key, this.isWordMaster = false});

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
                            ? GameEmptyStateWidget(
                              isDarkMode: themeProvider.isDarkMode,
                            )
                            : GameScoresListWidget(
                              charRushProvider: charRushProvider,
                              wordMasterProvider: wordMasterProvider,
                              isDarkMode: themeProvider.isDarkMode,
                              themeProvider: themeProvider,
                              isWordMaster: true,
                            )
                        : charRushProvider.scores.isEmpty
                        ? GameEmptyStateWidget(
                          isDarkMode: themeProvider.isDarkMode,
                        )
                        : GameScoresListWidget(
                          charRushProvider: charRushProvider,
                          wordMasterProvider: wordMasterProvider,
                          isDarkMode: themeProvider.isDarkMode,
                          themeProvider: themeProvider,
                          isWordMaster: false,
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
}
