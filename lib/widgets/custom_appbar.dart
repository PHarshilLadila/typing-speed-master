// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:developer';
import 'dart:html' as html;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';
import 'package:typing_speed_master/widgets/custom_nav_item.dart';
import 'package:typing_speed_master/features/profile/widget/profile_placeholder_avatar.dart';
import 'package:typing_speed_master/providers/router_provider.dart';

class CustomAppBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuClick;
  final bool isMobile;
  final bool isTablet;
  final double screenWidth;
  final bool isDarkMode;

  const CustomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onMenuClick,
    required this.isMobile,
    required this.isTablet,
    required this.screenWidth,
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
          isMobile || isTablet
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
          GestureDetector(
            onTap: () {
              final routerProvider = Provider.of<RouterProvider>(
                context,
                listen: false,
              );
              routerProvider.setSelectedIndex(0);
              context.go('/');
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard,
                    color: themeProvider.primaryColor,
                    size: 26,
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: EdgeInsets.only(
                      right: (isMobile || isTablet) ? 16.0 : 40.0,
                    ),
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
          ),

          if (!isMobile && !isTablet) _buildDesktopNavigation(),

          const Spacer(),

          if (!isMobile) _buildRightSideItems(context),
        ],
      ),
    );
  }

  Widget _buildDesktopNavigation() {
    final double availableWidth = screenWidth - 300;

    if (availableWidth < 400) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconOnlyNavItem(Icons.keyboard, 0),
            const SizedBox(width: 4),
            _buildIconOnlyNavItem(Icons.dashboard_outlined, 1),
            const SizedBox(width: 4),
            _buildIconOnlyNavItem(Icons.history_toggle_off_outlined, 2),
            const SizedBox(width: 4),
            _buildIconOnlyNavItem(FontAwesomeIcons.fire, 3),
            const SizedBox(width: 4),
            _buildIconOnlyNavItem(Icons.person_outline, 4),
          ],
        ),
      );
    } else if (availableWidth < 500) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompactNavItem("Test", Icons.keyboard, 0),
            const SizedBox(width: 6),
            _buildCompactNavItem("Stats", Icons.dashboard_outlined, 1),
            const SizedBox(width: 6),
            _buildCompactNavItem(
              "History",
              Icons.history_toggle_off_outlined,
              2,
            ),
            const SizedBox(width: 6),
            _buildCompactNavItem("Games", FontAwesomeIcons.fire, 3),
            const SizedBox(width: 6),
            _buildCompactNavItem("Profile", Icons.person_outline, 4),
          ],
        ),
      );
    } else {
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
              icon: FontAwesomeIcons.fire,
              label: "Games",
              selected: selectedIndex == 3,
              onTap: () => onMenuClick(3),
              isDarkTheme: isDarkMode,
            ),
            const SizedBox(width: 8),
            CustomNavItem(
              icon: Icons.person_outline,
              label: "Profile",
              selected: selectedIndex == 4,
              onTap: () => onMenuClick(4),
              isDarkTheme: isDarkMode,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildIconOnlyNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color:
            selectedIndex == index
                ? Colors.amber
                : (isDarkMode ? Colors.white70 : Colors.black54),
        size: 20,
      ),
      onPressed: () => onMenuClick(index),
      tooltip: _getTooltipForIndex(index),
    );
  }

  Widget _buildCompactNavItem(String label, IconData icon, int index) {
    return GestureDetector(
      onTap: () => onMenuClick(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color:
              selectedIndex == index
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  selectedIndex == index
                      ? Colors.amber
                      : (isDarkMode ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    selectedIndex == index
                        ? Colors.amber
                        : (isDarkMode ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTooltipForIndex(int index) {
    switch (index) {
      case 0:
        return "Typing Test";
      case 1:
        return "Dashboard";
      case 2:
        return "History";
      case 3:
        return "Games";
      case 4:
        return "Profile";
      default:
        return "";
    }
  }

  Widget _buildRightSideItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(width: 8),
          ProfileDropdown(
            onProfileAction: () {
              if (selectedIndex != 4) {
                onMenuClick(4);
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
                    child: _appbarProfileCard(),
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

  Widget _appbarProfileCard() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkTheme = themeProvider.isDarkMode;

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
                          imageUrl: authProvider.user!.avatarUrl!,
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
                        await authProvider.signOut();
                        await Future.delayed(const Duration(milliseconds: 500));
                        if (kIsWeb) {
                          html.window.location.assign(
                            html.window.location.href,
                          );
                        } else {
                          Restart.restartApp();
                        }

                        log("User Sign Out Successful and App Restarted");
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
                    imageUrl: authProvider.user!.avatarUrl!,
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
