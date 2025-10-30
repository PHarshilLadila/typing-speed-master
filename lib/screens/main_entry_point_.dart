import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/screens/dashboard_screen.dart';
import 'package:typing_speed_master/screens/history_screen.dart';
import 'package:typing_speed_master/screens/typing_test_screen.dart';
import 'package:typing_speed_master/widgets/custom_appbar.dart';
import 'package:typing_speed_master/widgets/drawer_tiles.dart';

class MainEntryPoint extends StatefulWidget {
  const MainEntryPoint({super.key});

  @override
  State<MainEntryPoint> createState() => _MainEntryPointState();
}

class _MainEntryPointState extends State<MainEntryPoint> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    TypingTestScreen(),
    DashboardScreen(),
    HistoryScreen(),
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
              isDarkMode: themeProvider.isDarkMode,
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
            child: Stack(children: [_pages[_selectedIndex]]),
          ),
        );
      },
    );
  }
}
