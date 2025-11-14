// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:developer';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restart_app/restart_app.dart';
import 'package:typing_speed_master/models/user_model.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading && !authProvider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return profileUI(context, authProvider, isDark);
      },
    );
  }

  Widget profileUI(
    BuildContext context,
    AuthProvider authProvider,
    bool isDark,
  ) {
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final borderColor =
        isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth < 1024;

        return SingleChildScrollView(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              profileHeader(context, isMobile, isTablet),
              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 48,
                  vertical: isMobile ? 20 : 24,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: profileContent(
                  context,
                  authProvider,
                  isDark,
                  isMobile,
                  isTablet,
                ),
              ),

              const SizedBox(height: 32),

              if (authProvider.isLoggedIn)
                profileDangerZone(
                  context,
                  authProvider,
                  isDark,
                  isMobile,
                  isTablet,
                ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget profileHeader(BuildContext context, bool isMobile, bool isTablet) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your account and preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget profileContent(
    BuildContext context,
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
    bool isTablet,
  ) {
    final textColor = isDark ? Colors.white : Colors.black;
    final user = authProvider.user;

    return Column(
      children: [
        if (isMobile)
          profileMobileLayout(authProvider, isDark, isMobile, textColor, user)
        else
          profileDesktopLayout(
            authProvider,
            isDark,
            isMobile,
            isTablet,
            textColor,
            user,
          ),
      ],
    );
  }

  Widget profileMobileLayout(
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
    Color textColor,
    UserModel? user,
  ) {
    return Column(
      children: [
        profileAvatar(user, isDark, isMobile ? 80.0 : 100.0),
        const SizedBox(height: 20),

        profileUserInfo(authProvider, user, textColor, isMobile, true, isDark),
        const SizedBox(height: 24),

        profileActionButton(authProvider, isDark, isMobile),
      ],
    );
  }

  Widget profileDesktopLayout(
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
    bool isTablet,
    Color textColor,
    UserModel? user,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        profileAvatar(user, isDark, isTablet ? 100.0 : 120.0),
        const SizedBox(width: 24),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileUserInfo(
                authProvider,
                user,
                textColor,
                isMobile,
                false,
                isDark,
              ),
              const SizedBox(height: 20),

              if (authProvider.isLoggedIn && user != null)
                profileUserTags(user, isDark, isMobile),
            ],
          ),
        ),

        profileActionButton(authProvider, isDark, isMobile),
      ],
    );
  }

  Widget profileAvatar(UserModel? user, bool isDark, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ClipOval(
        child:
            user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: user.avatarUrl!,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => profilePlaceholderAvatar(isDark, size),
                  errorWidget:
                      (context, url, error) =>
                          profilePlaceholderAvatar(isDark, size),
                )
                : profilePlaceholderAvatar(isDark, size),
      ),
    );
  }

  Widget profileUserInfo(
    AuthProvider authProvider,
    UserModel? user,
    Color textColor,
    bool isMobile,
    bool isCentered,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          authProvider.isLoggedIn ? (user?.fullName ?? 'User') : 'Welcome!',
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment:
              isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.envelope,
              size: isMobile ? 14 : 16,
              color: isDark ? Colors.amberAccent : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                authProvider.isLoggedIn
                    ? (user?.email ?? 'No email')
                    : 'Sign in to access your account',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: textColor.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        if (authProvider.isLoggedIn && user?.createdAt != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment:
                isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.calendar,
                size: isMobile ? 12 : 14,
                color: isDark ? Colors.amberAccent : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                'Joined ${DateFormat('MMM yyyy').format(user!.createdAt!)}',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget profileUserTags(UserModel user, bool isDark, bool isMobile) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        profileTags('ID: ${user.id.substring(0, 8)}...', isDark),
        profileTags('Intermediate', isDark),
        profileTags('Streak Maintained 🔥', isDark),
      ],
    );
  }

  Widget profileActionButton(
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
  ) {
    if (authProvider.isLoggedIn) {
      return SizedBox(
        width: isMobile ? double.infinity : null,
        child: TextButton(
          onPressed: () {
            showEditProfileDialog(context, authProvider);
          },
          style: TextButton.styleFrom(
            backgroundColor:
                isDark ? Colors.amberAccent.shade400 : Colors.amber,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: isMobile ? 12 : 14,
            ),
          ),
          child: Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: isMobile ? double.infinity : null,
        child: ElevatedButton(
          onPressed:
              authProvider.isLoading
                  ? null
                  : () {
                    authProvider.signInWithGoogle();
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.grey[850] : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.grey[800],
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 14 : 16,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.google, size: 16),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget profileDangerZone(
    BuildContext context,
    AuthProvider authProvider,
    bool isDark,
    bool isMobile,
    bool isTablet,
  ) {
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 16 : 20,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign out from your account',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    CustomDialog.showSignOutDialog(
                      context: context,
                      onConfirm: () async {
                        Navigator.of(context, rootNavigator: true).pop();
                        await authProvider.signOut();
                        await Future.delayed(Duration(milliseconds: 500));
                        if (kIsWeb) {
                          html.window.location.assign(
                            html.window.location.href,
                          );
                        } else {
                          Restart.restartApp();
                        }
                        log("✅ User Sign Out Successful and App Restarted");
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget profilePlaceholderAvatar(bool isDark, double size) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.blue.shade100,
      child: Center(
        child: Icon(
          Icons.person,
          size: size * 0.4,
          color: isDark ? Colors.amberAccent : Colors.blue.shade600,
        ),
      ),
    );
  }

  Widget profileTags(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    final nameController = TextEditingController(text: user?.fullName ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDark = themeProvider.isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: Text(
            'Edit Profile',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.amberAccent : Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[800],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  authProvider.updateProfile(
                    fullName: nameController.text.trim(),
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? Colors.amberAccent.shade400 : Colors.amber,
              ),
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}
