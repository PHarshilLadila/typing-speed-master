import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;

  final SupabaseClient _supabase = Supabase.instance.client;

  AuthProvider() {
    _initializeAuth();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _fetchUserProfile(session.user.id);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));

      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _fetchUserProfile(session.user.id);
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

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final currentUrl = Uri.base.toString();
      debugPrint('Current URL: $currentUrl');

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? currentUrl : 'http://localhost:62621',
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

  Future<void> _fetchUserProfile(String userId) async {
    try {
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
      final user = _supabase.auth.currentUser;
      if (user != null) {
        debugPrint('Creating profile for user: ${user.email}');

        final userMetadata = user.userMetadata ?? {};
        final appMetadata = user.appMetadata ?? {};

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

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signOut();
      _user = null;
      _error = null;

      debugPrint('User signed out successfully');
    } catch (e) {
      _error = 'Failed to sign out: $e';
      debugPrint('Sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    try {
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
}

// import 'package:flutter/foundation.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../models/user_model.dart';

// class AuthProvider with ChangeNotifier {
//   UserModel? _user;
//   bool _isLoading = false;
//   String? _error;

//   UserModel? get user => _user;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   bool get isLoggedIn => _user != null;

//   final SupabaseClient _supabase = Supabase.instance.client;

//   AuthProvider() {
//     _initializeAuth();
//   }

//   Future<void> _initializeAuth() async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final session = _supabase.auth.currentSession;
//       if (session != null) {
//         await _fetchUserProfile(session.user.id);
//       }
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> signInWithGoogle() async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();

//       await _supabase.auth.signInWithOAuth(
//         OAuthProvider
//             .google, // ✅ Use `Provider.google`, not `OAuthProvider.google`
//         redirectTo:
//             'http://localhost:62621', // ✅ Make sure this matches your Supabase settings
//       );
//     } on AuthException catch (e) {
//       _error = e.message;
//     } catch (e) {
//       _error = 'An error occurred during sign in: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _fetchUserProfile(String userId) async {
//     try {
//       final response =
//           await _supabase.from('profiles').select().eq('id', userId).single();

//       if (response != null) {
//         _user = UserModel.fromJson(response);
//         notifyListeners();
//       } else {
//         // Create profile if it doesn't exist
//         await _createUserProfile(userId);
//       }
//     } catch (e) {
//       // If no profile exists, create one
//       if (e is PostgrestException && e.code == 'PGRST116') {
//         await _createUserProfile(userId);
//       } else {
//         debugPrint("Failed to fetch user profile: $e");
//         _error = 'Failed to fetch user profile: $e';
//       }
//     }
//   }

//   Future<void> _createUserProfile(String userId) async {
//     try {
//       final user = _supabase.auth.currentUser;
//       if (user != null) {
//         final newProfile = {
//           'id': userId,
//           'email': user.email,
//           'full_name':
//               user.userMetadata?['full_name'] ??
//               user.userMetadata?['name'] ??
//               user.email?.split('@').first ??
//               'User',
//           'avatar_url':
//               user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
//           'created_at': DateTime.now().toIso8601String(),
//           'updated_at': DateTime.now().toIso8601String(),
//         };

//         await _supabase.from('profiles').insert(newProfile);
//         _user = UserModel.fromJson(newProfile);
//         notifyListeners();
//       }
//     } catch (e) {
//       _error = 'Failed to create user profile: $e';
//     }
//   }

//   Future<void> signOut() async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await _supabase.auth.signOut();
//       _user = null;
//       _error = null;
//     } catch (e) {
//       _error = 'Failed to sign out: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final updates = {
//         'updated_at': DateTime.now().toIso8601String(),
//         if (fullName != null) 'full_name': fullName,
//         if (avatarUrl != null) 'avatar_url': avatarUrl,
//       };

//       await _supabase.from('profiles').update(updates).eq('id', _user!.id);

//       _user = _user!.copyWith(
//         fullName: fullName ?? _user!.fullName,
//         avatarUrl: avatarUrl ?? _user!.avatarUrl,
//       );
//     } catch (e) {
//       _error = 'Failed to update profile: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }
