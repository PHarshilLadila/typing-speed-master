// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/history/widget/typing_result_card_shimmer_widget.dart';
import 'package:typing_speed_master/models/typing_test_result_model.dart';
import 'package:typing_speed_master/features/profile/provider/user_activity_provider.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/features/typing_test/provider/typing_test_provider.dart';
import 'package:typing_speed_master/widgets/custom_dialogs.dart';
import 'package:typing_speed_master/widgets/custom_history_not_found_widget.dart';
import 'package:typing_speed_master/widgets/custom_typing_result_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  String selectedSortOption = 'new_to_old';
  String selectedFilterDifficulty = 'all';
  String selectedFilterDuration = 'all';
  Timer? filterDebounceTimer;

  final Map<String, String> sortOptions = {
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
    '180': '180 Seconds',
    '300': '300 Seconds',
    'word_based': 'Word Based',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TypingProvider>(context, listen: false);
      provider.getAllRecentResults();
    });
  }

  void onFilterChanged() {
    filterDebounceTimer?.cancel();
    filterDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  List<TypingTestResultModel> getFilteredAndSortedResults(
    List<TypingTestResultModel> results,
  ) {
    List<TypingTestResultModel> filteredResults =
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

    return filteredResults;
  }

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
      return height / 5;
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
          onFilterChanged();
        },
        items:
            sortOptions.entries.map((entry) {
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
          onFilterChanged();
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          onFilterChanged();
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

  Future<void> deleteHistoryEntry(TypingTestResultModel result) async {
    try {
      final provider = Provider.of<TypingProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final activityProvider = Provider.of<UserActivityProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await provider.deleteHistoryEntry(result);

      if (authProvider.user != null) {
        final currentYear = DateTime.now().year;

        activityProvider.clearData();
        await activityProvider.fetchActivityData(
          authProvider.user!.id,
          currentYear,
        );

        await authProvider.fetchUserProfile(authProvider.user!.id);
      }

      if (mounted) {
        setState(() {});
      }

      final isDarkMode = themeProvider.isDarkMode;
      Fluttertoast.showToast(
        msg: "History deleted successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        textColor: isDarkMode ? Colors.white : Colors.black,
        fontSize: 14.0,
        webPosition: "center",
        webBgColor:
            isDarkMode
                ? "linear-gradient(to right, #000000, #000000)"
                : "linear-gradient(to right, #FFFFFF, #FFFFFF)",
      );
    } catch (e) {
      log('Error deleting history: $e');
      Fluttertoast.showToast(
        msg: "Failed to delete history",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<TypingProvider>(
      builder: (context, provider, _) {
        final allResults = provider.results;
        final filteredResults = getFilteredAndSortedResults(allResults);

        // final cardColor =
        //     themeProvider.isDarkMode ? Colors.grey[800] : Colors.white;
        // final borderColor =
        //     themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200];
        // final textColor =
        //     themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[500];
        // final iconColor =
        //     themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[400];
        final responsivePadding = getResponsivePadding(context);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: responsivePadding.copyWith(bottom: 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  historyHeader(context, 24, 18),
                  const SizedBox(height: 30),
                  historyFilterAndSortOptions(context),
                  const SizedBox(height: 30),
                  if (filteredResults.isNotEmpty || provider.results.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${filteredResults.length} result${filteredResults.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                            ),
                          ),
                          TextButton(
                            onPressed: provider.clearHistory,
                            child: Text(
                              'Clear All',
                              style: TextStyle(
                                color:
                                    themeProvider.isDarkMode
                                        ? Colors.red[300]
                                        : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ]),
              ),
            ),
            if (provider.isLoading)
              // CircularProgressIndicator(color: themeProvider.primaryColor),
              SliverPadding(
                padding: responsivePadding.copyWith(top: 0, bottom: 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return TypingHistoryShimmerCard(
                      cardHeight: 140,
                      progressSize: 70,
                      subtitleFontSize: 14,
                    );
                  }, childCount: 5),
                ),
              ),
            if (!provider.isLoading && filteredResults.isEmpty)
              SliverPadding(
                padding: responsivePadding.copyWith(top: 0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[900]
                              : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.grey[500]!
                                : Colors.grey[500]!,
                        width: 0.3,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: getEmptyStateTopPadding(context),
                          bottom: getEmptyStateTopPadding(context),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomHistoryNotFoundWidget(
                              title:
                                  allResults.isEmpty
                                      ? 'No tests completed yet'
                                      : 'No results match your filters',
                            ),

                            // Icon(
                            //   Icons.assignment,
                            //   size: getResponsiveIconSize(context),
                            //   color: iconColor,
                            // ),
                            // const SizedBox(height: 12),
                            // Text(
                            //   allResults.isEmpty
                            //       ? 'No tests completed yet'
                            //       : 'No results match your filters',
                            //   style: TextStyle(
                            //     fontSize: getResponsiveSubtitleFontSize(
                            //       context,
                            //     ),
                            //     fontWeight: FontWeight.w600,
                            //     color: textColor,
                            //   ),
                            // ),
                            const SizedBox(height: 6),
                            Text(
                              allResults.isEmpty
                                  ? 'Start your first typing test to see history here'
                                  : 'Try changing your filter or sort options',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else if (!provider.isLoading)
              SliverPadding(
                padding: responsivePadding.copyWith(top: 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final result = filteredResults[index];
                    return CustomTypingResultCard(
                      result: result,
                      subtitleFontSize: getResponsiveSubtitleFontSize(context),
                      isDarkMode: themeProvider.isDarkMode,
                      isHistory: true,
                      onViewDetails: () {
                        context.push('/results?from=history', extra: result);
                      },
                      indexOfNumbers: '${index + 1}',
                      onTap: () async {
                        CustomDialog.showSignOutDialog(
                          title: "Delete This History?",
                          content:
                              "Are you sure you want to delete this history?",
                          confirmText: "Delete",
                          context: context,
                          onConfirm: () async {
                            await deleteHistoryEntry(result);
                          },
                        );
                      },
                    );
                  }, childCount: filteredResults.length),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    filterDebounceTimer?.cancel();
    super.dispose();
  }
}
