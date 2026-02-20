// providers/game_dashboard_provider.dart
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameDashboardProvider with ChangeNotifier {
  bool _isFavoriteCharacterRush = false;
  bool _isFavoriteWordMaster = false;
  bool _isFavoriteMonsterGame = false;
  bool _isFavoriteDynoGame = false;
  bool _isFavoriteWordReflex = false;
  // bool _isFavoriteSquidGame = false;
  // bool _isFavoriteRangerGame = false;

  bool get isFavoriteCharacterRush => _isFavoriteCharacterRush;
  bool get isFavoriteWordMaster => _isFavoriteWordMaster;
  bool get isFavoriteMonsterGame => _isFavoriteMonsterGame;
  bool get isFavoriteDynoGame => _isFavoriteDynoGame;
  bool get isFavoriteWordReflex => _isFavoriteWordReflex;
  // bool get isFavoriteSquidGame => _isFavoriteSquidGame;
  // bool get isFavoriteRangerGame => _isFavoriteRangerGame;

  GameDashboardProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isFavoriteCharacterRush =
          prefs.getBool('favorite_character_rush') ?? false;
      _isFavoriteWordMaster = prefs.getBool('favorite_word_master') ?? false;
      _isFavoriteMonsterGame = prefs.getBool("favorite_monster_game") ?? false;
      _isFavoriteDynoGame = prefs.getBool("favorite_dyno_game") ?? false;
      _isFavoriteWordReflex = prefs.getBool("favorite_word_reflex") ?? false;
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

  Future<void> toggleFavoriteMonsterGame() async {
    try {
      _isFavoriteMonsterGame = !_isFavoriteMonsterGame;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('favorite_monster_game', _isFavoriteMonsterGame);
      notifyListeners();
      debugPrint('Monster game favorite: $_isFavoriteMonsterGame');
    } catch (e) {
      debugPrint('Error toggling monster game favorite: $e');
      _isFavoriteMonsterGame = !_isFavoriteMonsterGame;
    }
  }

  Future<void> toggleFavoriteDynoGame() async {
    try {
      _isFavoriteDynoGame = !_isFavoriteDynoGame;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('favorite_dyno_game', _isFavoriteDynoGame);
      notifyListeners();
      debugPrint('Dyno game favorite: $_isFavoriteDynoGame');
    } catch (e) {
      debugPrint('Error toggling dyno game favorite: $e');
      _isFavoriteDynoGame = !_isFavoriteDynoGame;
    }
  }

  Future<void> toggleFavoriteWordReflex() async {
    try {
      _isFavoriteWordReflex = !_isFavoriteWordReflex;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('favorite_word_reflex', _isFavoriteWordReflex);
      notifyListeners();
      debugPrint('Word Reflex favorite: $_isFavoriteWordReflex');
    } catch (e) {
      debugPrint('Error toggling Word Reflex favorite: $e');
      _isFavoriteWordReflex = !_isFavoriteWordReflex;
    }
  }

  bool isFavorite(String gameId) {
    switch (gameId) {
      case 'character_rush':
        return _isFavoriteCharacterRush;
      case 'word_master':
        return _isFavoriteWordMaster;
      case 'monster_game':
        return _isFavoriteMonsterGame;
      case 'dyno_game':
        return _isFavoriteDynoGame;
      case 'word_reflex':
        return _isFavoriteWordReflex;
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
      case 'monster_game':
        await toggleFavoriteMonsterGame();
        break;
      case "dyno_game":
        await toggleFavoriteDynoGame();
        break;
      case "word_reflex":
        await toggleFavoriteWordReflex();
        break;
    }
  }
}
