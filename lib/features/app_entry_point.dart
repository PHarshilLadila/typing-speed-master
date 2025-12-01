// // ignore_for_file: deprecated_member_use

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:typing_speed_master/models/typing_test_result_model.dart';
// import 'package:typing_speed_master/theme/provider/theme_provider.dart';
// import 'package:typing_speed_master/providers/auth_provider.dart';
// import 'package:typing_speed_master/features/dashboard/dashboard_screen.dart';
// import 'package:typing_speed_master/features/games/character_rush/game_character_rush_screen.dart';
// import 'package:typing_speed_master/features/games/game_dashboard_screen.dart';
// import 'package:typing_speed_master/features/games/word_master/game_word_master.dart';
// import 'package:typing_speed_master/features/history/history_screen.dart';
// import 'package:typing_speed_master/features/profile/profile_screen.dart';
// import 'package:typing_speed_master/features/typing_test/typing_test_screen.dart';
// import 'package:typing_speed_master/features/typing_test/results_screen.dart';
// import 'package:typing_speed_master/widgets/custom_appbar.dart';
// import 'package:typing_speed_master/widgets/custom_drawer_tiles.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class AppEntryPoint extends StatefulWidget {
//   const AppEntryPoint({super.key});

//   @override
//   State<AppEntryPoint> createState() => AppEntryPointState();
// }

// class AppEntryPointState extends State<AppEntryPoint> {
//   int selectedIndex = 0;
//   Widget? currentPage;
//   bool get isInGameScreen =>
//       currentPage is GameCharacterRushScreen || currentPage is GameWordMaster;

//   final List<Widget> pages = [
//     const TypingTestScreen(),
//     const DashboardScreen(),
//     const HistoryScreen(),
//     const GameDashboardScreen(),
//     const ProfileScreen(),
//   ];

//   final List<Widget> _pageHistory = [];
//   final List<int> _indexHistory = [];

//   @override
//   void initState() {
//     super.initState();
//     currentPage = pages[selectedIndex];
//     _pageHistory.add(currentPage!);
//     _indexHistory.add(selectedIndex);
//   }

//   void onMenuClick(int index) {
//     setState(() {
//       selectedIndex = index;
//       currentPage = pages[index];

//       if (index == 4) {
//         _refreshProfileData();
//       }
//       if (index == 3 && isInGameScreen) {
//         currentPage = pages[3];
//       } else if (index != 3 && isInGameScreen) {
//         currentPage = pages[index];
//       } else {
//         currentPage = pages[index];
//       }
//       if (_pageHistory.isEmpty || _pageHistory.last != currentPage) {
//         _pageHistory.add(currentPage!);
//         _indexHistory.add(selectedIndex);
//       }
//     });
//   }

//   Future<bool> _onWillPop() async {
//     if (_pageHistory.length > 1) {
//       _pageHistory.removeLast();
//       _indexHistory.removeLast();

//       setState(() {
//         currentPage = _pageHistory.last;
//         selectedIndex = _indexHistory.last;
//       });
//       return false;
//     }
//     return true;
//   }

//   void launchGame(String gameId) {
//     setState(() {
//       selectedIndex = 3;
//       switch (gameId) {
//         case "character_rush":
//           currentPage = const GameCharacterRushScreen();
//           break;
//         case "word_master":
//           currentPage = const GameWordMaster();
//           break;
//       }
//     });
//   }

//   Future<void> _refreshProfileData() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     if (authProvider.isLoggedIn && authProvider.user != null) {
//       await authProvider.fetchUserProfile(authProvider.user!.id);
//     }
//   }

//   void showResultsScreen(TypingTestResultModel result) {
//     setState(() {
//       currentPage = ResultsScreen(
//         key: ValueKey(result.timestamp),
//         result: result,
//         onBackToTest: () {
//           setState(() {
//             currentPage = pages[0];
//             selectedIndex = 0;
//           });
//         },
//         onBackToDashboard: () {
//           setState(() {
//             currentPage = pages[1];
//             selectedIndex = 1;
//           });
//         },
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double screenWidth = constraints.maxWidth;
//         bool isMobile = screenWidth < 768;
//         bool isTablet = screenWidth >= 768 && screenWidth < 1024;

//         final themeProvider = Provider.of<ThemeProvider>(context);
//         final authProvider = Provider.of<AuthProvider>(context);

