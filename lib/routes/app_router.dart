import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:typing_speed_master/features/app_entry_point.dart';
import 'package:typing_speed_master/features/dashboard/dashboard_screen.dart';
import 'package:typing_speed_master/features/games/game_character_rush/game_character_rush_screen.dart';
import 'package:typing_speed_master/features/games/game_dashboard_screen.dart';
import 'package:typing_speed_master/features/games/game_word_master/game_word_master.dart';
import 'package:typing_speed_master/features/games/game_word_reflex/game_word_reflex_screen.dart';
import 'package:typing_speed_master/features/history/history_screen.dart';
import 'package:typing_speed_master/features/profile/profile_screen.dart';
import 'package:typing_speed_master/features/typing_test/results_screen.dart';
import 'package:typing_speed_master/features/typing_test/typing_test_screen.dart';
import 'package:typing_speed_master/helper/app_extra_codec.dart';
import 'package:typing_speed_master/models/typing_test_result_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    extraCodec: AppExtraCodec(),
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppEntryPoint(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const TypingTestScreen()),
          ),
          GoRoute(
            path: '/typing-test',
            name: 'typingTest',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const TypingTestScreen()),
          ),
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const DashboardScreen()),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const HistoryScreen()),
          ),
          GoRoute(
            path: '/games',
            name: 'games',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const GameDashboardScreen()),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const ProfileScreen()),
          ),
          GoRoute(
            path: '/games/character-rush',
            name: 'characterRush',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const GameCharacterRushScreen()),
          ),
          GoRoute(
            path: '/games/word-master',
            name: 'wordMaster',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const GameWordMaster()),
          ),
          GoRoute(
            path: '/games/word-reflex',
            name: 'wordReflex',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const GameWordReflexScreen()),
          ),
          GoRoute(
            path: '/results',
            name: 'results',
            pageBuilder: (context, state) {
              final result = state.extra as TypingTestResultModel;
              final from = state.uri.queryParameters['from'];

              return NoTransitionPage(
                child: ResultsScreen(
                  key: ValueKey(result.timestamp),
                  result: result,
                  from: from,
                ),
              );
            },
          ),
        ],
      ),
    ],
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      return null;
    },
  );
}
