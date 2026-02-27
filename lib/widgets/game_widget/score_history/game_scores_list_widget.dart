import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:typing_speed_master/features/games/game_character_rush/model/character_rush_model.dart';
import 'package:typing_speed_master/features/games/game_character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/features/games/game_word_master/model/word_master_model.dart';
import 'package:typing_speed_master/features/games/game_word_master/provider/word_master_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/game_widget/score_history/game_score_items_widget.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  scoreHigh,
  scoreLow,
  durationLong,
  durationShort,
  collectedHigh,
  collectedLow,
}

class GameScoresListWidget extends StatefulWidget {
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
  State<GameScoresListWidget> createState() => _GameScoresListWidgetState();
}

class _GameScoresListWidgetState extends State<GameScoresListWidget> {
  SortOption _currentSort = SortOption.dateNewest;

  List<dynamic> _getSortedScores() {
    List<dynamic> scores =
        widget.isWordMaster
            ? List<WordMasterModel>.from(widget.wordMasterProvider!.scores)
            : List<CharacterRushModel>.from(widget.charRushProvider!.scores);

    scores.sort((a, b) {
      if (widget.isWordMaster) {
        final ma = a as WordMasterModel;
        final mb = b as WordMasterModel;
        switch (_currentSort) {
          case SortOption.dateNewest:
            return mb.timestamps.compareTo(ma.timestamps);
          case SortOption.dateOldest:
            return ma.timestamps.compareTo(mb.timestamps);
          case SortOption.scoreHigh:
            return mb.score.compareTo(ma.score);
          case SortOption.scoreLow:
            return ma.score.compareTo(mb.score);
          case SortOption.durationLong:
            return mb.gameDuration.compareTo(ma.gameDuration);
          case SortOption.durationShort:
            return ma.gameDuration.compareTo(mb.gameDuration);
          case SortOption.collectedHigh:
            return mb.wordCollected.compareTo(ma.wordCollected);
          case SortOption.collectedLow:
            return ma.wordCollected.compareTo(mb.wordCollected);
        }
      } else {
        final ma = a as CharacterRushModel;
        final mb = b as CharacterRushModel;
        switch (_currentSort) {
          case SortOption.dateNewest:
            return mb.timestamps.compareTo(ma.timestamps);
          case SortOption.dateOldest:
            return ma.timestamps.compareTo(mb.timestamps);
          case SortOption.scoreHigh:
            return mb.score.compareTo(ma.score);
          case SortOption.scoreLow:
            return ma.score.compareTo(mb.score);
          case SortOption.durationLong:
            return mb.gameDuration.compareTo(ma.gameDuration);
          case SortOption.durationShort:
            return ma.gameDuration.compareTo(mb.gameDuration);
          case SortOption.collectedHigh:
            return mb.charactersCollected.compareTo(ma.charactersCollected);
          case SortOption.collectedLow:
            return ma.charactersCollected.compareTo(mb.charactersCollected);
        }
      }
    });

    return scores;
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        return 'Date: Newest';
      case SortOption.dateOldest:
        return 'Date: Oldest';
      case SortOption.scoreHigh:
        return 'Score: High-Low';
      case SortOption.scoreLow:
        return 'Score: Low-High';
      case SortOption.durationLong:
        return 'Duration: Longest';
      case SortOption.durationShort:
        return 'Duration: Shortest';
      case SortOption.collectedHigh:
        return widget.isWordMaster ? 'Words: Most' : 'Chars: Most';
      case SortOption.collectedLow:
        return widget.isWordMaster ? 'Words: Least' : 'Chars: Least';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedScores = _getSortedScores();

    return Column(
      children: [
        _buildSortBar(),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedScores.length,
          itemBuilder: (context, index) {
            if (widget.isWordMaster) {
              final score = sortedScores[index] as WordMasterModel;
              return GameScoreItem(
                rank: index + 1,
                isDarkMode: widget.isDarkMode,
                themeProvider: widget.themeProvider,
                charRushScore: null,
                wordMasterScore: score,
                onDelete: () {
                  widget.wordMasterProvider!.deleteScore(score);
                },
              );
            } else {
              final score = sortedScores[index] as CharacterRushModel;
              return GameScoreItem(
                rank: index + 1,
                isDarkMode: widget.isDarkMode,
                themeProvider: widget.themeProvider,
                wordMasterScore: null,
                charRushScore: score,
                onDelete: () {
                  widget.charRushProvider!.deleteScore(score);
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            widget.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.sort_rounded,
                size: 18,
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                'Sort By:',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          PopupMenuButton<SortOption>(
            initialValue: _currentSort,
            onSelected: (SortOption selection) {
              setState(() {
                _currentSort = selection;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.themeProvider.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.themeProvider.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getSortLabel(_currentSort),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.themeProvider.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 20,
                    color: widget.themeProvider.primaryColor,
                  ),
                ],
              ),
            ),
            itemBuilder: (BuildContext context) {
              return SortOption.values.map((SortOption option) {
                return PopupMenuItem<SortOption>(
                  value: option,
                  child: Text(
                    _getSortLabel(option),
                    style: GoogleFonts.outfit(fontSize: 14),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }
}