//         final Widget bodyContent = currentPage!;

//         final Widget finalBodyContent =
//             currentPage is ResultsScreen
//                 ? bodyContent
//                 : TypingTestResultsProvider(
//                   showResultsScreen: showResultsScreen,
//                   child: bodyContent,
//                 );

//         return WillPopScope(
//           onWillPop: _onWillPop,

//           child: Scaffold(
//             appBar: PreferredSize(
//               preferredSize: const Size.fromHeight(70),
//               child: CustomAppBar(
//                 selectedIndex: isInGameScreen ? 3 : selectedIndex,
//                 onMenuClick: onMenuClick,
//                 isMobile: isMobile,
//                 isTablet: isTablet,
//                 screenWidth: screenWidth,
//                 isDarkMode: themeProvider.isDarkMode,
//               ),
//             ),
//             drawer:
//                 isMobile || isTablet
//                     ? _buildDrawer(themeProvider, authProvider)
//                     : null,
//             body: buildBody(finalBodyContent),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDrawer(ThemeProvider themeProvider, AuthProvider authProvider) {
//     return Drawer(
//       width: 300,
//       elevation: 16,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
//       ),
//       child: Container(
//         decoration: BoxDecoration(),
//         child: ListView(
//           children: [
//             Container(
//               height: 180,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Colors.amber.shade500, Colors.amber.shade300],
//                 ),
//                 borderRadius: const BorderRadius.only(
//                   bottomRight: Radius.circular(30),
//                 ),
//               ),
//               child: Stack(
//                 children: [
//                   Positioned(
//                     top: 5,
//                     left: 120,
//                     child: Icon(
//                       Icons.speed_outlined,
//                       size: 80,
//                       color:
//                           themeProvider.isDarkMode
//                               ? Colors.black.withOpacity(0.05)
//                               : Colors.white.withOpacity(0.25),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 20,
//                     right: 20,
//                     child: Icon(
//                       Icons.keyboard_alt_outlined,
//                       size: 60,
//                       color:
//                           themeProvider.isDarkMode
//                               ? Colors.black.withOpacity(0.02)
//                               : Colors.white.withOpacity(0.15),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(2),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           child:
//                               authProvider.isLoggedIn &&
//                                       authProvider.user?.avatarUrl != null
//                                   ? ClipOval(
//                                     child: CachedNetworkImage(
//                                       imageUrl: authProvider.user!.avatarUrl!,
//                                       width: 48,
//                                       height: 48,
//                                       fit: BoxFit.cover,
//                                       placeholder:
//                                           (context, url) => Container(
//                                             width: 48,
//                                             height: 48,
//                                             decoration: BoxDecoration(
//                                               color: Colors.amber.shade100,
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: Icon(
//                                               Icons.person,
//                                               color: Colors.amber.shade800,
//                                               size: 24,
//                                             ),
//                                           ),
//                                       errorWidget:
//                                           (context, url, error) => Container(
//                                             width: 48,
//                                             height: 48,
//                                             decoration: BoxDecoration(
//                                               color: Colors.amber.shade100,
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: Icon(
//                                               Icons.person,
//                                               color: Colors.amber.shade800,
//                                               size: 24,
//                                             ),
//                                           ),
//                                     ),
//                                   )
//                                   : Container(
//                                     width: 48,
//                                     height: 48,
//                                     decoration: BoxDecoration(
//                                       color: Colors.amber.shade100,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: Icon(
//                                       Icons.person,
//                                       color: Colors.amber.shade800,
//                                       size: 24,
//                                     ),
//                                   ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           authProvider.isLoggedIn
//                               ? authProvider.user?.fullName ?? 'User'
//                               : "Guest User",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color:
//                                 themeProvider.isDarkMode
//                                     ? Colors.black
//                                     : Colors.white,
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           authProvider.isLoggedIn
//                               ? authProvider.user?.email ?? ''
//                               : "Sign in to save progress",
//                           style: TextStyle(
//                             fontSize: 12,
//                             color:
//                                 themeProvider.isDarkMode
//                                     ? Colors.black.withOpacity(0.8)
//                                     : Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Column(
//                 children: [
//                   CustomDrawerTile(
//                     icon: Icons.keyboard_alt_outlined,
//                     label: "Typing Test",
//                     isDarkMode: themeProvider.isDarkMode,
//                     selected: selectedIndex == 0,
//                     onTap: () {
//                       Navigator.pop(context);
//                       onMenuClick(0);
//                     },
//                   ),
//                   CustomDrawerTile(
//                     icon: Icons.dashboard_outlined,
//                     label: "Dashboard",
//                     isDarkMode: themeProvider.isDarkMode,
//                     selected: selectedIndex == 1,
//                     onTap: () {
//                       Navigator.pop(context);
//                       onMenuClick(1);
//                     },
//                   ),
//                   CustomDrawerTile(
//                     icon: Icons.history_toggle_off_outlined,
//                     label: "History",
//                     isDarkMode: themeProvider.isDarkMode,
//                     selected: selectedIndex == 2,
//                     onTap: () {
//                       Navigator.pop(context);
//                       onMenuClick(2);
//                     },
//                   ),
//                   CustomDrawerTile(
//                     icon: FontAwesomeIcons.fire,
//                     label: "Games",
//                     isDarkMode: themeProvider.isDarkMode,
//                     selected: selectedIndex == 3,
//                     onTap: () {
//                       Navigator.pop(context);
//                       onMenuClick(3);
//                     },
//                   ),
//                   CustomDrawerTile(
//                     icon: Icons.person_outline_outlined,
//                     label: "Profile",
//                     isDarkMode: themeProvider.isDarkMode,
//                     selected: selectedIndex == 4,
//                     onTap: () {
//                       Navigator.pop(context);
//                       onMenuClick(4);
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),

//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     decoration: BoxDecoration(
//                       color:
//                           themeProvider.isDarkMode
//                               ? Colors.grey.shade800.withOpacity(0.5)
//                               : Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color:
//                             themeProvider.isDarkMode
//                                 ? Colors.grey.shade700
//                                 : Colors.grey.shade300,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           themeProvider.isDarkMode
//                               ? Icons.dark_mode
//                               : Icons.light_mode,
//                           color:
//                               themeProvider.isDarkMode
//                                   ? Colors.amber
//                                   : Colors.orange,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             themeProvider.isDarkMode
//                                 ? "Dark Mode"
//                                 : "Light Mode",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               color:
//                                   themeProvider.isDarkMode
//                                       ? Colors.grey.shade300
//                                       : Colors.grey.shade800,
//                             ),
//                           ),
//                         ),
//                         CupertinoSwitch(
//                           applyTheme: true,
//                           value: themeProvider.isDarkMode,
//                           onChanged: (value) {
//                             themeProvider.toggleTheme();
//                           },
//                           activeColor: Colors.amber,
//                           trackColor: Colors.grey,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     "Version 1.0.0",
//                     style: TextStyle(
//                       color:
//                           themeProvider.isDarkMode
//                               ? Colors.grey.shade500
//                               : Colors.grey.shade600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildBody(Widget bodyContent) {
//     return bodyContent;
//   }
// }

// class TypingTestResultsProvider extends StatefulWidget {
//   final Function(TypingTestResultModel) showResultsScreen;
//   final Widget child;

//   const TypingTestResultsProvider({
//     super.key,
//     required this.showResultsScreen,
//     required this.child,
//   });

//   static TypingTestResultsProviderState? of(BuildContext context) {
//     final state =
//         context.findAncestorStateOfType<TypingTestResultsProviderState>();
//     return state;
//   }

//   @override
//   TypingTestResultsProviderState createState() =>
//       TypingTestResultsProviderState();
// }

// class TypingTestResultsProviderState extends State<TypingTestResultsProvider> {
//   void showResults(TypingTestResultModel result) {
//     widget.showResultsScreen(result);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }

// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/models/typing_test_result_model.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import 'package:typing_speed_master/widgets/custom_appbar.dart';
import 'package:typing_speed_master/widgets/custom_drawer_tiles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:typing_speed_master/providers/router_provider.dart';

class AppEntryPoint extends StatefulWidget {
  final Widget child;

  const AppEntryPoint({super.key, required this.child});

  @override
  State<AppEntryPoint> createState() => AppEntryPointState();
}

class AppEntryPointState extends State<AppEntryPoint> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedIndex();
    });
  }

  void _updateSelectedIndex() {
    final routerProvider = Provider.of<RouterProvider>(context, listen: false);
    final location = GoRouterState.of(context).uri.toString();
    final path = GoRouterState.of(context).uri.path;

    int index = 0;

    if (location.contains('/dashboard')) {
      index = 1;
    } else if (location.contains('/history')) {
      index = 2;
    } else if (location.contains('/games')) {
      index = 3;
    } else if (location.contains('/profile')) {
      index = 4;
    } else if (location.contains('/results')) {
      // For results page, check the query parameter to determine which tab to highlight
      final fromParam = GoRouterState.of(context).uri.queryParameters['from'];
      if (fromParam == 'history') {
        index = 2; // Highlight History tab
      } else {
        index = 0; // Highlight Test tab (default)
      }
    } else {
      index = 0; // typing test
    }

    routerProvider.setSelectedIndex(index);
  }

  void onMenuClick(int index) {
    final routerProvider = Provider.of<RouterProvider>(context, listen: false);
    routerProvider.setSelectedIndex(index);

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/dashboard');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/games');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  void launchGame(String gameId) {
    final routerProvider = Provider.of<RouterProvider>(context, listen: false);
    routerProvider.setSelectedIndex(3);

    switch (gameId) {
      case "character_rush":
        context.go('/games/character-rush');
        break;
      case "word_master":
        context.go('/games/word-master');
        break;
    }
  }

  // Future<void> _refreshProfileData() async {
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //   if (authProvider.isLoggedIn && authProvider.user != null) {
  //     await authProvider.fetchUserProfile(authProvider.user!.id);
  //   }
  // }

  void showResultsScreen(TypingTestResultModel result) {
    context.push('/results', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    final routerProvider = Provider.of<RouterProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        bool isMobile = screenWidth < 768;
        bool isTablet = screenWidth >= 768 && screenWidth < 1024;

        final themeProvider = Provider.of<ThemeProvider>(context);
        final authProvider = Provider.of<AuthProvider>(context);

        // final isInGameScreen =
        //     GoRouterState.of(context).fullPath?.contains('/games/') ?? false;

        // Replace this in AppEntryPoint build method:
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: CustomAppBar(
              selectedIndex: routerProvider.selectedIndex,
              onMenuClick: onMenuClick,
              isMobile: isMobile,
              isTablet: isTablet,
              screenWidth: screenWidth,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          drawer:
              (isMobile || isTablet)
                  ? _buildDrawer(
                    themeProvider,
                    authProvider,
                    routerProvider.selectedIndex,
                  )
                  : null,
          // Remove the TypingTestResultsProvider wrapper:
          body: widget.child, // Directly use the child from go_router
        );
      },
    );
  }

  Widget _buildDrawer(
    ThemeProvider themeProvider,
    AuthProvider authProvider,
    int selectedIndex,
  ) {
    return Drawer(
      width: 300,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
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
                  colors: [Colors.amber.shade500, Colors.amber.shade300],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child:
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
                                  : Container(
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
                        const SizedBox(height: 16),
                        Text(
                          authProvider.isLoggedIn
                              ? authProvider.user?.fullName ?? 'User'
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
                                    ? Colors.black.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.8),
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
                  CustomDrawerTile(
                    icon: Icons.keyboard_alt_outlined,
                    label: "Typing Test",
                    isDarkMode: themeProvider.isDarkMode,
                    selected: selectedIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      onMenuClick(0);
                    },
                  ),
                  CustomDrawerTile(
                    icon: Icons.dashboard_outlined,
                    label: "Dashboard",
                    isDarkMode: themeProvider.isDarkMode,
                    selected: selectedIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      onMenuClick(1);
                    },
                  ),
                  CustomDrawerTile(
                    icon: Icons.history_toggle_off_outlined,
                    label: "History",
                    isDarkMode: themeProvider.isDarkMode,
                    selected: selectedIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      onMenuClick(2);
                    },
                  ),
                  CustomDrawerTile(
                    icon: FontAwesomeIcons.fire,
                    label: "Games",
                    isDarkMode: themeProvider.isDarkMode,
                    selected: selectedIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      onMenuClick(3);
                    },
                  ),
                  CustomDrawerTile(
                    icon: Icons.person_outline_outlined,
                    label: "Profile",
                    isDarkMode: themeProvider.isDarkMode,
                    selected: selectedIndex == 4,
                    onTap: () {
                      Navigator.pop(context);
                      onMenuClick(4);
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
                              ? Colors.grey.shade800.withOpacity(0.5)
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
    );
  }
}
