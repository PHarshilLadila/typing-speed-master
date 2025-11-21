// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/models/typing_result.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/providers/typing_provider.dart';
import 'package:typing_speed_master/screens/main_entry_point_.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';
import 'package:typing_speed_master/widgets/typing_result_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  String selectedSortOption = 'new_to_old';
  String selectedFilterDifficulty = 'all';
  String selectedFilterDuration = 'all';
  Timer? _filterDebounceTimer;

  List<TypingResult> _cachedFilteredResults = [];
  String _lastFilterKey = '';

  final Map<String, String> _sortOptions = {
    'new_to_old': 'Newest First',
    'old_to_new': 'Oldest First',
    'high_to_low_wpm': 'High to Low WPM',
    'low_to_high_wpm': 'Low to High WPM',
    'high_to_low_accuracy': 'High to Low Accuracy',
    'low_to_high_accuracy': 'Low to High Accuracy',
    'easy_to_hard': 'Easy to Hard',
    'hard_to_easy': 'Hard to Easy',
    'long_to_short_duration': 'Long to Short Duration',
    'short_to_long_duration': 'Short to Long Duration',
  };

  final Map<String, String> difficultyOptions = {
    'all': 'All Difficulties',
    'Easy': 'Easy',
    'Medium': 'Medium',
    'Hard': 'Hard',
  };

  final Map<String, String> durationOptions = {
    'all': 'All Durations',
    '30': '30 Seconds',
    '60': '60 Seconds',
    '120': '120 Seconds',
    'word_based': 'Word Based',
  };

  @override
  void initState() {
    super.initState();
    // Load once when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TypingProvider>(context, listen: false);
      provider.getAllRecentResults();
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final provider = Provider.of<TypingProvider>(context, listen: false);
  //   provider.getAllRecentResults();
  // }

  void _onFilterChanged() {
    _filterDebounceTimer?.cancel();
    _filterDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Clear cache to force recalculation
      _cachedFilteredResults = [];
      _lastFilterKey = '';
      if (mounted) {
        setState(() {});
      }
    });
  }

  List<TypingResult> getFilteredAndSortedResults(List<TypingResult> results) {
    final cacheKey =
        '$selectedSortOption-$selectedFilterDifficulty-$selectedFilterDuration';

    if (_lastFilterKey == cacheKey && _cachedFilteredResults.isNotEmpty) {
      return _cachedFilteredResults;
    }

    // First apply filters
    List<TypingResult> filteredResults =
        results.where((result) {
          if (selectedFilterDifficulty != 'all' &&
              result.difficulty != selectedFilterDifficulty) {
            return false;
          }

          if (selectedFilterDuration != 'all') {
            if (selectedFilterDuration == 'word_based' &&
                !result.isWordBasedTest) {
              return false;
            } else if (selectedFilterDuration != 'word_based') {
              final durationSeconds = result.duration.inSeconds;
              final selectedDuration = int.tryParse(selectedFilterDuration);
              if (selectedDuration != null &&
                  durationSeconds != selectedDuration) {
                return false;
              }
            }
          }
          return true;
        }).toList();

    switch (selectedSortOption) {
      case 'new_to_old':
        filteredResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'old_to_new':
        filteredResults.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'high_to_low_wpm':
        filteredResults.sort((a, b) => b.wpm.compareTo(a.wpm));
        break;
      case 'low_to_high_wpm':
        filteredResults.sort((a, b) => a.wpm.compareTo(b.wpm));
        break;
      case 'high_to_low_accuracy':
        filteredResults.sort((a, b) => b.accuracy.compareTo(a.accuracy));
        break;
      case 'low_to_high_accuracy':
        filteredResults.sort((a, b) => a.accuracy.compareTo(b.accuracy));
        break;
      case 'easy_to_hard':
        final difficultyOrder = {'Easy': 1, 'Medium': 2, 'Hard': 3};
        filteredResults.sort(
          (a, b) => difficultyOrder[a.difficulty]!.compareTo(
            difficultyOrder[b.difficulty]!,
          ),
        );
        break;
      case 'hard_to_easy':
        final difficultyOrder = {'Easy': 1, 'Medium': 2, 'Hard': 3};
        filteredResults.sort(
          (a, b) => difficultyOrder[b.difficulty]!.compareTo(
            difficultyOrder[a.difficulty]!,
          ),
        );
        break;
      case 'long_to_short_duration':
        filteredResults.sort(
          (a, b) => b.duration.inSeconds.compareTo(a.duration.inSeconds),
        );
        break;
      case 'short_to_long_duration':
        filteredResults.sort(
          (a, b) => a.duration.inSeconds.compareTo(b.duration.inSeconds),
        );
        break;
    }

    _cachedFilteredResults = filteredResults;
    _lastFilterKey = cacheKey;

    return filteredResults;
  }

  EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) {
      return EdgeInsets.all(40);
    } else if (width > 768) {
      return const EdgeInsets.all(40.0);
    } else {
      return const EdgeInsets.symmetric(vertical: 40.0, horizontal: 30);
    }
  }

  double getResponsiveSubtitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) {
      return 18.0;
    } else if (width > 768) {
      return 17.0;
    } else {
      return 16.0;
    }
  }

  EdgeInsets getCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 768) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  double getResponsiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 768) {
      return 64.0;
    } else {
      return 48.0;
    }
  }

  double getEmptyStateTopPadding(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    if (height > 800) {
      return height / 4;
    } else {
      return height / 6;
    }
  }

  double getEmptyStateWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 768) {
      return 400;
    } else if (width > 480) {
      return 350;
    } else {
      return 300;
    }
  }

  Widget historyFilterAndSortOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Column(
        children: [
          historySortDropdown(context, isDarkMode),
          const SizedBox(height: 12),
          historyFilterRow(context, isDarkMode),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: historyFilterRow(context, isDarkMode)),
          const SizedBox(width: 16),
          historySortDropdown(context, isDarkMode),
        ],
      );
    }
  }

  Widget historySortDropdown(BuildContext context, bool isDarkMode) {
    return Container(
      width: MediaQuery.of(context).size.width < 768 ? double.infinity : 200,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButton<String>(
        value: selectedSortOption,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 14,
        ),
        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
        onChanged: (String? newValue) {
          setState(() {
            selectedSortOption = newValue!;
          });
          _onFilterChanged();
        },
        items:
            _sortOptions.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget historyFilterRow(BuildContext context, bool isDarkMode) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Column(
        children: [
          historyDifficultyFilter(context, isDarkMode),
          const SizedBox(height: 12),
          historyDurationFilter(context, isDarkMode),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: historyDifficultyFilter(context, isDarkMode)),
          const SizedBox(width: 12),
          Expanded(child: historyDurationFilter(context, isDarkMode)),
        ],
      );
    }
  }

  Widget historyDifficultyFilter(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButton<String>(
        value: selectedFilterDifficulty,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 14,
        ),
        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
        onChanged: (String? newValue) {
          setState(() {
            selectedFilterDifficulty = newValue!;
          });
        },
        items:
            difficultyOptions.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget historyDurationFilter(BuildContext context, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButton<String>(
        value: selectedFilterDuration,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 14,
        ),
        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
        onChanged: (String? newValue) {
          setState(() {
            selectedFilterDuration = newValue!;
          });
        },
        items:
            durationOptions.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget historyListResults(BuildContext context, double subtitleFontSize) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<TypingProvider>(
      builder: (context, provider, _) {
        final allResults = provider.results;
        final filteredResults = getFilteredAndSortedResults(allResults);

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
            historyFilterAndSortOptions(context),
            const SizedBox(height: 20),

            if (filteredResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Showing ${filteredResults.length} result${filteredResults.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        themeProvider.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                  ),
                ),
              ),

            if (filteredResults.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: getEmptyStateTopPadding(context),
                  ),
                  child: Container(
                    width: getEmptyStateWidth(context),
                    padding: getCardPadding(context),
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
                          size: getResponsiveIconSize(context),
                          color: iconColor,
                        ),
                        SizedBox(height: 12),
                        Text(
                          allResults.isEmpty
                              ? 'No tests completed yet'
                              : 'No results match your filters',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          allResults.isEmpty
                              ? 'Start your first typing test to see results here'
                              : 'Try changing your filter or sort options',
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
                    filteredResults
                        .map(
                          (result) => TypingResultCard(
                            result: result,
                            subtitleFontSize: getResponsiveSubtitleFontSize(
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
                                '${filteredResults.indexOf(result) + 1}',
                            onTap: () async {
                              CustomDialog.showSignOutDialog(
                                title: "Delete This History?",
                                content:
                                    "Are you sure you want to delete this history?",
                                confirmText: "Delete",
                                context: context,
                                onConfirm: () async {
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
                                        'History Deleted successfully..!',
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

  Widget historyHeader(
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
                "Here Your Fingers' History Lives!",
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
        padding: getResponsivePadding(context),
        child: Column(
          children: [
            historyHeader(context, 24, 18),
            const SizedBox(height: 30),
            historyListResults(context, getResponsiveSubtitleFontSize(context)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _filterDebounceTimer?.cancel();
    super.dispose();
  }
}
