// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/game_character_rush/model/character_rush_settings_model.dart';
import 'package:typing_speed_master/features/games/game_character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/features/games/game_character_rush/widget/char_rush_%20character_widget.dart';
import 'package:typing_speed_master/features/games/game_character_rush/widget/char_rush_instruction_widget.dart';
import 'package:typing_speed_master/features/games/game_word_master/provider/word_master_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';
import 'package:typing_speed_master/widgets/game_widget/game_setting/game_setting_slider_widget.dart';
import 'package:typing_speed_master/widgets/game_widget/score_history/game_empty_state_widget.dart';
import 'package:typing_speed_master/widgets/game_widget/score_history/game_scores_list_widget.dart';

class GameCharacterRushScreen extends StatefulWidget {
  const GameCharacterRushScreen({super.key});

  @override
  State<GameCharacterRushScreen> createState() =>
      _GameCharacterRushScreenState();
}

class _GameCharacterRushScreenState extends State<GameCharacterRushScreen>
    with WidgetsBindingObserver {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();

  bool _showHistory = false;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    final gameProvider = Provider.of<CharacterRushProvider>(
      context,
      listen: false,
    );
    gameProvider.endGame();
    textController.clear();
    setState(() {
      _showHistory = false;
      _showSettings = false;
    });
    focusNode.requestFocus();
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
                final gameProvider = Provider.of<CharacterRushProvider>(
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

  Widget charRushGameStats(
    CharacterRushProvider gameProvider,
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
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
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

          _buildGameControlButton(
            icon: Icons.refresh_rounded,
            label: 'Restart Game',
            color: Colors.orange,
            backgroundColor: Colors.orange,
            onPressed: () {
              _restartGame();
            },
            themeProvider: themeProvider,
          ),
          // _buildGameControlButton(
          //   icon: Icons.exit_to_app_rounded,
          //   label: 'Quit Game',
          //   color: Colors.redAccent,
          //   backgroundColor: Colors.redAccent,
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
      //   children: [
      //     charRushStatItem(
      //       'Score',
      //       '${gameProvider.score}',
      //       Icons.emoji_events,
      //       Colors.amber,
      //     ),
      //     charRushStatItem(
      //       'Collected',
      //       '${gameProvider.charactersCollected}',
      //       Icons.check_circle,
      //       Colors.green,
      //     ),
      //     charRushStatItem(
      //       'Speed',
      //       '${gameProvider.currentSpeed.toStringAsFixed(1)}x',
      //       Icons.speed,
      //       Colors.blue,
      //     ),
      //     charRushTimerDropdown(gameProvider, themeProvider, context),

      //     _buildGameControlButton(
      //       icon: Icons.refresh_rounded,
      //       label: 'Restart Game',
      //       color: Colors.orange,
      //       backgroundColor: Colors.orange,
      //       onPressed: () {
      //         _restartGame();
      //       },
      //       themeProvider: themeProvider,
      //     ),
      //     _buildGameControlButton(
      //       icon: Icons.exit_to_app_rounded,
      //       label: 'Quit Game',
      //       color: Colors.redAccent,
      //       backgroundColor: Colors.redAccent,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
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
            ),
          ],
        ),
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

  Widget charRushStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Expanded(
      child: Container(
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
            SizedBox(height: 8),
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
      ),
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
                            ? Colors.grey[900]
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
          child: Column(
            children: [
              Padding(
                padding: getResponsivePadding(context),
                child: Column(
                  children: [
                    gameDashboardHeader(context),

                    const SizedBox(height: 40),
                    charRushGameStats(gameProvider, themeProvider, context),
                    const SizedBox(height: 20),
                    if (_showHistory)
                      _buildHistoryView(gameProvider, themeProvider)
                    else if (_showSettings)
                      _buildSettingsView(gameProvider, themeProvider)
                    else
                      charRushGameArea(gameProvider, themeProvider, screenSize),
                    const SizedBox(height: 20),
                    CharRushInstructionWidget(
                      isDarkMode: themeProvider.isDarkMode,
                    ),
                  ],
                ),
              ),
              // FooterWidget(themeProvider: themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryView(
    CharacterRushProvider gameProvider,
    ThemeProvider themeProvider,
  ) {
    final wordMasterProvider = Provider.of<WordMasterProvider>(context);

    return Container(
      height: 480,
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
              Spacer(),
              if (gameProvider.scores.isNotEmpty)
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
              SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showHistory = false;
                  });
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                gameProvider.scores.isEmpty
                    ? GameEmptyStateWidget(isDarkMode: themeProvider.isDarkMode)
                    : GameScoresListWidget(
                      charRushProvider: gameProvider,
                      wordMasterProvider: wordMasterProvider,
                      isDarkMode: themeProvider.isDarkMode,
                      themeProvider: themeProvider,
                      isWordMaster: false,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(
    CharacterRushProvider gameProvider,
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
                icon: Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                GameSettingsSliderWidget(
                  title: 'Initial Speed',
                  description: 'Starting speed of falling characters',
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
                  title: 'Max Characters',
                  description: 'Maximum characters on screen at once',
                  value: gameProvider.settings.maxCharacters.toDouble(),
                  min: 3,
                  max: 10,
                  divisions: 7,
                  unit: '',
                  isInt: true,
                  themeProvider: themeProvider,
                  onChanged: (value) {
                    gameProvider.updateSettings(
                      gameProvider.settings.copyWith(
                        maxCharacters: value.toInt(),
                      ),
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
                          CharacterRushSettingsModel(
                            initialSpeed: 1.0,
                            speedIncrement: 0.1,
                            maxCharacters: 5,
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
