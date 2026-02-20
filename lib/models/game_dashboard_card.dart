import 'package:flutter/material.dart';

enum GameType { character, word }

enum GameAvailability { available, comingSoon }

class GameDashboardCard {
  final String gameId;
  final String title;
  final String subtitle;
  final GameType type;
  final Color backgroundColor;
  final GameAvailability availability;
  bool isFavorite;

  GameDashboardCard({
    required this.gameId,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.backgroundColor,
    this.availability = GameAvailability.available,
    this.isFavorite = false,
  });

  bool get isComingSoon => availability == GameAvailability.comingSoon;
}