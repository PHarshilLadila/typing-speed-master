import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class GameCharacterRush extends StatefulWidget {
  const GameCharacterRush({super.key});

  @override
  State<GameCharacterRush> createState() => _GameCharacterRushState();
}

class _GameCharacterRushState extends State<GameCharacterRush> {
  EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) {
      return EdgeInsets.symmetric(
        vertical: 50,
        horizontal: MediaQuery.of(context).size.width / 5,
      );
    } else if (width > 768) {
      return const EdgeInsets.all(40.0);
    } else {
      return const EdgeInsets.symmetric(vertical: 40.0, horizontal: 30);
    }
  }

  Widget gameDashboardHeader(
    BuildContext context,
    double titleFontSize,
    double subtitleFontSize,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Character Rush',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Collect the charcter fast",
                style: TextStyle(
                  fontSize: 16,
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
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.filter_list,
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: getResponsivePadding(context),
          child: Column(
            children: [
              gameDashboardHeader(context, 24, 18),
              const SizedBox(height: 40),
              Container(
                height: isMobile ? 180 : 340,
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.black12 : Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isDarkTheme
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
