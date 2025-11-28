// // game_dashboard_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:typing_speed_master/providers/game_dashboard_provider.dart';
// import 'package:typing_speed_master/providers/theme_provider.dart';
// import 'package:typing_speed_master/widgets/game_card_widget.dart';

// class GameDashboardScreen extends StatefulWidget {
//   const GameDashboardScreen({super.key});

//   @override
//   State<GameDashboardScreen> createState() => GameDashboardScreenState();
// }

// class GameDashboardScreenState extends State<GameDashboardScreen> {
//   // Game card data - easily customizable
//   List<GameCard> getGameCards(BuildContext context) {
//     final gameDashboardProvider = Provider.of<GameDashboardProvider>(
//       context,
//       listen: false,
//     );
//     return [
//       GameCard(
//         title: "Character Rush",
//         subtitle: "Type falling characters quickly",
//         type: GameType.character,
//         backgroundColor: Colors.blue,
//         gameId: "character_rush",
//         onTapStarIcon: () {
//           gameDashboardProvider.toggleFavoriteCharacterRush();
//           debugPrint("Character Rush Start Icon");
//         },
//       ),
//       GameCard(
//         title: "Word Master",
//         subtitle: "Type complete words accurately",
//         type: GameType.word,
//         backgroundColor: Colors.green,
//         gameId: "word_master",
//         onTapStarIcon: () {
//           debugPrint("Word Master Start Icon");
//         },
//       ),
//       // GameCard(
//       //   title: "Speed Typing",
//       //   subtitle: "Test your typing speed",
//       //   type: GameType.character,
//       //   backgroundColor: Colors.orange,
//       //   gameId: "speed_typing",
//       // ),
//       // Add more cards here in future
//     ];
//   }

//   EdgeInsets getResponsivePadding(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     if (width > 1200) {
//       return EdgeInsets.symmetric(
//         vertical: 50,
//         horizontal: MediaQuery.of(context).size.width / 5,
//       );
//     } else if (width > 768) {
//       return const EdgeInsets.all(40.0);
//     } else {
//       return const EdgeInsets.symmetric(vertical: 40.0, horizontal: 30);
//     }
//   }

//   Widget gameDashboardHeader(
//     BuildContext context,
//     double titleFontSize,
//     double subtitleFontSize,
//   ) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Games',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color:
//                       themeProvider.isDarkMode
//                           ? Colors.white
//                           : Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Play Bold. Perform Better.",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color:
//                       themeProvider.isDarkMode
//                           ? Colors.grey[400]
//                           : Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         IconButton(
//           onPressed: () {
//             // Add filter functionality
//           },
//           icon: Icon(
//             Icons.filter_list,
//             color: themeProvider.isDarkMode ? Colors.white : Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

//   void _handleGameTap(GameCard gameCard) {
//     // Handle game card tap
//     print('Game tapped: ${gameCard.title}');

//     // Navigate to game screen based on gameId
//     // Example:
//     // Navigator.push(
//     //   context,
//     //   MaterialPageRoute(
//     //     builder: (context) => GameScreen(gameId: gameCard.gameId),
//     //   ),
//     // );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final gameCards = getGameCards(context);

//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       child: Padding(
//         padding: getResponsivePadding(context),
//         child: Column(
//           children: [
//             gameDashboardHeader(context, 24, 18),
//             const SizedBox(height: 40),

//             // Custom responsive layout
//             if (screenWidth > 980)
//               _buildDesktopLayout(context, gameCards)
//             else
//               _buildMobileLayout(gameCards),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDesktopLayout(BuildContext context, List<GameCard> gameCards) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final padding = getResponsivePadding(context);
//     final availableWidth =
//         screenWidth - padding.horizontal - 40; // 40 for extra margins

//     // Calculate dynamic width for cards - 2 cards with proper spacing
//     final cardWidth = (availableWidth - 40) / 2; // 40px spacing between cards

//     return Wrap(
//       spacing: 50, // Space between cards
//       runSpacing: 20, // Space between rows
//       alignment: WrapAlignment.spaceBetween,
//       children:
//           gameCards.map((gameCard) {
//             // Now gameCards is a List, not a Function
//             return SizedBox(
//               width: cardWidth,
//               child: GameCardWidget(
//                 gameCard: gameCard,
//                 onTap: () => _handleGameTap(gameCard),
//               ),
//             );
//           }).toList(),
//     );
//   }

