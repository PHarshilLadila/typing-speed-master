import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:typing_speed_master/models/typing_result.dart';
import 'package:typing_speed_master/providers/typing_provider.dart';
import '../models/user_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  bool _isSignOut = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;
  bool get isSignOut => _isSignOut;
  DateTime? _lastProfileFetchTime;
  static const Duration _profileFetchDebounceTime = Duration(seconds: 2);

  final SupabaseClient _supabase = Supabase.instance.client;

  AuthProvider() {
    _initializeAuth();
    setupAuthListener();
  }
  set user(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> _initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));

      final session = _supabase.auth.currentSession;
      if (session != null) {
        await fetchUserProfile(session.user.id);
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  void setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final event = data.event;

      debugPrint(
        'Auth state change - Event: $event, User: ${session?.user.id}',
      );

      if (session != null && !_isSignOut) {
        if (event == AuthChangeEvent.signedIn) {
          await fetchUserProfile(session.user.id);

          await Future.delayed(Duration(seconds: 1));

          final typingProvider = _getTypingProvider();
          if (typingProvider != null) {
            await typingProvider.verifySupabaseConnection();
          }
        }
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      _isSignOut = false;
      notifyListeners();

      final currentUrl = Uri.base.toString();
      debugPrint('Current URL: $currentUrl');

      String redirectUrl;
      if (kIsWeb) {
        final uri = Uri.parse(currentUrl); // for local
        redirectUrl =
            '${uri.origin}${uri.path}'; // for local (Also update the URL configuration in the Authentication section of the Supabase Studio.)
        // redirectUrl = 'https://typingspeedmaster.vercel.app'; // for production
      } else {
        redirectUrl = 'http://localhost:62621'; // for local
        // redirectUrl = 'https://typingspeedmaster.vercel.app'; // for production
      }

      debugPrint('Using redirect URL: $redirectUrl');

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
    } on AuthException catch (e) {
      _error = 'Authentication failed: ${e.message}';
      debugPrint('AuthException: ${e.message}');
    } catch (e) {
      _error = 'An error occurred during sign in: $e';
      debugPrint('Sign in error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    try {
      _isLoading = true;
      _isSignOut = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 100));

      await _supabase.auth.signOut();
      _user = null;
      _error = null;

      await preference.remove('user');
      await preference.remove('typing_results');

      debugPrint('User signed out successfully');
    } catch (e) {
      _error = 'Failed to sign out: $e';
      debugPrint('Sign out error: $e');
    } finally {
      _isLoading = false;
      _isSignOut = false;
      notifyListeners();
    }
  }

  bool get isSigningOut => _isSignOut || _isLoading;

  void setSignOutState(bool value) {
    _isSignOut = value;
    notifyListeners();
  }

  void cancelOperations() {
    _isSignOut = true;
    notifyListeners();
  }

  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    try {
      if (_isSignOut) return;

      _isLoading = true;
      notifyListeners();

      final updates = {
        'updated_at': DateTime.now().toIso8601String(),
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      await _supabase.from('profiles').update(updates).eq('id', _user!.id);

      _user = _user!.copyWith(
        fullName: fullName ?? _user!.fullName,
        avatarUrl: avatarUrl ?? _user!.avatarUrl,
      );
      _error = null;

      debugPrint('Profile updated successfully');
    } catch (e) {
      _error = 'Failed to update profile: $e';
      debugPrint('Update profile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _user = null;
    _isLoading = false;
    _error = null;
    _isSignOut = false;
    notifyListeners();
  }

  TypingProvider? _getTypingProvider() {
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        return Provider.of<TypingProvider>(context, listen: false);
      }
    } catch (e) {
      debugPrint('Error getting typing provider: $e');
    }
    return null;
  }

  Future<void> updateUserStats(TypingResult result) async {
    try {
      if (_isSignOut || _user == null) {
        dev.log(
          '❌ Cannot update stats: _isSignOut=$_isSignOut, _user=${_user?.id}',
        );
        return;
      }

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      dev.log('📊 Starting stats update for user: ${_user!.id}');
      dev.log('📅 Today: $today, Last activity: ${_user!.lastActivityDate}');

      int newCurrentStreak = _user!.currentStreak;
      final lastActivity = _user!.lastActivityDate;

      if (lastActivity != null) {
        if (_isSameDay(lastActivity, today)) {
          dev.log(
            '🔄 Already updated today, keeping current streak: $newCurrentStreak',
          );
        } else if (_isSameDay(lastActivity, yesterday)) {
          newCurrentStreak++;
          dev.log('🔥 Consecutive day! New streak: $newCurrentStreak');
        } else {
          newCurrentStreak = 1;
          dev.log('💥 Streak broken! Reset to: $newCurrentStreak');
        }
      } else {
        newCurrentStreak = 1;
        dev.log('🎯 First activity! Starting streak: $newCurrentStreak');
      }

      final newLongestStreak =
          newCurrentStreak > _user!.longestStreak
              ? newCurrentStreak
              : _user!.longestStreak;

      dev.log(
        '📈 Current streak: $newCurrentStreak, Longest streak: $newLongestStreak',
      );

      final newTotalTests = _user!.totalTests + 1;
      final newTotalWords = _user!.totalWords + result.wpm;
      final newAverageWpm =
          ((_user!.averageWpm * _user!.totalTests) + result.wpm) /
          newTotalTests;
      final newAverageAccuracy =
          ((_user!.averageAccuracy * _user!.totalTests) + result.accuracy) /
          newTotalTests;

      dev.log('🧮 Stats calculation:');
      dev.log('   - Total tests: ${_user!.totalTests} → $newTotalTests');
      dev.log(
        '   - Average WPM: ${_user!.averageWpm.toStringAsFixed(2)} → ${newAverageWpm.toStringAsFixed(2)}',
      );
      dev.log(
        '   - Average Accuracy: ${_user!.averageAccuracy.toStringAsFixed(2)} → ${newAverageAccuracy.toStringAsFixed(2)}',
      );

      final updates = {
        'current_streak': newCurrentStreak,
        'longest_streak': newLongestStreak,
        'last_activity_date': today.toIso8601String(),
        'total_tests': newTotalTests,
        'total_words': newTotalWords,
        'average_wpm': newAverageWpm,
        'average_accuracy': newAverageAccuracy,
        'updated_at': today.toIso8601String(),
      };

      dev.log('💾 Updating Supabase with: $updates');

      final response =
          await _supabase
              .from('profiles')
              .update(updates)
              .eq('id', _user!.id)
              .select();

      dev.log('✅ Supabase update response: $response');

      if (response.isNotEmpty) {
        _user = _user!.copyWith(
          currentStreak: newCurrentStreak,
          longestStreak: newLongestStreak,
          lastActivityDate: today,
          totalTests: newTotalTests,
          totalWords: newTotalWords,
          averageWpm: newAverageWpm,
          averageAccuracy: newAverageAccuracy,
        );

        dev.log('🎉 User stats updated successfully!');
        dev.log('   - Level: ${_user!.level}');
        dev.log('   - Streak: ${_user!.currentStreak} days');
        dev.log('   - Total Tests: ${_user!.totalTests}');
        dev.log('   - Avg WPM: ${_user!.averageWpm.toStringAsFixed(1)}');

        notifyListeners();
      } else {
        dev.log('❌ Supabase update returned empty response');
      }
    } catch (e) {
      dev.log('💥 Error updating user stats: $e');
      if (e is PostgrestException) {
        dev.log('💥 Postgrest error: ${e.message}');
        dev.log('💥 Details: ${e.details}');
        dev.log('💥 Hint: ${e.hint}');
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> fetchUserProfile(String userId) async {
    final now = DateTime.now();
    if (_lastProfileFetchTime != null &&
        now.difference(_lastProfileFetchTime!) < _profileFetchDebounceTime) {
      debugPrint('Skipping profile fetch - too soon after last fetch');
      return;
    }

    _lastProfileFetchTime = now;

    try {
      if (_isSignOut) return;

      debugPrint('Fetching profile for user: $userId');

      final response =
          await _supabase
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (response != null) {
        _user = UserModel.fromJson(response);
        debugPrint(
          'Profile fetched successfully: ${_user?.email}, Level: ${_user?.level}, Streak: ${_user?.currentStreak}',
        );
      } else {
        debugPrint('No profile found, creating new one...');
        await _createUserProfile(userId);
      }
      _error = null;
    } catch (e) {
      debugPrint('Error fetching profile: $e');

      if (e is PostgrestException && e.code == '23505') {
        debugPrint('Profile already exists, fetching again...');
        await _fetchExistingProfile(userId);
      } else if (e is PostgrestException) {
        _error = 'Database error: ${e.message}';
      } else {
        _error = 'Failed to fetch user profile: $e';
      }
    }
    notifyListeners();
  }

  Future<void> _fetchExistingProfile(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();

      _user = UserModel.fromJson(response);
      debugPrint('Existing profile fetched successfully: ${_user?.email}');
    } catch (e) {
      debugPrint('Error fetching existing profile: $e');
    }
  }

  Future<void> _createUserProfile(String userId) async {
    try {
      if (_isSignOut) return;

      final user = _supabase.auth.currentUser;
      if (user != null) {
        debugPrint('Creating profile for user: ${user.email}');

        final existingProfile =
            await _supabase
                .from('profiles')
                .select()
                .eq('id', userId)
                .maybeSingle();

        if (existingProfile != null) {
          debugPrint(
            'Profile already exists (race condition), using existing profile',
          );
          _user = UserModel.fromJson(existingProfile);
          return;
        }

        final userMetadata = user.userMetadata ?? {};
        final appMetadata = user.appMetadata;

        String? fullName =
            userMetadata['full_name'] ??
            userMetadata['name'] ??
            appMetadata['full_name'] ??
            appMetadata['name'];

        String? avatarUrl =
            userMetadata['avatar_url'] ??
            userMetadata['picture'] ??
            appMetadata['avatar_url'] ??
            appMetadata['picture'];

        final email = user.email ?? 'unknown@email.com';
        final defaultName = email.split('@').first;

        final newProfile = {
          'id': userId,
          'email': email,
          'full_name': fullName ?? defaultName,
          'avatar_url': avatarUrl,
          'level': 'Beginner',
          'current_streak': 0,
          'longest_streak': 0,
          'total_tests': 0,
          'total_words': 0,
          'average_wpm': 0,
          'average_accuracy': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('profiles').insert(newProfile);
        _user = UserModel.fromJson(newProfile);
        _error = null;

        debugPrint('Profile created successfully for: ${_user?.email}');
      }
    } catch (e) {
      debugPrint('Error creating profile: $e');

      if (e is PostgrestException && e.code == '23505') {
        debugPrint('Profile already exists, fetching instead...');
        await _fetchExistingProfile(userId);
      } else {
        _error = 'Failed to create user profile: $e';
      }
    }
  }
}


/*
-- Add new columns to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS level varchar DEFAULT 'Beginner',
ADD COLUMN IF NOT EXISTS current_streak integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS longest_streak integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_activity_date date,
ADD COLUMN IF NOT EXISTS total_tests integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_words integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS average_wpm numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS average_accuracy numeric DEFAULT 0;

-- Create a function to update user level
CREATE OR REPLACE FUNCTION update_user_level()
RETURNS trigger AS $$
BEGIN
  -- Update user level based on average WPM
  NEW.level := CASE
    WHEN NEW.average_wpm < 20 THEN 'Beginner'
    WHEN NEW.average_wpm >= 20 AND NEW.average_wpm < 40 THEN 'Intermediate'
    WHEN NEW.average_wpm >= 40 AND NEW.average_wpm < 60 THEN 'Advanced'
    ELSE 'Expert'
  END;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update level
DROP TRIGGER IF EXISTS update_user_level_trigger ON profiles;
CREATE TRIGGER update_user_level_trigger
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_user_level();
*/