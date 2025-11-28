// providers/game_dashboard_provider.dart
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameDashboardProvider with ChangeNotifier {
  bool _isFavoriteCharacterRush = false;
  bool _isFavoriteWordMaster = false;

  bool get isFavoriteCharacterRush => _isFavoriteCharacterRush;
  bool get isFavoriteWordMaster => _isFavoriteWordMaster;

  GameDashboardProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isFavoriteCharacterRush =
          prefs.getBool('favorite_character_rush') ?? false;
      _isFavoriteWordMaster = prefs.getBool('favorite_word_master') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavoriteCharacterRush() async {
    try {
      _isFavoriteCharacterRush = !_isFavoriteCharacterRush;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('favorite_character_rush', _isFavoriteCharacterRush);
      notifyListeners();
      debugPrint('Character Rush favorite: $_isFavoriteCharacterRush');
    } catch (e) {
      debugPrint('Error toggling Character Rush favorite: $e');
      _isFavoriteCharacterRush = !_isFavoriteCharacterRush;
    }
  }

  Future<void> toggleFavoriteWordMaster() async {
    try {
      _isFavoriteWordMaster = !_isFavoriteWordMaster;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('favorite_word_master', _isFavoriteWordMaster);
      notifyListeners();
      debugPrint('Word Master favorite: $_isFavoriteWordMaster');
    } catch (e) {
      debugPrint('Error toggling Word Master favorite: $e');
      _isFavoriteWordMaster = !_isFavoriteWordMaster;
    }
  }

  bool isFavorite(String gameId) {
    switch (gameId) {
      case 'character_rush':
        return _isFavoriteCharacterRush;
      case 'word_master':
        return _isFavoriteWordMaster;
      default:
        return false;
    }
  }

  Future<void> toggleFavorite(String gameId) async {
    switch (gameId) {
      case 'character_rush':
        await toggleFavoriteCharacterRush();
        break;
      case 'word_master':
        await toggleFavoriteWordMaster();
        break;
    }
  }
}
