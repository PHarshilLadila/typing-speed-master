// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/game_character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/features/games/game_character_rush/widget/char_rush_%20character_widget.dart';
import 'package:typing_speed_master/features/games/game_word_master/model/word_master_settings_model.dart';
import 'package:typing_speed_master/features/games/game_word_master/provider/word_master_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';
import 'package:typing_speed_master/widgets/game_widget/game_setting/game_setting_slider_widget.dart';
import 'package:typing_speed_master/widgets/game_widget/score_history/game_empty_state_widget.dart';
import 'package:typing_speed_master/widgets/game_widget/score_history/game_scores_list_widget.dart';

class GameWordMaster extends StatefulWidget {
  const GameWordMaster({super.key});

  @override
  State<GameWordMaster> createState() => _GameWordMasterState();
}

class _GameWordMasterState extends State<GameWordMaster>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  bool _showHistory = false;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
      final gameProvider = Provider.of<WordMasterProvider>(
        context,
        listen: false,
      );
      gameProvider.setWordCollectedCallback(() {
        textController.clear();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    focusNode.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restartGame();
    }
  }

  void _restartGame() {
    final gameProvider = Provider.of<WordMasterProvider>(
      context,
      listen: false,
    );
    gameProvider.endGame();
    gameProvider.clearTypedWord();
    setState(() {
      _showHistory = false;
      _showSettings = false;
    });
    gameProvider.setWordCollectedCallback(() {
      textController.clear();
    });
    focusNode.requestFocus();
  }

  void _onTick(Duration elapsed) {
    final delta = _lastTick == Duration.zero ? elapsed : elapsed - _lastTick;
    _lastTick = elapsed;

    final deltaSeconds = delta.inMicroseconds / 1000000.0;

    if (!mounted) return;
    final gameProvider = Provider.of<WordMasterProvider>(
      context,
      listen: false,
    );
    gameProvider.frameUpdate(deltaSeconds);
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
      width: double.infinity,
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
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
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

          _buildGameControlButton(
            icon: Icons.refresh_rounded,
            label: 'Restart Game',
            color: Colors.orange,
            backgroundColor: Colors.orange.withOpacity(0.1),
            onPressed: () {
              _restartGame();
            },
            themeProvider: themeProvider,
          ),
          // _buildGameControlButton(
          //   icon: Icons.exit_to_app_rounded,
          //   label: 'Quit Game',
          //   color: Colors.redAccent,
          //   backgroundColor: Colors.redAccent.withOpacity(0.1),
          //   onPressed: () {
          //     gameProvider.endGame();
          //     Navigator.of(context).pop();
          //   },
          //   themeProvider: themeProvider,
          // ),
        ],
      ),
      // child: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   // mainAxisSize: MainAxisSize.max,
      //   children: [
      //     wordMasterStatItem(
      //       'Score',
      //       '${gameProvider.score}',
      //       Icons.emoji_events,
      //       Colors.amber,
      //     ),
      //     wordMasterStatItem(
      //       'Collected',
      //       '${gameProvider.wordsCollected}',
      //       Icons.check_circle,
      //       Colors.green,
      //     ),
      //     wordMasterStatItem(
      //       'Speed',
      //       '${gameProvider.currentSpeed.toStringAsFixed(1)}x',
      //       Icons.speed,
      //       Colors.blue,
      //     ),
      //     wordMasterTimerDropdown(gameProvider, themeProvider, context),
      //     // VerticalDivider(
      //     //   color:
      //     //       themeProvider.isDarkMode
      //     //           ? Colors.white.withOpacity(0.1)
      //     //           : Colors.black.withOpacity(0.1),
      //     //   thickness: 1,
      //     //   indent: 10,
      //     //   endIndent: 10,
      //     // ),
      //     _buildGameControlButton(
      //       icon: Icons.refresh_rounded,
      //       label: 'Restart Game',
      //       color: Colors.orange,
      //       backgroundColor: Colors.orange.withOpacity(0.1),
      //       onPressed: () {
      //         _restartGame();
      //       },
      //       themeProvider: themeProvider,
      //     ),
      //     _buildGameControlButton(
      //       icon: Icons.exit_to_app_rounded,
      //       label: 'Quit Game',
      //       color: Colors.redAccent,
      //       backgroundColor: Colors.redAccent.withOpacity(0.1),
      //       onPressed: () {
      //         gameProvider.endGame();
      //         Navigator.of(context).pop();
      //       },
      //       themeProvider: themeProvider,
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildGameControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
    required ThemeProvider themeProvider,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          // border: Border.all(
          //   color:
          //       themeProvider.isDarkMode
          //           ? Colors.white.withOpacity(0.1)
          //           : Colors.black.withOpacity(0.05),
          // ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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

                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildTypedWordDisplay(gameProvider, themeProvider),
                  ),
                ),

                if (gameProvider.isWrongWord &&
                    gameProvider.currentTypedWord.isNotEmpty)
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: wrongWordIndicatorWidget(themeProvider),
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

                Focus(
                  autofocus: true,
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (RawKeyEvent event) {
                      if (event is RawKeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.escape) {
                          textController.clear();
                          gameProvider.clearTypedWord();
                        } else if (event.logicalKey ==
                            LogicalKeyboardKey.enter) {
                          gameProvider.checkWords(
                            gameProvider.currentTypedWord,
                          );
                          textController.clear();
                          gameProvider.clearTypedWord();
                        }
                      }
                    },
                    child: Container(),
                  ),
                ),

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

  Widget wrongWordIndicatorWidget(ThemeProvider themeProvider) {
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
    final gameProvider = Provider.of<WordMasterProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: getResponsivePadding(context),
              child: Column(
                children: [
                  gameDashboardHeader(context),
                  const SizedBox(height: 40),
                  wordMasterGameStats(gameProvider, themeProvider, context),
                  const SizedBox(height: 20),
                  if (_showHistory)
                    _buildHistoryView(gameProvider, themeProvider)
                  else if (_showSettings)
                    _buildSettingsView(gameProvider, themeProvider)
                  else
                    wordMasterGameArea(gameProvider, themeProvider, screenSize),
                  const SizedBox(height: 20),
                  wordMasterInstructions(themeProvider.isDarkMode),
                ],
              ),
            ),
            // FooterWidget(themeProvider: themeProvider),
          ],
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

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
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
        padding: const EdgeInsets.all(14),
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
                setState(() {
                  _showHistory = !_showHistory;
                  _showSettings = false;
                  if (_showHistory && gameProvider.isGameRunning) {
                    gameProvider.pauseGame();
                  } else if (!_showHistory && gameProvider.isGameRunning) {
                    gameProvider.resumeGame();
                  }
                });
              },
              icon: Icon(
                _showHistory ? Icons.sports_esports : Icons.leaderboard,
                color:
                    _showHistory
                        ? themeProvider.primaryColor
                        : (themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.grey[600]),
              ),
              tooltip: _showHistory ? 'Back to Game' : 'Score History',
            ),
            IconButton(
              onPressed: () {
                final gameProvider = Provider.of<WordMasterProvider>(
                  context,
                  listen: false,
                );
                setState(() {
                  _showSettings = !_showSettings;
                  _showHistory = false;
                  if (_showSettings && gameProvider.isGameRunning) {
                    gameProvider.pauseGame();
                  } else if (!_showSettings && gameProvider.isGameRunning) {
                    gameProvider.resumeGame();
                  }
                });
              },
              icon: Icon(
                _showSettings ? Icons.sports_esports : Icons.settings,
                color:
                    _showSettings
                        ? themeProvider.primaryColor
                        : (themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.grey[600]),
              ),
              tooltip: _showSettings ? 'Back to Game' : 'Game Settings',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryView(
    WordMasterProvider gameProvider,
    ThemeProvider themeProvider,
  ) {
    final charRushProvider = Provider.of<CharacterRushProvider>(context);

    return Container(
      height: 580,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black38 : Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
          width: 2,
        ),
      ),
      child: Column(
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
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              if (gameProvider.scores.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                            gameProvider.clearHistory();
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
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showHistory = false;
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                gameProvider.scores.isEmpty
                    ? GameEmptyStateWidget(isDarkMode: themeProvider.isDarkMode)
                    : GameScoresListWidget(
                      charRushProvider: charRushProvider,
                      wordMasterProvider: gameProvider,
                      isDarkMode: themeProvider.isDarkMode,
                      themeProvider: themeProvider,
                      isWordMaster: true,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(
    WordMasterProvider gameProvider,
    ThemeProvider themeProvider,
  ) {
    return Container(
      height: 720,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black38 : Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize your gaming experience',
                    style: TextStyle(
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showSettings = false;
                  });
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Expanded(
          //   child: SingleChildScrollView(
          //     physics: const BouncingScrollPhysics(),
          //     child: Column(
          //       children: [
          //         GameSettingsSliderWidget(
          //           title: 'Initial Speed',
          //           description: 'Starting speed of falling words',
          //           value: gameProvider.settings.initialSpeed,
          //           min: 0.5,
          //           max: 3.0,
          //           divisions: 25,
          //           unit: 'x',
          //           themeProvider: themeProvider,
          //           onChanged: (value) {
          //             gameProvider.updateSettings(
          //               gameProvider.settings.copyWith(initialSpeed: value),
          //             );
          //           },
          //         ),
          //         GameSettingsSliderWidget(
          //           title: 'Speed Increment',
          //           description: 'How much speed increases every 10 seconds',
          //           value: gameProvider.settings.speedIncrement,
          //           min: 0.05,
          //           max: 0.9,
          //           divisions: 9,
          //           unit: 'x',
          //           themeProvider: themeProvider,
          //           onChanged: (value) {
          //             gameProvider.updateSettings(
          //               gameProvider.settings.copyWith(speedIncrement: value),
          //             );
          //           },
          //         ),
          //         GameSettingsSliderWidget(
          //           title: 'Max Words',
          //           description: 'Maximum words on screen at once',
          //           value: gameProvider.settings.maxWords.toDouble(),
          //           min: 3,
          //           max: 10,
          //           divisions: 7,
          //           unit: '',
          //           isInt: true,
          //           themeProvider: themeProvider,
          //           onChanged: (value) {
          //             gameProvider.updateSettings(
          //               gameProvider.settings.copyWith(maxWords: value.toInt()),
          //             );
          //           },
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                GameSettingsSliderWidget(
                  title: 'Initial Speed',
                  description: 'Starting speed of falling words',
                  value: gameProvider.settings.initialSpeed,
                  min: 0.5,
                  max: 3.0,
                  divisions: 25,
                  unit: 'x',
                  themeProvider: themeProvider,
                  onChanged: (value) {
                    gameProvider.updateSettings(
                      gameProvider.settings.copyWith(initialSpeed: value),
                    );
                  },
                ),
                GameSettingsSliderWidget(
                  title: 'Speed Increment',
                  description: 'How much speed increases every 10 seconds',
                  value: gameProvider.settings.speedIncrement,
                  min: 0.05,
                  max: 0.9,
                  divisions: 9,
                  unit: 'x',
                  themeProvider: themeProvider,
                  onChanged: (value) {
                    gameProvider.updateSettings(
                      gameProvider.settings.copyWith(speedIncrement: value),
                    );
                  },
                ),
                GameSettingsSliderWidget(
                  title: 'Max Words',
                  description: 'Maximum words on screen at once',
                  value: gameProvider.settings.maxWords.toDouble(),
                  min: 3,
                  max: 10,
                  divisions: 7,
                  unit: '',
                  isInt: true,
                  themeProvider: themeProvider,
                  onChanged: (value) {
                    gameProvider.updateSettings(
                      gameProvider.settings.copyWith(maxWords: value.toInt()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    CustomDialog.showConfirmationDialog(
                      context: context,
                      title: 'Reset Settings',
                      content:
                          'Are you sure you want to reset all settings to default values?',
                      confirmText: 'Reset',
                      confirmButtonColor: Colors.orange,
                      onConfirm: () {
                        gameProvider.updateSettings(
                          WordMasterSettingsModel(
                            initialSpeed: 1.0,
                            speedIncrement: 0.1,
                            maxWords: 5,
                            soundEnabled: true,
                          ),
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Reset Defaults'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    CustomDialog.showSuccessDialog(
                      context: context,
                      title: 'Settings Saved',
                      content: 'Your game settings have been updated.',
                      onPressed: () {},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
