import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:typing_speed_master/providers/typing_provider.dart';
import '../models/user_model.dart';

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

  final SupabaseClient _supabase = Supabase.instance.client;

  AuthProvider() {
    _initializeAuth();
    setupAuthListener();
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
      if (session != null && !_isSignOut) {
        await fetchUserProfile(session.user.id);

        await Future.delayed(Duration(seconds: 1));

        final typingProvider = _getTypingProvider();
        if (typingProvider != null) {
          await typingProvider.verifySupabaseConnection();
          await typingProvider.syncLocalResultsToSupabase();
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
        final uri = Uri.parse(currentUrl);
        redirectUrl = '${uri.origin}${uri.path}';
      } else {
        redirectUrl = 'http://localhost:62621';
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

  Future<void> fetchUserProfile(String userId) async {
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
        debugPrint('Profile fetched successfully: ${_user?.email}');
      } else {
        debugPrint('No profile found, creating new one...');
        await _createUserProfile(userId);
      }
      _error = null;
    } catch (e) {
      debugPrint('Error fetching profile: $e');

      if (e is PostgrestException) {
        if (e.code == 'PGRST116' || e.code == 'PGRST205') {
          debugPrint('Profile table issue, creating profile...');
          await _createUserProfile(userId);
        } else {
          _error = 'Database error: ${e.message}';
        }
      } else {
        _error = 'Failed to fetch user profile: $e';
      }
    }
    notifyListeners();
  }

  Future<void> _createUserProfile(String userId) async {
    try {
      if (_isSignOut) return;

      final user = _supabase.auth.currentUser;
      if (user != null) {
        debugPrint('Creating profile for user: ${user.email}');

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
      _error = 'Failed to create user profile: $e';
    }
    notifyListeners();
  }

  // Future<void> signOut() async {
  //   final SharedPreferences preferance = await SharedPreferences.getInstance();
  //   try {
  //     _isLoading = true;
  //     _isSignOut = true;
  //     notifyListeners();

  //     await Future.delayed(const Duration(milliseconds: 100));

  //     await _supabase.auth.signOut();
  //     _user = null;
  //     _error = null;

  //     await preferance.clear();

  //     debugPrint('User signed out successfully');
  //   } catch (e) {
  //     _error = 'Failed to sign out: $e';
  //     debugPrint('Sign out error: $e');
  //   } finally {
  //     _isLoading = false;
  //     _isSignOut = false;
  //     notifyListeners();
  //   }
  // }
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

      // Only clear your app data, not Supabase auth data
      await preference.remove('user');
      await preference.remove('typing_results');
      // Add any other app-specific keys

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

  Future<void> syncUserData() async {
    try {
      final typingProvider = _getTypingProvider();
      if (typingProvider != null) {
        await typingProvider.syncLocalResultsToSupabase();
      }
    } catch (e) {
      debugPrint('Error syncing user data: $e');
    }
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

  Future<void> triggerDataSync() async {
    try {
      dev.log('Triggering data sync after login');

      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      debugPrint('Error triggering data sync: $e');
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
