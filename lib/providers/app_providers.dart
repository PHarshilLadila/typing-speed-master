import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:typing_speed_master/features/games/game_character_rush/provider/character_rush_provider.dart';
import 'package:typing_speed_master/features/games/game_word_master/provider/word_master_provider.dart';
import 'package:typing_speed_master/features/games/game_word_reflex/provider/word_reflex_provider.dart';
import 'package:typing_speed_master/features/games/provider/game_dashboard_provider.dart';
import 'package:typing_speed_master/features/profile/provider/user_activity_provider.dart';
import 'package:typing_speed_master/features/typing_test/provider/typing_test_provider.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import 'package:typing_speed_master/providers/router_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class AppProviders {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => RouterProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => TypingProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => UserActivityProvider()),
    ChangeNotifierProvider(create: (_) => GameDashboardProvider()),
    ChangeNotifierProvider(create: (_) => CharacterRushProvider()),
    ChangeNotifierProvider(create: (_) => WordMasterProvider()),
    ChangeNotifierProvider(create: (_) => WordReflexProvider()),
  ];
}
