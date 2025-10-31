import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_nav_item.dart';

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
    final authProvider = Provider.of<AuthProvider>(context);

    return AppBar(
      backgroundColor: isDarkMode ? Colors.black38 : Colors.white,
      elevation: 0.5,
      excludeHeaderSemantics: true,
      automaticallyImplyLeading: isMobile,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.keyboard, color: Colors.amber, size: 26),
                SizedBox(width: 6),
                Padding(
                  padding: EdgeInsets.only(right: 48.0),
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
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  CustomNavItem(
                    icon: Icons.keyboard,
                    label: "Test",
                    selected: selectedIndex == 0,
                    onTap: () => onMenuClick(0),
                    isDarkTheme: isDarkMode,
                  ),
                  const SizedBox(width: 12),
                  CustomNavItem(
                    icon: Icons.dashboard_outlined,
                    label: "Dashboard",
                    selected: selectedIndex == 1,
                    onTap: () => onMenuClick(1),
                    isDarkTheme: isDarkMode,
                  ),
                  const SizedBox(width: 12),
                  CustomNavItem(
                    icon: Icons.history_toggle_off_outlined,
                    label: "History",
                    selected: selectedIndex == 2,
                    onTap: () => onMenuClick(2),
                    isDarkTheme: isDarkMode,
                  ),
                  const SizedBox(width: 12),
                  CustomNavItem(
                    icon: Icons.person_outline,
                    label: "Profile",
                    selected: selectedIndex == 3,
                    onTap: () => onMenuClick(3),
                    isDarkTheme: isDarkMode,
                  ),
                ],
              ),
            ),
          Spacer(),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: () {
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).toggleTheme();
                    },
                    icon: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.amber
                                  : Colors.grey[700],
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  authProvider.isLoggedIn &&
                          authProvider.user?.avatarUrl != null
                      ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: authProvider.user!.avatarUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.amber.shade800,
                                  size: 24,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.amber.shade800,
                                  size: 24,
                                ),
                              ),
                        ),
                      )
                      : CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 18,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
