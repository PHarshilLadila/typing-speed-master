// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:typing_speed_master/features/games/game_character_rush/model/character_rush_model.dart';
// import 'package:typing_speed_master/features/games/game_word_master/model/word_master_model.dart';
// import 'package:typing_speed_master/theme/provider/theme_provider.dart';

// class GameScoreItem extends StatelessWidget {
//   final CharacterRushModel? charRushScore;
//   final WordMasterModel? wordMasterScore;
//   final int rank;
//   final bool isDarkMode;
//   final ThemeProvider themeProvider;

//   const GameScoreItem({
//     super.key,
//     required this.charRushScore,
//     required this.wordMasterScore,
//     required this.rank,
//     required this.isDarkMode,
//     required this.themeProvider,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isWordMasterScore = wordMasterScore != null;

//     final score =
//         isWordMasterScore ? wordMasterScore!.score : charRushScore!.score;

//     final collected =
//         isWordMasterScore
//             ? wordMasterScore!.wordCollected
//             : charRushScore!.charactersCollected;

//     final gameDuration =
//         isWordMasterScore
//             ? wordMasterScore!.gameDuration
//             : charRushScore!.gameDuration;

//     final timestamps =
//         isWordMasterScore
//             ? wordMasterScore!.timestamps
//             : charRushScore!.timestamps;

//     final collectedLabel = isWordMasterScore ? "words" : "characters";

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
//           width: 0.5,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: getGamesRankColor(rank, themeProvider),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 "$rank",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       'Score: $score',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: isDarkMode ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     gamesScoreBadge(score, isDarkMode),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(Icons.check_circle, size: 14, color: Colors.green),
//                     const SizedBox(width: 4),
//                     Text(
//                       "$collected $collectedLabel collected",
//                       style: TextStyle(
//                         color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Icon(Icons.timer, size: 14, color: Colors.blue),
//                     const SizedBox(width: 4),
//                     Text(
//                       "${gameDuration}s",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 gameDateFormate(timestamps),
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                 ),
//               ),
//               Text(
//                 gameTimeFormate(timestamps),
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget gamesScoreBadge(int score, bool isDarkMode) {
//     Color color;
//     String text;

//     if (score >= 1000) {
//       color = Colors.amber;
//       text = 'AMAZING!';
//     } else if (score >= 500) {
//       color = Colors.purple;
//       text = 'GREAT!';
//     } else if (score >= 200) {
//       color = Colors.amber;
//       text = 'GOOD!';
//     } else {
//       color = Colors.green;
//       text = 'NICE!';
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.5)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//           color: color,
//         ),
//       ),
//     );
//   }

//   Color getGamesRankColor(int rank, ThemeProvider themeProvider) {
//     switch (rank) {
//       case 1:
//         return const Color(0xFFFFD700);
//       case 2:
//         return const Color(0xFFC0C0C0);
//       case 3:
//         return const Color(0xFFCD7F32);
//       default:
//         return themeProvider.primaryColor;
//     }
//   }

//   String gameDateFormate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   String gameTimeFormate(DateTime date) {
//     return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//   }
// }

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:typing_speed_master/features/games/game_character_rush/model/character_rush_model.dart';
import 'package:typing_speed_master/features/games/game_word_master/model/word_master_model.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

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
      padding: EdgeInsets.all(
        screenWidth * 0.02 > 20 ? 20 : screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank Circle with enhanced design
          Container(
            width: screenWidth * 0.06 > 48 ? 48 : screenWidth * 0.06,
            height: screenWidth * 0.06 > 48 ? 48 : screenWidth * 0.06,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: getGamesRankGradient(rank, themeProvider),
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: getGamesRankColor(
                    rank,
                    themeProvider,
                  ).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "$rank",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.018 > 18 ? 18 : screenWidth * 0.018,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Expanded content with improved spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Score row with badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Score: $score',
                        style: TextStyle(
                          fontSize:
                              screenWidth * 0.016 > 20
                                  ? 20
                                  : screenWidth * 0.016,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode
                                  ? Colors.white.withOpacity(0.95)
                                  : Colors.black.withOpacity(0.9),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    gamesScoreBadge(score, isDarkMode),
                  ],
                ),
                const SizedBox(height: 6),

                // Stats row
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    // Collected count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$collected $collectedLabel",
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.black.withOpacity(0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    // Duration
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.blue.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${gameDuration}s",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color:
                                isDarkMode
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Date and time with improved typography
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  gameDateFormate(timestamps),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                gameTimeFormate(timestamps),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.4),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
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

  List<Color> getGamesRankGradient(int rank, ThemeProvider themeProvider) {
    switch (rank) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFDB931)];
      case 2:
        return [const Color(0xFFE0E0E0), const Color(0xFFB0B0B0)];
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFFB06E2B)];
      default:
        return [
          themeProvider.primaryColor,
          themeProvider.primaryColor.withOpacity(0.8),
        ];
    }
  }

  String gameDateFormate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String gameTimeFormate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
