import 'package:flutter/material.dart';
import 'package:typing_speed_master/features/games/game_character_rush/model/character_rush_model.dart';
import 'package:typing_speed_master/features/games/game_character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/features/games/game_word_master/model/word_master_model.dart';
import 'package:typing_speed_master/features/games/game_word_master/provider/word_master_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/game_widget/score_history/game_score_items_widget.dart';

class GameScoresListWidget extends StatelessWidget {
  final CharacterRushProvider? charRushProvider;
  final WordMasterProvider? wordMasterProvider;
  final bool isDarkMode;
  final bool isWordMaster;
  final ThemeProvider themeProvider;

  const GameScoresListWidget({
    super.key,
    required this.charRushProvider,
    required this.wordMasterProvider,
    required this.isDarkMode,
    required this.themeProvider,
    required this.isWordMaster,
  });

  @override
  Widget build(BuildContext context) {
    final scores =
        isWordMaster ? wordMasterProvider!.scores : charRushProvider!.scores;

    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        if (isWordMaster) {
          return GameScoreItem(
            rank: index + 1,
            isDarkMode: isDarkMode,
            themeProvider: themeProvider,
            charRushScore: null,
            wordMasterScore: scores[index] as WordMasterModel,
          );
        } else {
          return GameScoreItem(
            rank: index + 1,
            isDarkMode: isDarkMode,
            themeProvider: themeProvider,
            wordMasterScore: null,
            charRushScore: scores[index] as CharacterRushModel,
          );
        }
      },
    );
  }
}
