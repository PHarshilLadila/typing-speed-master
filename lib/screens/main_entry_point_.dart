// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/models/typing_result.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import 'package:typing_speed_master/screens/dashboard_screen.dart';
import 'package:typing_speed_master/screens/history_screen.dart';
import 'package:typing_speed_master/screens/profile_screen.dart';
import 'package:typing_speed_master/screens/typing_test_screen.dart';
import 'package:typing_speed_master/screens/results_screen.dart';
import 'package:typing_speed_master/widgets/custom_appbar.dart';
import 'package:typing_speed_master/widgets/drawer_tiles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MainEntryPoint extends StatefulWidget {
  const MainEntryPoint({super.key});

  @override
  State<MainEntryPoint> createState() => _MainEntryPointState();
}

class _MainEntryPointState extends State<MainEntryPoint> {
  int _selectedIndex = 0;
  Widget? _currentPage;

  final List<Widget> _pages = [
    const TypingTestScreen(),
    const DashboardScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = _pages[_selectedIndex];
  }

  void _onMenuClick(int index) {
    setState(() {
      _selectedIndex = index;
      _currentPage = _pages[index];
    });
  }

  void _showResultsScreen(TypingResult result) {
    setState(() {
      _currentPage = ResultsScreen(
        key: ValueKey(result.timestamp),
        result: result,
        onBackToTest: () {
          setState(() {
            _currentPage = _pages[0];
            _selectedIndex = 0;
          });
        },
        onBackToDashboard: () {
          setState(() {
            _currentPage = _pages[1];
            _selectedIndex = 1;
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;
        final themeProvider = Provider.of<ThemeProvider>(context);
        final authProvider = Provider.of<AuthProvider>(context);

        final Widget bodyContent = _currentPage!;

        final Widget finalBodyContent =
            _currentPage is ResultsScreen
                ? bodyContent
                : TypingTestResultsProvider(
                  showResultsScreen: _showResultsScreen,
                  child: bodyContent,
                );

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: CustomAppBar(
              selectedIndex: _selectedIndex,
              onMenuClick: _onMenuClick,
              isMobile: isMobile,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          drawer:
              isMobile
                  ? Drawer(
                    width: 300,
                    elevation: 16,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(20),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(),
                      child: ListView(
                        children: [
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.amber.shade500,
                                  Colors.amber.shade300,
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 5,
                                  left: 120,
                                  child: Icon(
                                    Icons.speed_outlined,
                                    size: 80,
                                    color:
                                        themeProvider.isDarkMode
                                            ? Colors.black.withOpacity(0.05)
                                            : Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  right: 20,
                                  child: Icon(
                                    Icons.keyboard_alt_outlined,
                                    size: 60,
                                    color:
                                        themeProvider.isDarkMode
                                            ? Colors.black.withOpacity(0.02)
                                            : Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child:
                                            authProvider.isLoggedIn &&
                                                    authProvider
                                                            .user
                                                            ?.avatarUrl !=
                                                        null
                                                ? ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        authProvider
                                                            .user!
                                                            .avatarUrl!,
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => Container(
                                                          width: 48,
                                                          height: 48,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .amber
                                                                        .shade100,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                          child: Icon(
                                                            Icons.person,
                                                            color:
                                                                Colors
                                                                    .amber
                                                                    .shade800,
                                                            size: 24,
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => Container(
                                                          width: 48,
                                                          height: 48,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .amber
                                                                        .shade100,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                          child: Icon(
                                                            Icons.person,
                                                            color:
                                                                Colors
                                                                    .amber
                                                                    .shade800,
                                                            size: 24,
                                                          ),
                                                        ),
                                                  ),
                                                )
                                                : Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.amber.shade100,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.person,
                                                    color:
                                                        Colors.amber.shade800,
                                                    size: 24,
                                                  ),
                                                ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        authProvider.isLoggedIn
                                            ? authProvider.user?.fullName ??
                                                'User'
                                            : "Guest User",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              themeProvider.isDarkMode
                                                  ? Colors.black
                                                  : Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        authProvider.isLoggedIn
                                            ? authProvider.user?.email ?? ''
                                            : "Sign in to save progress",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              themeProvider.isDarkMode
                                                  ? Colors.black.withOpacity(
                                                    0.8,
                                                  )
                                                  : Colors.white.withOpacity(
                                                    0.8,
                                                  ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                DrawerTile(
                                  icon: Icons.keyboard_alt_outlined,
                                  label: "Typing Test",
                                  isDarkMode: themeProvider.isDarkMode,
                                  selected:
                                      _selectedIndex == 0 &&
                                      _currentPage == null,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _onMenuClick(0);
                                  },
                                ),
                                DrawerTile(
                                  icon: Icons.dashboard_outlined,
                                  label: "Dashboard",
                                  isDarkMode: themeProvider.isDarkMode,

                                  selected:
                                      _selectedIndex == 1 &&
                                      _currentPage == null,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _onMenuClick(1);
                                  },
                                ),
                                DrawerTile(
                                  icon: Icons.history_toggle_off_outlined,
                                  label: "History",
                                  isDarkMode: themeProvider.isDarkMode,

                                  selected:
                                      _selectedIndex == 2 &&
                                      _currentPage == null,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _onMenuClick(2);
                                  },
                                ),
                                DrawerTile(
                                  icon: Icons.person_outline_outlined,
                                  label: "Profile",
                                  isDarkMode: themeProvider.isDarkMode,

                                  selected:
                                      _selectedIndex == 3 &&
                                      _currentPage == null,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _onMenuClick(3);
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        themeProvider.isDarkMode
                                            ? Colors.grey.shade800.withOpacity(
                                              0.5,
                                            )
                                            : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          themeProvider.isDarkMode
                                              ? Colors.grey.shade700
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        themeProvider.isDarkMode
                                            ? Icons.dark_mode
                                            : Icons.light_mode,
                                        color:
                                            themeProvider.isDarkMode
                                                ? Colors.amber
                                                : Colors.orange,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          themeProvider.isDarkMode
                                              ? "Dark Mode"
                                              : "Light Mode",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color:
                                                themeProvider.isDarkMode
                                                    ? Colors.grey.shade300
                                                    : Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                      CupertinoSwitch(
                                        applyTheme: true,
                                        value: themeProvider.isDarkMode,
                                        onChanged: (value) {
                                          themeProvider.toggleTheme();
                                        },
                                        activeColor: Colors.amber,
                                        trackColor: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Text(
                                  "Version 1.0.0",
                                  style: TextStyle(
                                    color:
                                        themeProvider.isDarkMode
                                            ? Colors.grey.shade500
                                            : Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : null,
          body: _buildBody(finalBodyContent),
        );
      },
    );
  }

  Widget _buildBody(Widget bodyContent) {
    return bodyContent;
  }
}

class TypingTestResultsProvider extends StatefulWidget {
  final Function(TypingResult) showResultsScreen;
  final Widget child;

  const TypingTestResultsProvider({
    super.key,
    required this.showResultsScreen,
    required this.child,
  });

  static TypingTestResultsProviderState? of(BuildContext context) {
    final state =
        context.findAncestorStateOfType<TypingTestResultsProviderState>();
    return state;
  }

  @override
  TypingTestResultsProviderState createState() =>
      TypingTestResultsProviderState();
}

class TypingTestResultsProviderState extends State<TypingTestResultsProvider> {
  void showResults(TypingResult result) {
    widget.showResultsScreen(result);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
