import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/models/typing_result.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/screens/dashboard_screen.dart';
import 'package:typing_speed_master/screens/history_screen.dart';
import 'package:typing_speed_master/screens/profile_screen.dart';
import 'package:typing_speed_master/screens/typing_test_screen.dart';
import 'package:typing_speed_master/screens/results_screen.dart';
import 'package:typing_speed_master/widgets/custom_appbar.dart';
import 'package:typing_speed_master/widgets/drawer_tiles.dart';

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

  void _onMenuClick(int index) {
    setState(() {
      _selectedIndex = index;
      _currentPage = null;
    });
  }

  void _showResultsScreen(TypingResult result) {
    setState(() {
      _currentPage = ResultsScreen(
        key: ValueKey(result.timestamp),
        result: result,
        onBackToTest: () {
          setState(() {
            _currentPage = null;
            _selectedIndex = 0;
          });
        },
        onBackToDashboard: () {
          setState(() {
            _currentPage = null;
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

        final Widget bodyContent = _currentPage ?? _pages[_selectedIndex];

        final Widget finalBodyContent =
            _currentPage == null
                ? TypingTestResultsProvider(
                  showResultsScreen: _showResultsScreen,
                  child: bodyContent,
                )
                : bodyContent;

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
                          selected: _selectedIndex == 0 && _currentPage == null,
                          onTap: () {
                            Navigator.pop(context);
                            _onMenuClick(0);
                          },
                        ),
                        DrawerTile(
                          icon: Icons.dashboard_outlined,
                          label: "Dashboard",
                          selected: _selectedIndex == 1 && _currentPage == null,
                          onTap: () {
                            Navigator.pop(context);
                            _onMenuClick(1);
                          },
                        ),
                        DrawerTile(
                          icon: Icons.history,
                          label: "History",
                          selected: _selectedIndex == 2 && _currentPage == null,
                          onTap: () {
                            Navigator.pop(context);
                            _onMenuClick(2);
                          },
                        ),
                        DrawerTile(
                          icon: Icons.person_outline,
                          label: "Profile",
                          selected: _selectedIndex == 3 && _currentPage == null,
                          onTap: () {
                            Navigator.pop(context);
                            _onMenuClick(3);
                          },
                        ),
                      ],
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
