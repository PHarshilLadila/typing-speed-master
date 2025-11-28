import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/models/game_dashboard_card.dart';
import 'package:typing_speed_master/features/games/provider/game_dashboard_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/features/games/character_rush/game_character_rush.dart';
import 'package:typing_speed_master/features/games/word_master/game_word_master.dart';
import 'package:typing_speed_master/features/app_entry_point.dart';
import 'package:typing_speed_master/features/games/widget/game_card_widget.dart';

class GameDashboardScreen extends StatefulWidget {
  const GameDashboardScreen({super.key});

  @override
  State<GameDashboardScreen> createState() => GameDashboardScreenState();
}

class GameDashboardScreenState extends State<GameDashboardScreen> {
  List<GameDashboardCard> getGameCards(BuildContext context) {
    final gameProvider = Provider.of<GameDashboardProvider>(
      context,
      listen: false,
    );

    return [
      GameDashboardCard(
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
      GameDashboardCard(
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
          onPressed: () {},
          icon: Icon(
            Icons.filter_list,
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _handleGameTap(GameDashboardCard gameCard) {
    debugPrint('Game tapped: ${gameCard.title}');

    final mainEntryPointState =
        context.findAncestorStateOfType<AppEntryPointState>();

    if (mainEntryPointState != null) {
      mainEntryPointState.launchGame(gameCard.gameId);
    } else {
      switch (gameCard.gameId) {
        case "character_rush":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GameCharacterRush()),
          );
          break;
        case "word_master":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GameWordMaster()),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                  GameDashboardCard(
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
                  GameDashboardCard(
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

  Widget _buildDesktopLayout(
    BuildContext context,
    List<GameDashboardCard> gameCards,
  ) {
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

  Widget _buildMobileLayout(List<GameDashboardCard> gameCards) {
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
