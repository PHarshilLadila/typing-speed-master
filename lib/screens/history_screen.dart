// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/providers/typing_provider.dart';
import 'package:typing_speed_master/screens/main_entry_point_.dart';
import 'package:typing_speed_master/widgets/typing_result_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<TypingProvider>(context, listen: false);
    provider.getAllRecentResults();
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) {
      return EdgeInsets.all(40);
    } else if (width > 768) {
      return const EdgeInsets.all(40.0);
    } else {
      return const EdgeInsets.symmetric(vertical: 40.0, horizontal: 30);
    }
  }

  double _getResponsiveSubtitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) {
      return 18.0;
    } else if (width > 768) {
      return 17.0;
    } else {
      return 16.0;
    }
  }

  EdgeInsets _getCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 768) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  double _getResponsiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 768) {
      return 64.0;
    } else {
      return 48.0;
    }
  }

  double _getEmptyStateTopPadding(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    if (height > 800) {
      return height / 4;
    } else {
      return height / 6;
    }
  }

  double _getEmptyStateWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 768) {
      return 400;
    } else if (width > 480) {
      return 350;
    } else {
      return 300;
    }
  }

  Widget _buildRecentResults(BuildContext context, double subtitleFontSize) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<TypingProvider>(
      builder: (context, provider, _) {
        final recentResults = provider.getAllRecentResults();

        final cardColor =
            themeProvider.isDarkMode ? Colors.grey[800] : Colors.white;
        final borderColor =
            themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200];
        final textColor =
            themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[500];
        final iconColor =
            themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[400];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            if (recentResults.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: _getEmptyStateTopPadding(context),
                  ),
                  child: Container(
                    width: _getEmptyStateWidth(context),
                    padding: _getCardPadding(context),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderColor ?? Colors.grey[200]!,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment,
                          size: _getResponsiveIconSize(context),
                          color: iconColor,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No tests completed yet',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Start your first typing test to see results here',
                          style: TextStyle(
                            fontSize: subtitleFontSize - 2,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children:
                    recentResults
                        .map(
                          (result) => TypingResultCard(
                            result: result,
                            subtitleFontSize: _getResponsiveSubtitleFontSize(
                              context,
                            ),
                            isDarkMode: themeProvider.isDarkMode,
                            isHistory: true,
                            onViewDetails: () {
                              log('View details for ${result.difficulty}');
                              final resultsProvider =
                                  TypingTestResultsProvider.of(context);
                              if (resultsProvider != null) {
                                resultsProvider.showResults(result);
                              }
                            },
                            indexOfNumbers:
                                '${recentResults.indexOf(result) + 1}',
                            onTap: () async {
                              await provider.deleteHistoryEntry(result);
                              final isDarkMode = themeProvider.isDarkMode;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor:
                                      isDarkMode
                                          ? Colors.grey[850]
                                          : Colors.white,
                                  content: Text(
                                    'Deleted history entry',
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double titleFontSize,
    double subtitleFontSize,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final titleColor =
        themeProvider.isDarkMode ? Colors.white : Colors.grey[800];
    final subtitleColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here Your Fingers’ History Lives!',
                style: TextStyle(
                  fontSize: 20,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: _getResponsivePadding(context),
        child: Column(
          children: [
            _buildHeader(context, 24, 18),
            const SizedBox(height: 30),
            _buildRecentResults(
              context,
              _getResponsiveSubtitleFontSize(context),
            ),
          ],
        ),
      ),
    );
  }
}
