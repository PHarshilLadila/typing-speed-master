// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/models/game_dashboard_card.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class GameCardWidget extends StatelessWidget {
  final GameDashboardCard gameCard;
  final VoidCallback? onTap;

  const GameCardWidget({super.key, required this.gameCard, this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    return Container(
      height: isMobile ? 160 : 340,
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.black12 : Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDarkTheme
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          _buildFallingElements(gameCard.type, isMobile, themeProvider),

          Padding(
            padding:
                isMobile
                    ? const EdgeInsets.all(16.0)
                    : const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gameCard.title,
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkTheme ? Colors.white : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            gameCard.subtitle,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color:
                                  isDarkTheme
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: gameCard.onTapStarIcon,
                      icon: Icon(
                        gameCard.isFavorite
                            ? FontAwesomeIcons.solidStar
                            : FontAwesomeIcons.star,
                        size: 18,
                        color: gameCard.isFavorite ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ],
                ),

                if (isMobile) const Spacer(),

                if (!isMobile) ...[
                  const Spacer(),
                  _buildTrapezoidGameArea(themeProvider),
                ],

                InkWell(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    height: isMobile ? 44 : 50,
                    decoration: BoxDecoration(
                      color: gameCard.backgroundColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gameCard.backgroundColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Play Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: isMobile ? 16 : 18,
                        ),
                      ],
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

  Widget _buildFallingElements(
    GameType type,
    bool isMobile,
    ThemeProvider themeProvider,
  ) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final elementCount = isMobile ? 6 : 10;
          final List<Rect> usedPositions = [];

          return Stack(
            children: List.generate(elementCount, (index) {
              final random = Random();
              double left, top, size;

              Rect newRect;
              int tries = 0;

              do {
                size =
                    isMobile
                        ? random.nextDouble() * 20 + 22
                        : random.nextDouble() * 25 + 28;

                left = random.nextDouble() * (constraints.maxWidth - size);
                top = random.nextDouble() * (constraints.maxHeight - size);

                newRect = Rect.fromLTWH(left, top, size + 8, size + 8);
                tries++;
              } while (usedPositions.any((r) => r.overlaps(newRect)) &&
                  tries < 12);

              usedPositions.add(newRect);

              final opacity =
                  themeProvider.isDarkMode
                      ? random.nextDouble() * 0.2 + 0.15
                      : random.nextDouble() * 0.3 + 0.1;

              final color = _getRandomColor(random, type);

              return Positioned(
                left: left,
                top: top,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity,
                    child:
                        type == GameType.character
                            ? _buildCharacterElement(random, color, size)
                            : _buildWordElement(random, color, size),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildCharacterElement(Random random, Color color, double size) {
    final characters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    final char = characters[random.nextInt(characters.length)];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.6), width: 1.2),
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            color: color,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWordElement(Random random, Color color, double size) {
    final words = [
      'TYPING',
      'IMPROVMENT',
      'HARD',
      'VELOCITY',
      'SPEED',
      'MASTER',
      'CONSISTENCY',
    ];
    final word = words[random.nextInt(words.length)];

    return Transform.rotate(
      angle: random.nextDouble() * 0.2 - 0.1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Text(
          word,
          style: TextStyle(
            color: color,
            fontSize: size * 0.25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getRandomColor(Random random, GameType type) {
    final colors =
        type == GameType.character
            ? [
              Colors.blue.shade400,
              Colors.green.shade400,
              Colors.orange.shade400,
              Colors.purple.shade400,
              Colors.red.shade400,
            ]
            : [
              Colors.deepOrange.shade400,
              Colors.indigo.shade400,
              Colors.teal.shade400,
              Colors.amber.shade700,
            ];

    return colors[random.nextInt(colors.length)];
  }

  Widget _buildTrapezoidGameArea(ThemeProvider themeProvider) {
    return ClipPath(
      clipper: TrapezoidClipper(),
      child: Container(
        color: themeProvider.isDarkMode ? Colors.black : Colors.white,
        child: Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gameCard.backgroundColor.withOpacity(0.4),
                gameCard.backgroundColor.withOpacity(0.15),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Transform(
                alignment: Alignment.center,
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(-0.4),
                child: Text(
                  gameCard.title,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: gameCard.backgroundColor.withOpacity(0.8),
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Trapezoid Clipper
class TrapezoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.1, 0);
    path.lineTo(size.width * 0.9, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
