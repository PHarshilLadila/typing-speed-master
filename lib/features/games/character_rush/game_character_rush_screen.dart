// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/features/games/character_rush/widget/char_rush_%20character_widget.dart';
import 'package:typing_speed_master/features/games/character_rush/widget/game_settings_dialog.dart';
import 'package:typing_speed_master/features/games/character_rush/widget/score_history_dialog.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class GameCharacterRushScreen extends StatefulWidget {
  const GameCharacterRushScreen({super.key});

  @override
  State<GameCharacterRushScreen> createState() =>
      _GameCharacterRushScreenState();
}

class _GameCharacterRushScreenState extends State<GameCharacterRushScreen> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();

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

  Widget gameDashboardHeader(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Character Rush',
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
                "Type the falling characters before they disappear!",
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                final gameProvider = Provider.of<CharacterRushProvider>(
                  context,
                  listen: false,
                );
                final bool wasGameRunning = gameProvider.isGameRunning;
                final bool wasGamePaused = gameProvider.isGamePaused;

                if (wasGameRunning && !wasGamePaused) {
                  gameProvider.pauseGame();
                }
                showDialog(
                  context: context,
                  builder: (context) => const ScoreHistoryDialog(),
                );
                if (wasGameRunning && !wasGamePaused) {
                  gameProvider.resumeGame();
                }
              },
              icon: Icon(
                Icons.leaderboard,
                color:
                    themeProvider.isDarkMode ? Colors.white : Colors.grey[600],
              ),
              tooltip: 'Score History',
            ),
            IconButton(
              onPressed: () {
                final gameProvider = Provider.of<CharacterRushProvider>(
                  context,
                  listen: false,
                );
                final bool wasGameRunning = gameProvider.isGameRunning;
                final bool wasGamePaused = gameProvider.isGamePaused;

                if (wasGameRunning && !wasGamePaused) {
                  gameProvider.pauseGame();
                }

                showDialog(
                  context: context,
                  builder: (context) => const GameSettingsDialog(),
                );
                if (wasGameRunning && !wasGamePaused) {
                  gameProvider.resumeGame();
                }
              },
              icon: Icon(
                Icons.settings,
                color:
                    themeProvider.isDarkMode ? Colors.white : Colors.grey[600],
              ),
              tooltip: 'Game Settings',
            ),
          ],
        ),
      ],
    );
  }

  Widget charRushGameStats(
    CharacterRushProvider gameProvider,
    ThemeProvider themeProvider,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black12 : Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          charRushStatItem(
            'Score',
            '${gameProvider.score}',
            Icons.emoji_events,
            Colors.amber,
          ),
          charRushStatItem(
            'Collected',
            '${gameProvider.charactersCollected}',
            Icons.check_circle,
            Colors.green,
          ),
          charRushStatItem(
            'Speed',
            '${gameProvider.currentSpeed.toStringAsFixed(1)}x',
            Icons.speed,
            Colors.blue,
          ),
          charRushTimerDropdown(gameProvider, themeProvider, context),
          // InkWell(
          //   onTap: () {
          //     debugPrint("Ontap of Timer.");
          //   },
          //   child: Container(
          //     padding: EdgeInsets.all(16),
          //     decoration: BoxDecoration(
          //       color: Colors.purple.withOpacity(0.2),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: _buildStatItem(
          //       'Time',
          //       '${gameProvider.gameDuration}s',
          //       Icons.timer,
          //       Colors.purple,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget charRushTimerDropdown(
    CharacterRushProvider gameProvider,
    ThemeProvider themeProvider,
    BuildContext context,
  ) {
    return PopupMenuButton<int>(
      offset: Offset(0, 50),
      onSelected: (int newTime) {
        if (!gameProvider.isGameRunning) {
          gameProvider.updateGameTime(newTime);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot change game time while game is running'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },

      itemBuilder: (BuildContext context) {
        return gameProvider.gameTimeOptions.map((int time) {
          return PopupMenuItem<int>(
            value: time,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$time seconds'),
                if (time == gameProvider.selectedGameTime)
                  Icon(Icons.check, color: themeProvider.primaryColor),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: Colors.purple, size: 24),
                const SizedBox(width: 4),
                Text(
                  '${gameProvider.selectedGameTime}s',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_drop_down, color: Colors.purple, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Game Time',
              style: TextStyle(
                fontSize: 12,
                color:
                    themeProvider.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget charRushStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget charRushGameArea(
    CharacterRushProvider gameProvider,
    ThemeProvider themeProvider,
    Size screenSize,
  ) {
    final isMobile = screenSize.width <= 768;
    final gameAreaHeight = isMobile ? 340.0 : 480.0;

    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: Container(
        height: gameAreaHeight,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.black12 : Colors.white12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            charRushGameBackground(themeProvider.isDarkMode),

            for (int i = 0; i < gameProvider.activeCharacters.length; i++)
              Positioned(
                left:
                    gameProvider.characterPositions[i].dx *
                    (screenSize.width - 80),
                top: gameProvider.characterPositions[i].dy * gameAreaHeight,
                child: GameCharacterAndWordWidget(
                  characterOrWords: gameProvider.activeCharacters[i],
                  onCollected: () {},
                ),
              ),

            if (gameProvider.isGamePaused)
              Center(
                child: Container(
                  height: 180,
                  width: 300,
                  decoration: BoxDecoration(
                    color:
                        themeProvider.isDarkMode
                            ? Colors.grey[800]!.withOpacity(0.9)
                            : Colors.grey[100]!.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pause_circle_filled,
                          size: 48,
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Game Paused',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click anywhere to resume',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (!gameProvider.isGameRunning && !gameProvider.isGamePaused)
              Center(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color:
                        themeProvider.isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.keyboard,
                          size: 48,
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          gameProvider.charactersCollected > 0
                              ? 'Game Over! Final Score: ${gameProvider.score}'
                              : 'Tap to focus and start typing!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            gameProvider.startGame();
                            focusNode.requestFocus();
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            gameProvider.charactersCollected > 0
                                ? 'Play Again'
                                : 'Start Game',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Game Duration: ${gameProvider.selectedGameTime} seconds',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            Offstage(
              child: TextField(
                controller: textController,
                focusNode: focusNode,
                autofocus: true,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (value) {
                  if (value.isNotEmpty && !gameProvider.isGamePaused) {
                    gameProvider.checkCharacter(value);
                    Future.microtask(() => textController.clear());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget charRushGameBackground(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDarkMode
                  ? [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                  ]
                  : [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final gameProvider = Provider.of<CharacterRushProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (gameProvider.isGameRunning) {
          gameProvider.endGame();
        }
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: getResponsivePadding(context),
            child: Column(
              children: [
                gameDashboardHeader(context),
                const SizedBox(height: 40),
                charRushGameStats(gameProvider, themeProvider, context),
                const SizedBox(height: 20),
                charRushGameArea(gameProvider, themeProvider, screenSize),
                const SizedBox(height: 20),
                charRushInstructions(themeProvider.isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget charRushInstructions(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Play:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Type the falling characters on your keyboard\n'
            '• Characters can be typed in uppercase or lowercase\n'
            '• Game speed increases every 15 seconds\n'
            '• Score more points for faster characters\n'
            '• Game automatically pauses when opening settings/score history\n'
            '• Click the timer to change game duration (before starting)',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
