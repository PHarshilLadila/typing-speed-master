// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/character_rush/widget/char_rush_%20character_widget.dart';
import 'package:typing_speed_master/widgets/game_widget/game_settings_dialog.dart';
import 'package:typing_speed_master/widgets/game_widget/game_score_history_dialog.dart';
import 'package:typing_speed_master/features/games/word_master/provider/word_master_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class GameWordMaster extends StatefulWidget {
  const GameWordMaster({super.key});

  @override
  State<GameWordMaster> createState() => _GameWordMasterState();
}

class _GameWordMasterState extends State<GameWordMaster> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
      final gameProvider = Provider.of<WordMasterProvider>(
        context,
        listen: false,
      );
      gameProvider.setWordCollectedCallback(() {
        // Clear the text field when word is collected
        textController.clear();
      });
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    textController.dispose();
    super.dispose();
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

  Widget wordMasterGameStats(
    WordMasterProvider gameProvider,
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
          wordMasterStatItem(
            'Score',
            '${gameProvider.score}',
            Icons.emoji_events,
            Colors.amber,
          ),
          wordMasterStatItem(
            'Collected',
            '${gameProvider.wordsCollected}',
            Icons.check_circle,
            Colors.green,
          ),
          wordMasterStatItem(
            'Speed',
            '${gameProvider.currentSpeed.toStringAsFixed(1)}x',
            Icons.speed,
            Colors.blue,
          ),
          wordMasterTimerDropdown(gameProvider, themeProvider, context),
          // InkWell(
          //   onTap: () {
          //     debugPrint("onTap of Timer.");
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

  // Replace the wordMasterGameArea method with this updated version:

  Widget wordMasterGameArea(
    WordMasterProvider gameProvider,
    ThemeProvider themeProvider,
    Size screenSize,
  ) {
    final isMobile = screenSize.width <= 768;
    final gameAreaHeight = isMobile ? 340.0 : 580.0;

    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: Stack(
        children: [
          Container(
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
                wordMasterGameBackground(themeProvider.isDarkMode),

                for (int i = 0; i < gameProvider.activeWords.length; i++)
                  Positioned(
                    left:
                        gameProvider.wordPositions[i].dx *
                        (screenSize.width - 80),
                    top: gameProvider.wordPositions[i].dy * gameAreaHeight,
                    child: GameCharacterAndWordWidget(
                      isWordMasterGame: true,
                      characterOrWords: gameProvider.activeWords[i],
                      onCollected: () {},
                    ),
                  ),

                // Show typed word at the bottom
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildTypedWordDisplay(gameProvider, themeProvider),
                  ),
                ),

                // Show wrong word animation
                if (gameProvider.isWrongWord &&
                    gameProvider.currentTypedWord.isNotEmpty)
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildWrongWordIndicator(themeProvider),
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
                              gameProvider.wordsCollected > 0
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
                                gameProvider.clearTypedWord();
                                gameProvider.startGame();
                                gameProvider.setWordCollectedCallback(() {
                                  textController.clear();
                                });
                                focusNode.requestFocus();
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: Text(
                                gameProvider.wordsCollected > 0
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

                // Add this to your GameWordMaster widget's build method after the text field:

                // Add this as a widget above the text field or use RawKeyboardListener
                Focus(
                  autofocus: true,
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (RawKeyEvent event) {
                      if (event is RawKeyDownEvent) {
                        // Clear typed word on Escape key
                        if (event.logicalKey == LogicalKeyboardKey.escape) {
                          textController.clear();
                          gameProvider.clearTypedWord();
                        }
                        // Submit word on Enter key
                        else if (event.logicalKey == LogicalKeyboardKey.enter) {
                          // Force check the word
                          gameProvider.checkWords(
                            gameProvider.currentTypedWord,
                          );
                          textController.clear();
                          gameProvider.clearTypedWord();
                        }
                      }
                    },
                    child:
                        Container(), // Empty container, we just need the keyboard listener
                  ),
                ),

                // Hidden text field for keyboard input
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Offstage(
                    child: TextField(
                      controller: textController,
                      focusNode: focusNode,
                      autofocus: true,
                      style: const TextStyle(color: Colors.transparent),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (gameProvider.isGameRunning &&
                            !gameProvider.isGamePaused) {
                          gameProvider.updateTypedWord(value);
                        }
                      },
                      onSubmitted: (value) {
                        // Clear word on enter/return
                        textController.clear();
                        gameProvider.clearTypedWord();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypedWordDisplay(
    WordMasterProvider gameProvider,
    ThemeProvider themeProvider,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color:
            gameProvider.isWrongWord && gameProvider.currentTypedWord.isNotEmpty
                ? Colors.red.withOpacity(0.2)
                : themeProvider.isDarkMode
                ? Colors.black.withOpacity(0.7)
                : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color:
              gameProvider.isWrongWord &&
                      gameProvider.currentTypedWord.isNotEmpty
                  ? Colors.red
                  : themeProvider.primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.keyboard,
            color:
                gameProvider.isWrongWord &&
                        gameProvider.currentTypedWord.isNotEmpty
                    ? Colors.red
                    : themeProvider.primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            gameProvider.currentTypedWord.isNotEmpty
                ? gameProvider.currentTypedWord
                : 'Type the words...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
                  gameProvider.isWrongWord &&
                          gameProvider.currentTypedWord.isNotEmpty
                      ? Colors.red
                      : themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.grey[800],
            ),
          ),
          if (gameProvider.currentTypedWord.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                textController.clear();
                gameProvider.clearTypedWord();
              },
              color:
                  themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildWrongWordIndicator(ThemeProvider themeProvider) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Text(
              'Word not found! Press ESC to clear',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // final isDarkTheme = themeProvider.isDarkMode;
    // final screenWidth = MediaQuery.of(context).size.width;
    // final isMobile = screenWidth <= 768;
    final gameProvider = Provider.of<WordMasterProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: getResponsivePadding(context),
          child: Column(
            children: [
              gameDashboardHeader(context),
              const SizedBox(height: 40),
              wordMasterGameStats(gameProvider, themeProvider, context),
              const SizedBox(height: 20),
              wordMasterGameArea(gameProvider, themeProvider, screenSize),
              const SizedBox(height: 20),
              wordMasterInstructions(themeProvider.isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget wordMasterStatItem(
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

  Widget wordMasterTimerDropdown(
    WordMasterProvider gameProvider,
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

  Widget wordMasterGameBackground(bool isDarkMode) {
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

  Widget wordMasterInstructions(bool isDarkMode) {
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
            '• Type the complete falling words\n'
            '• Press Enter to submit or let autocomplete work\n'
            '• Words can be typed in uppercase or lowercase\n'
            '• Red border shows wrong word - press ESC to clear\n'
            '• Game speed increases every 15 seconds\n'
            '• Score more points for faster words\n'
            '• Click X to clear current typed word\n'
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
                'Word Master',
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
                "Type the falling word before they disappear!",
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
                final gameProvider = Provider.of<WordMasterProvider>(
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
                  builder:
                      (context) =>
                          const GameScoreHistoryDialog(isWordMaster: true),
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
                final gameProvider = Provider.of<WordMasterProvider>(
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
                  builder:
                      (context) => const GameSettingsDialog(isWordMaster: true),
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
}
