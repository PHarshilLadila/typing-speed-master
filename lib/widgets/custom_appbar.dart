// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:developer';
import 'dart:html' as html;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';
import 'package:typing_speed_master/widgets/custom_nav_item.dart';
import 'package:typing_speed_master/widgets/profile_placeholder_avatar.dart';

class CustomAppBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuClick;
  final bool isMobile;
  final bool isDarkMode;

  const CustomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onMenuClick,
    required this.isMobile,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppBar(
      backgroundColor: isDarkMode ? Colors.black38 : Colors.white,
      elevation: 0.5,
      excludeHeaderSemantics: true,
      leading:
          isMobile
              ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              )
              : null,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard,
                  color: themeProvider.primaryColor,
                  size: 26,
                ),
                SizedBox(width: 6),
                Padding(
                  padding: EdgeInsets.only(right: isMobile ? 16.0 : 40.0),
                  child: Text(
                    "TypeMaster",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!isMobile) appbarNavigationItems(context),

          Spacer(),

          if (!isMobile) appbarRightSideItems(context),
        ],
      ),
    );
  }

  Widget appbarNavigationItems(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableWidth = mediaQuery.size.width - 200;
    final hasSpaceForNav = availableWidth > 400;

    if (!hasSpaceForNav) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomNavItem(
            icon: Icons.keyboard,
            label: "Test",
            selected: selectedIndex == 0,
            onTap: () => onMenuClick(0),
            isDarkTheme: isDarkMode,
          ),
          const SizedBox(width: 8),
          CustomNavItem(
            icon: Icons.dashboard_outlined,
            label: "Dashboard",
            selected: selectedIndex == 1,
            onTap: () => onMenuClick(1),
            isDarkTheme: isDarkMode,
          ),
          const SizedBox(width: 8),
          CustomNavItem(
            icon: Icons.history_toggle_off_outlined,
            label: "History",
            selected: selectedIndex == 2,
            onTap: () => onMenuClick(2),
            isDarkTheme: isDarkMode,
          ),
          const SizedBox(width: 8),
          CustomNavItem(
            icon: Icons.person_outline,
            label: "Profile",
            selected: selectedIndex == 3,
            onTap: () => onMenuClick(3),
            isDarkTheme: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget appbarRightSideItems(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableWidth = mediaQuery.size.width - 200;
    final hasSpaceForRightSide = availableWidth > 150;

    if (!hasSpaceForRightSide) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          IconButton.filled(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            icon: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color:
                      themeProvider.isDarkMode
                          ? themeProvider.primaryColor
                          : Colors.grey[700],
                );
              },
            ),
          ),
          SizedBox(width: 8),
          ProfileDropdown(
            onProfileAction: () {
              if (selectedIndex != 3) {
                onMenuClick(3);
              }
            },
          ),
        ],
      ),
    );
  }
}

class ProfileDropdown extends StatefulWidget {
  final VoidCallback onProfileAction;

  const ProfileDropdown({super.key, required this.onProfileAction});

  @override
  State<ProfileDropdown> createState() => ProfileDropdownState();
}

class ProfileDropdownState extends State<ProfileDropdown> {
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;

  void showProfileOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    overlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: hideProfileOverlay,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    top: offset.dy + size.height + 8,
                    right:
                        MediaQuery.of(context).size.width -
                        offset.dx -
                        size.width,
                    child: appbarProfileCard(),
                  ),
                ],
              ),
            ),
          ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  void hideProfileOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  Widget appbarProfileCard() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvide = Provider.of<ThemeProvider>(context);
    bool isDarkTheme = themeProvide.isDarkMode;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkTheme ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkTheme ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authProvider.isLoggedIn) ...[
              Row(
                children: [
                  authProvider.user?.avatarUrl != null
                      ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                              authProvider.user!.avatarUrl ??
                              "https://api.dicebear.com/7.x/avataaars/svg?seed=marrieage",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => ProfilePlaceHolderAvatar(
                                isDark: isDarkTheme,
                                size: 60,
                              ),
                          errorWidget:
                              (context, url, error) => ProfilePlaceHolderAvatar(
                                isDark: isDarkTheme,
                                size: 60,
                              ),
                        ),
                      )
                      : ProfilePlaceHolderAvatar(isDark: isDarkTheme, size: 60),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.user?.fullName ?? 'User Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.user?.email ?? 'user@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkTheme
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color:
                    isDarkTheme ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              const SizedBox(height: 8),
            ] else ...[
              Row(
                children: [
                  ProfilePlaceHolderAvatar(isDark: isDarkTheme, size: 50),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sign in to access your account',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkTheme
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color:
                    isDarkTheme ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  hideProfileOverlay();
                  if (authProvider.isLoggedIn) {
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
                  } else {
                    authProvider.signInWithGoogle();
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      authProvider.isLoggedIn
                          ? (isDarkTheme
                              ? Colors.red.shade800
                              : Colors.red.shade600)
                          : (isDarkTheme
                              ? Colors.green.shade800
                              : Colors.green.shade600),
                  foregroundColor: Colors.white,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                icon: Icon(
                  authProvider.isLoggedIn ? Icons.logout : Icons.login,
                  size: 16,
                ),
                label: Text(
                  authProvider.isLoggedIn ? 'Sign Out' : 'Sign In with Google',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CompositedTransformTarget(
      link: layerLink,
      child: GestureDetector(
        onTap: showProfileOverlay,
        child:
            authProvider.isLoggedIn && authProvider.user?.avatarUrl != null
                ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl:
                        authProvider.user!.avatarUrl ??
                        "https://api.dicebear.com/7.x/avataaars/svg?seed=profile",
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => ProfilePlaceHolderAvatar(
                          isDark: themeProvider.isDarkMode,
                          size: 40,
                        ),
                    errorWidget:
                        (context, url, error) => ProfilePlaceHolderAvatar(
                          isDark: themeProvider.isDarkMode,
                          size: 40,
                        ),
                  ),
                )
                : ProfilePlaceHolderAvatar(
                  isDark: themeProvider.isDarkMode,
                  size: 40,
                ),
      ),
    );
  }
}
