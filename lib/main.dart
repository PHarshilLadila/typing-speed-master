// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'providers/typing_provider.dart';
// import 'screens/dashboard_screen.dart';

// void main() {
//   runApp(const TypingSpeedTesterApp());
// }

// class TypingSpeedTesterApp extends StatelessWidget {
//   const TypingSpeedTesterApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => TypingProvider(),
//       child: MaterialApp(
//         title: 'Typing Speed Tester',
//         theme: ThemeData(
//           primarySwatch: Colors.amber,
//           useMaterial3: false,
//           textTheme: GoogleFonts.mulishTextTheme(),
//           scaffoldBackgroundColor: Colors.grey[50],
//           appBarTheme: AppBarTheme(
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black87,
//             elevation: 0,
//             centerTitle: false,
//             titleTextStyle: GoogleFonts.mulish(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           inputDecorationTheme: InputDecorationTheme(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[400]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[400]!),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.blue),
//             ),
//           ),
//         ),
//         home: const DashboardScreen(),
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:typing_speed_master/screens/typing_test_screen.dart';
import 'providers/typing_provider.dart';
import 'providers/theme_provider.dart'; // Add this import
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const TypingSpeedTesterApp());
}

class TypingSpeedTesterApp extends StatelessWidget {
  const TypingSpeedTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TypingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Typing Speed Tester',
            theme: ThemeData(
              primarySwatch: Colors.amber,
              useMaterial3: false,
              textTheme: GoogleFonts.mulishTextTheme(),
              scaffoldBackgroundColor: Colors.grey[50],
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: GoogleFonts.mulish(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.amber,
              useMaterial3: false,
              brightness: Brightness.dark,
              textTheme: GoogleFonts.mulishTextTheme(
                ThemeData.dark().textTheme,
              ),
              scaffoldBackgroundColor: Colors.grey[900],
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: GoogleFonts.mulish(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
                filled: true,
                fillColor: Colors.grey[800],
                labelStyle: const TextStyle(color: Colors.white),
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              cardColor: Colors.grey[800],
              bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[800]),
              dialogTheme: DialogThemeData(backgroundColor: Colors.grey[800]),
            ),
            themeMode: themeProvider.themeMode,
            home: const MainLayout(),
            // home: const DashboardScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    TypingTestScreen(),
    DashboardScreen(),
    Center(child: Text("History Page", style: TextStyle(fontSize: 24))),
    Center(child: Text("Profile Page", style: TextStyle(fontSize: 24))),
  ];

  void _onMenuClick(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;
        final themeProvider = Provider.of<ThemeProvider>(context);
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: CustomAppBar(
              selectedIndex: _selectedIndex,
              onMenuClick: _onMenuClick,
              isMobile: isMobile,
            ),
          ),
          drawer:
              isMobile
                  ? Drawer(
                    child: ListView(
                      children: [
                        const DrawerHeader(
                          child: Text(
                            "TypeMaster",
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        DrawerTile(
                          icon: Icons.keyboard,
                          label: "Test",
                          selected: _selectedIndex == 0,

                          onTap: () {
                            Navigator.pop(context);
                            _onMenuClick(0);
                          },
                        ),
                        DrawerTile(
                          icon: Icons.dashboard_outlined,
                          label: "Dashboard",
                          selected: _selectedIndex == 1,
                          onTap: () {
                            Navigator.pop(context);
                            _onMenuClick(1);
                          },
                        ),
                        DrawerTile(
                          icon: Icons.history,
                          label: "History",
                          selected: _selectedIndex == 2,
                          onTap: () {
                            Navigator.pop(context);
                            _onMenuClick(2);
                          },
                        ),
                        DrawerTile(
                          icon: Icons.person_outline,
                          label: "Profile",
                          selected: _selectedIndex == 3,
                          onTap: () {
                            Navigator.pop(context);
                            _onMenuClick(3);
                          },
                        ),
                      ],
                    ),
                  )
                  : null,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_selectedIndex],
          ),
        );
      },
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuClick;
  final bool isMobile;

  const CustomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onMenuClick,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      excludeHeaderSemantics: true,
      automaticallyImplyLeading: isMobile,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.keyboard, color: Colors.amber, size: 26),
              SizedBox(width: 6),
              Padding(
                padding: EdgeInsets.only(right: 48.0),
                child: Text(
                  "TypeMaster",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          if (!isMobile)
            Row(
              children: [
                NavItem(
                  icon: Icons.keyboard,
                  label: "Test",
                  selected: selectedIndex == 0,
                  onTap: () => onMenuClick(0),
                ),
                const SizedBox(width: 20),
                NavItem(
                  icon: Icons.dashboard_outlined,
                  label: "Dashboard",
                  selected: selectedIndex == 1,
                  onTap: () => onMenuClick(1),
                ),
                const SizedBox(width: 20),
                NavItem(
                  icon: Icons.history,
                  label: "History",
                  selected: selectedIndex == 2,
                  onTap: () => onMenuClick(2),
                ),
                const SizedBox(width: 20),
                NavItem(
                  icon: Icons.person_outline,
                  label: "Profile",
                  selected: selectedIndex == 3,
                  onTap: () => onMenuClick(3),
                ),
              ],
            ),
          Spacer(),
          if (!isMobile)
            Row(
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
                const CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 18,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.black87,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const DrawerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: Colors.grey.shade200,
      leading: Icon(icon, color: selected ? Colors.blue : Colors.black),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
