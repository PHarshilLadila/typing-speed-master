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
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:async';

class GameCharacterRushScreen extends StatefulWidget {
  const GameCharacterRushScreen({super.key});

  @override
  State<GameCharacterRushScreen> createState() =>
      _GameCharacterRushScreenState();
}

class _GameCharacterRushScreenState extends State<GameCharacterRushScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textController = TextEditingController();

  bool _showHistory = false;
  bool _showSettings = false;
  bool _isPerformanceExpanded = true;
  bool _showCharts = false;

  // Animation controllers for charts
  late AnimationController _lineChartController;
  late AnimationController _barChartController;
  late Animation<double> _lineChartAnimation;
  late Animation<double> _barChartAnimation;

  // Touch indicator for charts
  int _touchedBarIndex = -1;
  int _touchedLineIndex = -1;
  Timer? _touchResetTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    // Initialize animation controllers
    _lineChartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _barChartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _lineChartAnimation = CurvedAnimation(
      parent: _lineChartController,
      curve: Curves.easeInOutCubic,
    );
    _barChartAnimation = CurvedAnimation(
      parent: _barChartController,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    focusNode.dispose();
    textController.dispose();
    _lineChartController.dispose();
    _barChartController.dispose();
    _touchResetTimer?.cancel();
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
        ],
      ),
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

    return Container(
      width: value.length >= 4 ? 120 : 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    if (!_showCharts && gameProvider.scores.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showCharts = true;
          });
          _lineChartController.forward(from: 0);
          _barChartController.forward(from: 0);
        }
      });
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black38 : Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.14)
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
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              if (gameProvider.scores.isNotEmpty) ...[
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isPerformanceExpanded = !_isPerformanceExpanded;
                      if (_isPerformanceExpanded) {
                        _lineChartController.forward(from: 0);
                        _barChartController.forward(from: 0);
                      }
                    });
                  },
                  icon: Icon(
                    _isPerformanceExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.analytics_outlined,
                    color: themeProvider.primaryColor,
                  ),
                  tooltip:
                      _isPerformanceExpanded
                          ? 'Hide Performance'
                          : 'Show Performance',
                ),
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
                  label: const Text('Clear'),
                ),
              ],
              const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          gameProvider.scores.isEmpty
              ? GameEmptyStateWidget(isDarkMode: themeProvider.isDarkMode)
              : ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                children: [
                  if (_isPerformanceExpanded)
                    _buildPerformanceSection(gameProvider, themeProvider),
                  const SizedBox(height: 16),
                  _buildHistoryList(gameProvider, themeProvider),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(
    CharacterRushProvider gameProvider,
    ThemeProvider themeProvider,
  ) {
    if (gameProvider.scores.isEmpty) return const SizedBox.shrink();

    final isDark = themeProvider.isDarkMode;
    final scores = gameProvider.scores;

    // Calculate aggregate stats
    int totalScore = 0;
    int totalCollected = 0;
    int maxScore = 0;
    int maxCollected = 0;
    int totalDuration = 0;

    for (var s in scores) {
      totalScore += s.score;
      totalCollected += s.charactersCollected;
      if (s.score > maxScore) maxScore = s.score;
      if (s.charactersCollected > maxCollected)
        maxCollected = s.charactersCollected;
      totalDuration += s.gameDuration;
    }

    final avgScore = totalScore / scores.length;
    final collectionSpeed =
        totalDuration > 0
            ? (totalCollected / totalDuration) * 60
            : 0.0; // chars per minute

    // Determine performance level
    String performanceLabel = 'Beginner';
    Color performanceColor = Colors.blueGrey;
    IconData performanceIcon = Icons.rocket_launch;

    if (avgScore >= 500) {
      performanceLabel = 'Elite';
      performanceColor = Colors.amber;
      performanceIcon = Icons.workspace_premium;
    } else if (avgScore >= 300) {
      performanceLabel = 'Advanced';
      performanceColor = Colors.green;
      performanceIcon = Icons.trending_up;
    } else if (avgScore >= 150) {
      performanceLabel = 'Intermediate';
      performanceColor = Colors.blue;
      performanceIcon = Icons.insights;
    }

    return Column(
      children: [
        // Performance Rank Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: performanceColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: performanceColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.2),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(performanceIcon, color: performanceColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Performance',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      performanceLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: performanceColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Avg. Score',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    avgScore.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Mini Stats Row
        Row(
          children: [
            _buildSmallStatCard(
              'Max Score',
              maxScore.toString(),
              Icons.star_rounded,
              Colors.orange,
              isDark,
            ),
            const SizedBox(width: 12),
            _buildSmallStatCard(
              'Max Collected',
              maxCollected.toString(),
              Icons.bolt_rounded,
              Colors.purple,
              isDark,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSmallStatCard(
              'Games Played',
              scores.length.toString(),
              Icons.sports_esports_rounded,
              Colors.blue,
              isDark,
            ),
            const SizedBox(width: 12),
            _buildSmallStatCard(
              'Speed (CPM)',
              collectionSpeed.toStringAsFixed(1),
              Icons.speed_rounded,
              Colors.green,
              isDark,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Charts Section
        _buildEnhancedCharts(scores, themeProvider),

        const Divider(height: 48),
      ],
    );
  }

  Widget _buildSmallStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCharts(
    List<dynamic> scores,
    ThemeProvider themeProvider,
  ) {
    final isDark = themeProvider.isDarkMode;
    final last10Scores = scores.take(10).toList().reversed.toList();

    if (last10Scores.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Score Trend Chart with enhanced styling
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.grey[900]?.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: themeProvider.primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Score Trend Analysis',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Performance over last ${last10Scores.length} games',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _lineChartAnimation,
                builder: (context, child) {
                  final double maxScore =
                      scores
                          .map((e) => e.score as int)
                          .reduce(math.max)
                          .toDouble();
                  double getYAxisInterval(double maxScore) {
                    if (maxScore >= 10000) return 1000;
                    if (maxScore >= 5000) return 500;

                    if (maxScore >= 3000) return 500;
                    if (maxScore >= 1000) return 100;
                    return 50;
                  }

                  return SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 50,
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: isDark ? Colors.white10 : Colors.black12,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              interval: getYAxisInterval(maxScore),
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < last10Scores.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'G${value.toInt() + 1}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('', style: TextStyle(fontSize: 0));
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black12,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        minY: 0,
                        maxY: (scores
                                    .map((e) => e.score as int)
                                    .reduce(math.max)
                                    .toDouble() *
                                1.1)
                            .clamp(50, double.infinity),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(last10Scores.length, (index) {
                              return FlSpot(
                                index.toDouble(),
                                last10Scores[index].score.toDouble() *
                                    _lineChartAnimation.value,
                              );
                            }),
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: themeProvider.primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                final isHighlighted =
                                    _touchedLineIndex == index;
                                return FlDotCirclePainter(
                                  radius: isHighlighted ? 6 : 4,
                                  color: themeProvider.primaryColor,
                                  strokeWidth: isHighlighted ? 3 : 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: themeProvider.primaryColor.withOpacity(
                                0.1 * _lineChartAnimation.value,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  themeProvider.primaryColor.withOpacity(0.3),
                                  themeProvider.primaryColor.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          // touchTooltipData: LineTouchTooltipData(
                          //   // tooltipBgColor: isDark ? Colors.grey[900]! : Colors.white,
                          //   tooltipRoundedRadius: 8,
                          //   getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          //     return touchedSpots.map((spot) {
                          //       final gameIndex = spot.x.toInt();
                          //       if (gameIndex >= 0 &&
                          //           gameIndex < last10Scores.length) {
                          //         return LineTooltipItem(
                          //           'Game ${gameIndex + 1}\nScore: ${last10Scores[gameIndex].score}',
                          //           TextStyle(
                          //             color:
                          //                 isDark ? Colors.white : Colors.black,
                          //             fontWeight: FontWeight.bold,
                          //             fontSize: 12,
                          //           ),
                          //         );
                          //       }
                          //       return null;
                          //     }).toList();
                          //   },
                          // ),
                          touchTooltipData: LineTouchTooltipData(
                            tooltipRoundedRadius: 10,
                            tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),

                            // 🔥 BACKGROUND COLOR HERE
                            getTooltipColor: (touchedSpot) {
                              return isDark
                                  ? Colors.grey.shade900
                                  : Colors.white;
                            },

                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((spot) {
                                final gameIndex = spot.x.toInt();

                                if (gameIndex >= 0 &&
                                    gameIndex < last10Scores.length) {
                                  return LineTooltipItem(
                                    'Game ${gameIndex + 1}\nScore: ${last10Scores[gameIndex].score}',
                                    TextStyle(
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                }
                                return null;
                              }).toList();
                            },
                          ),
                          touchCallback: (
                            FlTouchEvent event,
                            LineTouchResponse? response,
                          ) {
                            if (response != null &&
                                response.lineBarSpots != null) {
                              setState(() {
                                _touchedLineIndex =
                                    response.lineBarSpots!.first.x.toInt();
                              });
                              _touchResetTimer?.cancel();
                              _touchResetTimer = Timer(
                                const Duration(seconds: 2),
                                () {
                                  setState(() {
                                    _touchedLineIndex = -1;
                                  });
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Legend for score chart
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChartLegendItem(
                    'Score Points',
                    themeProvider.primaryColor,
                    isDark,
                  ),
                  const SizedBox(width: 20),
                  _buildChartLegendItem(
                    'Trend Line',
                    themeProvider.primaryColor.withOpacity(0.5),
                    isDark,
                    isDashed: true,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Collection vs Duration Chart with enhanced styling
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.grey[900]?.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.speed, color: Colors.purple, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Collection Efficiency',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Characters collected vs game duration',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _barChartAnimation,
                builder: (context, child) {
                  final double maxY =
                      scores
                          .map((e) => e.charactersCollected as int)
                          .reduce(math.max)
                          .toDouble() *
                      1.2;
                  double getYAxisInterval(double maxScore) {
                    if (maxScore >= 10000) return 1000;
                    if (maxScore >= 5000) return 500;
                    if (maxScore >= 3000) return 500;
                    if (maxScore >= 1000) return 100;
                    return 50;
                  }

                  return SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            scores
                                .map((e) => e.charactersCollected as int)
                                .reduce(math.max)
                                .toDouble() *
                            1.2,
                        // barTouchData: BarTouchData(
                        //   enabled: true,
                        //   touchTooltipData: BarTouchTooltipData(
                        //     // tooltipBgColor: isDark ? Colors.grey[900]! : Colors.white,
                        //     tooltipRoundedRadius: 8,
                        //     getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        //       final gameIndex = group.x.toInt();
                        //       if (gameIndex >= 0 &&
                        //           gameIndex < last10Scores.length) {
                        //         final game = last10Scores[gameIndex];
                        //         final collectionRate = (game
                        //                     .charactersCollected /
                        //                 game.gameDuration *
                        //                 60)
                        //             .toStringAsFixed(1);
                        //         return BarTooltipItem(
                        //           'Game ${gameIndex + 1}\n',
                        //           TextStyle(
                        //             color: isDark ? Colors.white : Colors.black,
                        //             fontWeight: FontWeight.bold,
                        //             fontSize: 12,
                        //           ),
                        //           children: [
                        //             TextSpan(
                        //               text:
                        //                   'Collected: ${game.charactersCollected}\n',
                        //               // style: TextStyle(
                        //               //   color: Colors.purple,
                        //               //   fontSize: 11,
                        //               // ),
                        //             ),
                        //             TextSpan(
                        //               text: 'Duration: ${game.gameDuration}s\n',
                        //               // style: TextStyle(
                        //               //   color: Colors.blue,
                        //               //   fontSize: 11,
                        //               // ),
                        //             ),
                        //             TextSpan(
                        //               text: 'Rate: $collectionRate/min',
                        //               // style: TextStyle(
                        //               //   color: Colors.green,
                        //               //   fontSize: 11,
                        //               //   fontWeight: FontWeight.w600,
                        //               // ),
                        //             ),
                        //           ],
                        //         );
                        //       }
                        //       return null;
                        //     },
                        //   ),
                        //   touchCallback: (
                        //     FlTouchEvent event,
                        //     BarTouchResponse? response,
                        //   ) {
                        //     if (response != null && response.spot != null) {
                        //       setState(() {
                        //         _touchedBarIndex =
                        //             response.spot!.touchedBarGroupIndex;
                        //       });
                        //       _touchResetTimer?.cancel();
                        //       _touchResetTimer = Timer(
                        //         const Duration(seconds: 2),
                        //         () {
                        //           setState(() {
                        //             _touchedBarIndex = -1;
                        //           });
                        //         },
                        //       );
                        //     }
                        //   },
                        // ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) {
                              return isDark
                                  ? Colors.grey.shade900
                                  : Colors.white;
                            },
                            tooltipRoundedRadius: 10,
                            tooltipPadding: const EdgeInsets.all(10),

                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final gameIndex = group.x.toInt();
                              if (gameIndex >= 0 &&
                                  gameIndex < last10Scores.length) {
                                final game = last10Scores[gameIndex];
                                final collectionRate = (game
                                            .charactersCollected /
                                        game.gameDuration *
                                        60)
                                    .toStringAsFixed(1);

                                return BarTooltipItem(
                                  'Game ${gameIndex + 1}\n',
                                  TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.start,
                                  children: [
                                    TextSpan(
                                      text:
                                          'Collected: ${game.charactersCollected}\n',
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black87,
                                        fontSize: 11,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Duration: ${game.gameDuration}s\n',
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.black87,
                                        fontSize: 11,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Rate: $collectionRate/min',
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return null;
                            },
                          ),
                          touchCallback: (
                            FlTouchEvent event,
                            BarTouchResponse? response,
                          ) {
                            if (response != null && response.spot != null) {
                              setState(() {
                                _touchedBarIndex =
                                    response.spot!.touchedBarGroupIndex;
                              });
                              _touchResetTimer?.cancel();
                              _touchResetTimer = Timer(
                                const Duration(seconds: 2),
                                () {
                                  setState(() {
                                    _touchedBarIndex = -1;
                                  });
                                },
                              );
                            }
                          },
                        ),

                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < last10Scores.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'G${value.toInt() + 1}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${last10Scores[value.toInt()].gameDuration}s',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color:
                                                isDark
                                                    ? Colors.grey[500]
                                                    : Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: getYAxisInterval(maxY),
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('', style: TextStyle(fontSize: 0));
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 10,
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: isDark ? Colors.white10 : Colors.black12,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black12,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black12,
                              width: 1,
                            ),
                          ),
                        ),
                        barGroups: List.generate(last10Scores.length, (index) {
                          final isHighlighted = _touchedBarIndex == index;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY:
                                    last10Scores[index].charactersCollected
                                        .toDouble() *
                                    _barChartAnimation.value,
                                color:
                                    isHighlighted
                                        ? Colors.purple
                                        : Colors.purple.withOpacity(0.7),
                                width: isHighlighted ? 24 : 20,
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.purple.shade700,
                                    Colors.purple.shade300,
                                  ],
                                ),
                              ),
                            ],
                            showingTooltipIndicators: isHighlighted ? [0] : [],
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Legend for bar chart
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChartLegendItem(
                    'Characters Collected',
                    Colors.purple,
                    isDark,
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 12, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Duration below bars',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Summary of collection efficiency
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Colors.grey[800]?.withOpacity(0.3)
                          : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEfficiencyMetric(
                      'Avg/min',
                      '${(scores.map((e) => e.charactersCollected / e.gameDuration * 60).reduce((a, b) => a + b) / scores.length).toStringAsFixed(1)}',
                      Icons.speed,
                      Colors.green,
                      isDark,
                    ),
                    _buildEfficiencyMetric(
                      'Best Game',
                      'G${scores.indexWhere((e) => e.charactersCollected == scores.map((s) => s.charactersCollected).reduce((a, b) => a > b ? a : b)) + 1}',
                      Icons.emoji_events,
                      Colors.amber,
                      isDark,
                    ),
                    _buildEfficiencyMetric(
                      'Total',
                      '${scores.map((e) => e.charactersCollected).reduce((a, b) => a + b)}',
                      Icons.summarize,
                      Colors.blue,
                      isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegendItem(
    String label,
    Color color,
    bool isDark, {
    bool isDashed = false,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: isDashed ? null : color,
            gradient:
                isDashed
                    ? LinearGradient(colors: [color, color], stops: [0.5, 0.5])
                    : null,
            borderRadius: BorderRadius.circular(2),
          ),
          child:
              isDashed
                  ? LayoutBuilder(
                    builder: (context, constraints) {
                      return Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          (constraints.constrainWidth() / 4).floor(),
                          (index) =>
                              Container(width: 2, height: 4, color: color),
                        ),
                      );
                    },
                  )
                  : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyMetric(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(
    CharacterRushProvider gameProvider,
    ThemeProvider themeProvider,
  ) {
    final wordMasterProvider = Provider.of<WordMasterProvider>(context);
    return gameProvider.scores.isEmpty
        ? GameEmptyStateWidget(isDarkMode: themeProvider.isDarkMode)
        : GameScoresListWidget(
          charRushProvider: gameProvider,
          wordMasterProvider: wordMasterProvider,
          isDarkMode: themeProvider.isDarkMode,
          themeProvider: themeProvider,
          isWordMaster: false,
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
