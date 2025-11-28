import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/features/games/character_rush/widget/character_rush_%20character_widget.dart';
import 'package:typing_speed_master/features/games/character_rush/widget/game_settings_dialog.dart';
import 'package:typing_speed_master/features/games/character_rush/widget/score_history_dialog.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class GameCharacterRush extends StatefulWidget {
  const GameCharacterRush({super.key});

  @override
  State<GameCharacterRush> createState() => _GameCharacterRushState();
}

class _GameCharacterRushState extends State<GameCharacterRush> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

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
                showDialog(
                  context: context,
                  builder: (context) => const ScoreHistoryDialog(),
                );
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
                showDialog(
                  context: context,
                  builder: (context) => const GameSettingsDialog(),
                );
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

  Widget _buildGameStats(
    CharacterRushProvider gameProvider,
    ThemeProvider themeProvider,
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
          _buildStatItem(
            'Score',
            '${gameProvider.score}',
            Icons.emoji_events,
            Colors.amber,
          ),
          _buildStatItem(
            'Collected',
            '${gameProvider.charactersCollected}',
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatItem(
            'Speed',
            '${gameProvider.currentSpeed.toStringAsFixed(1)}x',
            Icons.speed,
            Colors.blue,
          ),
          _buildStatItem(
            'Time',
            '${gameProvider.gameDuration}s',
            Icons.timer,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
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

  Widget _buildGameArea(
    CharacterRushProvider gameProvider,
    ThemeProvider themeProvider,
    Size screenSize,
  ) {
    final isMobile = screenSize.width <= 768;
    final gameAreaHeight = isMobile ? 180.0 : 340.0;

    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
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
            // Game area background
            _buildGameBackground(themeProvider.isDarkMode),

            // Falling characters
            for (int i = 0; i < gameProvider.activeCharacters.length; i++)
              Positioned(
                left:
                    gameProvider.characterPositions[i].dx *
                    (screenSize.width - 80),
                top: gameProvider.characterPositions[i].dy * gameAreaHeight,
                child: CharacterWidget(
                  character: gameProvider.activeCharacters[i],
                  onCollected: () {
                    // This will be handled by keyboard input
                  },
                ),
              ),

            // Game instructions or start button
            if (!gameProvider.isGameRunning)
              Center(
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
                          _focusNode.requestFocus();
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          gameProvider.charactersCollected > 0
                              ? 'Play Again'
                              : 'Start Game',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Hidden text field for keyboard input
            Offstage(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                autofocus: true,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    gameProvider.checkCharacter(value);
                    Future.microtask(() => _textController.clear());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBackground(bool isDarkMode) {
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
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
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
                _buildGameStats(gameProvider, themeProvider),
                const SizedBox(height: 20),
                _buildGameArea(gameProvider, themeProvider, screenSize),
                const SizedBox(height: 20),
                _buildInstructions(themeProvider.isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions(bool isDarkMode) {
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
            '• Game speed increases every 10 seconds\n'
            '• Score more points for faster characters\n'
            '• Collect as many as you can before they reach the bottom!',
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
