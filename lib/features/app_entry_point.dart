// // ignore_for_file: deprecated_member_use

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:typing_speed_master/models/typing_test_result_model.dart';
// import 'package:typing_speed_master/theme/provider/theme_provider.dart';
// import 'package:typing_speed_master/providers/auth_provider.dart';
// import 'package:typing_speed_master/widgets/custom_appbar.dart';
// import 'package:typing_speed_master/widgets/custom_drawer_tiles.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:typing_speed_master/providers/router_provider.dart';

// class AppEntryPoint extends StatefulWidget {
//   final Widget child;

//   const AppEntryPoint({super.key, required this.child});

//   @override
//   State<AppEntryPoint> createState() => AppEntryPointState();
// }

// class AppEntryPointState extends State<AppEntryPoint> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       updateSelectedIndex();
//     });
//   }

//   void updateSelectedIndex() {
//     final routerProvider = Provider.of<RouterProvider>(context, listen: false);
//     final location = GoRouterState.of(context).uri.toString();

//     int index = 0;

//     if (location.contains('/dashboard')) {
//       index = 1;
//     } else if (location.contains('/history')) {
//       index = 2;
//     } else if (location.contains('/games')) {
//       index = 3;
//     } else if (location.contains('/profile')) {
//       index = 4;
//     } else if (location.contains('/results')) {
//       final fromParam = GoRouterState.of(context).uri.queryParameters['from'];
//       if (fromParam == 'history') {
//         index = 2;
//       } else {
//         index = 0;
//       }
//     } else {
//       index = 0;
//     }

//     routerProvider.setSelectedIndex(index);
//   }

//   void onMenuClick(int index) {
//     final routerProvider = Provider.of<RouterProvider>(context, listen: false);
//     routerProvider.setSelectedIndex(index);

//     switch (index) {
//       case 0:
//         context.go('/');
//         break;
//       case 1:
//         context.go('/dashboard');
//         break;
//       case 2:
//         context.go('/history');
//         break;
//       case 3:
//         context.go('/games');
//         break;
//       case 4:
//         context.go('/profile');
//         break;
//     }
//   }

//   void launchGame(String gameId) {
//     final routerProvider = Provider.of<RouterProvider>(context, listen: false);
//     routerProvider.setSelectedIndex(3);

//     switch (gameId) {
//       case "character_rush":
//         context.go('/games/character-rush');
//         break;
//       case "word_master":
//         context.go('/games/word-master');
//         break;
//       case "word_reflex":
//         context.go('/games/word-reflex');
//         break;
//     }
//   }

//   void showResultsScreen(TypingTestResultModel result) {
//     context.push('/results', extra: result);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final routerProvider = Provider.of<RouterProvider>(context);

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double screenWidth = constraints.maxWidth;
//         bool isMobile = screenWidth < 768;
//         bool isTablet = screenWidth >= 768 && screenWidth < 1024;

//         final themeProvider = Provider.of<ThemeProvider>(context);
//         final authProvider = Provider.of<AuthProvider>(context);

//         return Scaffold(
//           // persistentFooterAlignment: AlignmentDirectional.bottomEnd,
//           // persistentFooterButtons: [FooterWidget(themeProvider: themeProvider)],
//           appBar: PreferredSize(
//             preferredSize: const Size.fromHeight(70),
//             child: CustomAppBar(
//               selectedIndex: routerProvider.selectedIndex,
//               onMenuClick: onMenuClick,
//               isMobile: isMobile,
//               isTablet: isTablet,
//               screenWidth: screenWidth,
//               isDarkMode: themeProvider.isDarkMode,
//             ),
//           ),
//           drawer:
//               (isMobile || isTablet)
//                   ? appDrawer(
//                     themeProvider,
//                     authProvider,
//                     routerProvider.selectedIndex,
//                   )
//                   : null,
//           body: widget.child,
//         );
//       },
//     );
//   }

//   Widget appDrawer(
//     ThemeProvider themeProvider,
//     AuthProvider authProvider,
//     int selectedIndex,
//   ) {
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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class AppEntryPoint extends StatefulWidget {
  final Widget child;

  const AppEntryPoint({super.key, required this.child});

  @override
  State<AppEntryPoint> createState() => AppEntryPointState();
}

class AppEntryPointState extends State<AppEntryPoint> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _showNoInternetImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateSelectedIndex();
    });
    initConnectivity();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;

      // Check if no internet connection
      bool hasNoInternet = result.contains(ConnectivityResult.none);
      _showNoInternetImage = hasNoInternet;

      // If there are other connections besides none, then we have internet
      if (result.length > 1 ||
          (result.length == 1 && result.first != ConnectivityResult.none)) {
        _showNoInternetImage = false;
      }
    });

    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
  }

  void updateSelectedIndex() {
    final routerProvider = Provider.of<RouterProvider>(context, listen: false);
    final location = GoRouterState.of(context).uri.toString();

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
      final fromParam = GoRouterState.of(context).uri.queryParameters['from'];
      if (fromParam == 'history') {
        index = 2;
      } else {
        index = 0;
      }
    } else {
      index = 0;
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
      case "word_reflex":
        context.go('/games/word-reflex');
        break;
    }
  }

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

        return Scaffold(
          // persistentFooterAlignment: AlignmentDirectional.bottomEnd,
          // persistentFooterButtons: [FooterWidget(themeProvider: themeProvider)],
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
                  ? appDrawer(
                    themeProvider,
                    authProvider,
                    routerProvider.selectedIndex,
                  )
                  : null,
          body: Stack(
            children: [
              widget.child,
              // No Internet Connection Overlay
              if (_showNoInternetImage)
                Positioned.fill(
                  child: Container(
                    color:
                        themeProvider.isDarkMode
                            ? Colors.black.withOpacity(0.9)
                            : Colors.white.withOpacity(0.95),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // No Internet Image
                          Image.asset(
                            'assets/images/no_internet.gif',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.wifi_off_rounded,
                                size: 100,
                                color:
                                    themeProvider.isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No Internet Connection',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Please check your internet connection and try again',
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color:
                                    themeProvider.isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Retry connectivity check
                              await initConnectivity();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget appDrawer(
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
