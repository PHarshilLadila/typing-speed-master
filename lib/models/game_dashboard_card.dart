import 'package:flutter/material.dart';

enum GameType { character, word }

class GameDashboardCard {
  final String title;
  final String subtitle;
  final GameType type;
  final Color backgroundColor;
  final String gameId;
  final bool isFavorite;
  final void Function()? onTapStarIcon;

  const GameDashboardCard({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.backgroundColor,
    required this.gameId,
    required this.isFavorite,
    required this.onTapStarIcon,
  });
}