//   Widget _buildMobileLayout(List<GameCard> gameCards) {
//     return Column(
//       children:
//           gameCards.map((gameCard) {
//             return Container(
//               margin: const EdgeInsets.only(bottom: 20),
//               child: GameCardWidget(
//                 gameCard: gameCard,
//                 onTap: () => _handleGameTap(gameCard),
//               ),
//             );
//           }).toList(),
//     );
//   }
// }

// game_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/providers/game_dashboard_provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/widgets/game_card_widget.dart';

class GameDashboardScreen extends StatefulWidget {
  const GameDashboardScreen({super.key});

  @override
  State<GameDashboardScreen> createState() => GameDashboardScreenState();
}

class GameDashboardScreenState extends State<GameDashboardScreen> {
  // Game card data - easily customizable
  List<GameCard> getGameCards(BuildContext context) {
    final gameProvider = Provider.of<GameDashboardProvider>(
      context,
      listen: false,
    );

    return [
      GameCard(
        title: "Character Rush",
        subtitle: "Type falling characters quickly",
        type: GameType.character,
        backgroundColor: Colors.blue,
        gameId: "character_rush",
        isFavorite: gameProvider.isFavoriteCharacterRush,
        onTapStarIcon: () {
          gameProvider.toggleFavoriteCharacterRush();
        },
      ),
      GameCard(
        title: "Word Master",
        subtitle: "Type complete words accurately",
        type: GameType.word,
        backgroundColor: Colors.green,
        gameId: "word_master",
        isFavorite: gameProvider.isFavoriteWordMaster,
        onTapStarIcon: () {
          gameProvider.toggleFavoriteWordMaster();
        },
      ),
    ];
  }

  EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) {
      return EdgeInsets.symmetric(
        vertical: 50,
        horizontal: MediaQuery.of(context).size.width / 5,
      );
    } else if (width > 768) {
      return const EdgeInsets.all(40.0);
    } else {
      return const EdgeInsets.symmetric(vertical: 40.0, horizontal: 30);
    }
  }

  Widget gameDashboardHeader(
    BuildContext context,
    double titleFontSize,
    double subtitleFontSize,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Games',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Play Bold. Perform Better.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // Add filter functionality
          },
          icon: Icon(
            Icons.filter_list,
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _handleGameTap(GameCard gameCard) {
    debugPrint('Game tapped: ${gameCard.title}');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final gameCards = getGameCards(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: getResponsivePadding(context),
        child: Column(
          children: [
            gameDashboardHeader(context, 24, 18),
            const SizedBox(height: 40),

            Consumer<GameDashboardProvider>(
              builder: (context, gameProvider, child) {
                final gameCards = [
                  GameCard(
                    title: "Character Rush",
                    subtitle: "Type falling characters quickly",
                    type: GameType.character,
                    backgroundColor: Colors.blue,
                    gameId: "character_rush",
                    isFavorite: gameProvider.isFavoriteCharacterRush,
                    onTapStarIcon: () {
                      gameProvider.toggleFavoriteCharacterRush();
                    },
                  ),
                  GameCard(
                    title: "Word Master",
                    subtitle: "Type complete words accurately",
                    type: GameType.word,
                    backgroundColor: Colors.green,
                    gameId: "word_master",
                    isFavorite: gameProvider.isFavoriteWordMaster,
                    onTapStarIcon: () {
                      gameProvider.toggleFavoriteWordMaster();
                    },
                  ),
                ];

                // Custom responsive layout
                if (screenWidth > 980) {
                  return _buildDesktopLayout(context, gameCards);
                } else {
                  return _buildMobileLayout(gameCards);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List<GameCard> gameCards) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getResponsivePadding(context);
    final availableWidth = screenWidth - padding.horizontal - 40;

    final cardWidth = (availableWidth - 40) / 2;

    return Wrap(
      spacing: 50,
      runSpacing: 20,
      alignment: WrapAlignment.spaceBetween,
      children:
          gameCards.map((gameCard) {
            return SizedBox(
              width: cardWidth,
              child: GameCardWidget(
                gameCard: gameCard,
                onTap: () => _handleGameTap(gameCard),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMobileLayout(List<GameCard> gameCards) {
    return Column(
      children:
          gameCards.map((gameCard) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: GameCardWidget(
                gameCard: gameCard,
                onTap: () => _handleGameTap(gameCard),
              ),
            );
          }).toList(),
    );
  }
}
