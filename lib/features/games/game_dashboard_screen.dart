import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/models/game_dashboard_card.dart';
import 'package:typing_speed_master/features/games/provider/game_dashboard_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/features/games/game_character_rush/game_character_rush_screen.dart';
import 'package:typing_speed_master/features/games/game_word_master/game_word_master.dart';
import 'package:typing_speed_master/features/games/game_word_reflex/game_word_reflex_screen.dart';
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
      ),
      GameDashboardCard(
        title: "Word Master",
        subtitle: "Type complete words accurately",
        type: GameType.word,
        backgroundColor: Colors.green,
        gameId: "word_master",
        isFavorite: gameProvider.isFavoriteWordMaster,
      ),
      GameDashboardCard(
        title: "Word Reflex",
        subtitle: "Type the synonym after words disappear",
        type: GameType.word,
        backgroundColor: Colors.orange,
        gameId: "word_reflex",
        isFavorite: gameProvider.isFavoriteWordReflex,
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

  void handleGameTap(GameDashboardCard gameCard) {
    debugPrint('Game tapped: ${gameCard.title}');

    if (gameCard.isComingSoon) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${gameCard.title} is coming soon!')),
      );
      return;
    }

    final mainEntryPointState =
        context.findAncestorStateOfType<AppEntryPointState>();

    if (mainEntryPointState != null) {
      mainEntryPointState.launchGame(gameCard.gameId);
    } else {
      switch (gameCard.gameId) {
        case "character_rush":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GameCharacterRushScreen(),
            ),
          );
          break;
        case "word_master":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GameWordMaster()),
          );
          break;
        case "word_reflex":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GameWordReflexScreen(),
            ),
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Launching ${gameCard.title}')),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
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
                        ),
                        GameDashboardCard(
                          title: "Word Master",
                          subtitle: "Type complete words accurately",
                          type: GameType.word,
                          backgroundColor: Colors.green,
                          gameId: "word_master",
                          isFavorite: gameProvider.isFavoriteWordMaster,
                        ),
                        GameDashboardCard(
                          title: "Word Reflex",
                          subtitle: "Type the synonym after words disappear",
                          type: GameType.word,
                          backgroundColor: Colors.orange,
                          gameId: "word_reflex",
                          isFavorite: gameProvider.isFavoriteWordReflex,
                        ),
                        GameDashboardCard(
                          title: "Monster Game",
                          subtitle: "This is new monster game",
                          type: GameType.word,
                          backgroundColor: Color(0xffFFD700),
                          gameId: "monster_game",
                          availability: GameAvailability.comingSoon,
                          isFavorite: gameProvider.isFavoriteMonsterGame,
                        ),
                        GameDashboardCard(
                          title: "Dyno Game",
                          subtitle: "This is new dyno game",
                          type: GameType.word,
                          backgroundColor: Colors.purple,
                          gameId: "dyno_game",
                          availability: GameAvailability.comingSoon,
                          isFavorite: gameProvider.isFavoriteDynoGame,
                        ),
                        // GameDashboardCard(
                        //   title: "Squid Game",
                        //   subtitle: "This is new squid game",
                        //   type: GameType.word,
                        //   backgroundColor: Colors.orange,
                        //   gameId: "new_game",
                        //   availability: GameAvailability.comingSoon,
                        //   isFavorite: gameProvider.isFavoriteWordMaster,
                        // ),
                        // GameDashboardCard(
                        //   title: "Ranger's Game",
                        //   subtitle: "This is new ranger's game",
                        //   type: GameType.word,
                        //   backgroundColor: Color(0xffd8a6ad),
                        //   gameId: "new_game",
                        //   availability: GameAvailability.comingSoon,
                        //   isFavorite: gameProvider.isFavoriteWordMaster,
                        // ),
                      ];

                      final gamesToDisplay = gameCards;

                      if (screenWidth > 980) {
                        return gameDashboardDesktopLayout(
                          context,
                          gamesToDisplay,
                        );
                      } else {
                        return gameDashboardMobileLayout(gamesToDisplay);
                      }
                    },
                  ),
                ],
              ),
            ),
            // FooterWidget(themeProvider: themeProvider),
          ],
        ),
      ),
    );
  }

  Widget gameDashboardDesktopLayout(
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
                onTap: () => handleGameTap(gameCard),
              ),
            );
          }).toList(),
    );
  }

  Widget gameDashboardMobileLayout(List<GameDashboardCard> gameCards) {
    return Column(
      children:
          gameCards.map((gameCard) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: GameCardWidget(
                gameCard: gameCard,
                onTap: () => handleGameTap(gameCard),
              ),
            );
          }).toList(),
    );
  }
}
