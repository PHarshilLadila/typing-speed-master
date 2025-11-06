// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:typing_speed_master/helper/animation_helper/animated_difficulty_container.dart';
import 'package:typing_speed_master/helper/animation_helper/animated_progress_indicator.dart';
import 'package:typing_speed_master/models/typing_result.dart';

class TypingResultCard extends StatelessWidget {
  final TypingResult result;
  final double subtitleFontSize;
  final bool isDarkMode;
  final VoidCallback? onViewDetails;
  final bool isHistory;
  final String? indexOfNumbers;

  const TypingResultCard({
    super.key,
    required this.result,
    this.subtitleFontSize = 16,
    this.isDarkMode = false,
    this.onViewDetails,
    this.isHistory = true,
    this.indexOfNumbers,
  });

  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'hard':
        return const Color(0xFFFF6B6B);
      case 'medium':
        return const Color(0xFFFFA726);
      case 'easy':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFF42A5F5);
    }
  }

  Color getDifficultyGradientColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'hard':
        return const Color(0xFFFF5252);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'easy':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF2196F3);
    }
  }

  IconData getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'hard':
        return Icons.whatshot;
      case 'medium':
        return Icons.trending_up;
      case 'easy':
        return Icons.flag;
      default:
        return Icons.star;
    }
  }

  double _getProgressSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 380) {
      return 40.0;
    } else if (width < 768) {
      return 70.0;
    } else {
      return 80.0;
    }
  }

  double _getCardHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 380) {
      return isHistory ? 140 : 110;
    } else if (width < 768) {
      return isHistory ? 125 : 100;
    } else {
      return isHistory ? 135 : 110;
    }
  }

  EdgeInsets _getCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 380) {
      return const EdgeInsets.symmetric(horizontal: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20);
    }
  }

  double _getElementSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 380) {
      return 0.0;
    } else if (width < 768) {
      return 16;
    } else {
      return 20.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = getDifficultyColor(result.difficulty);
    final difficultyGradientColor = getDifficultyGradientColor(
      result.difficulty,
    );
    final difficultyIcon = getDifficultyIcon(result.difficulty);

    final backgroundColor1 = isDarkMode ? Colors.grey[800]! : Colors.white;
    final backgroundColor2 = isDarkMode ? Colors.grey[900]! : Colors.grey[50]!;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final progressBackgroundColor =
        isDarkMode ? Colors.grey[700] : Colors.grey[200];
    final iconBackgroundColor =
        isDarkMode ? Colors.grey[600] : Colors.grey.withOpacity(0.1);
    final iconColor = isDarkMode ? Colors.grey[300] : Colors.grey;

    final progressSize = _getProgressSize(context);
    final cardHeight = _getCardHeight(context);
    final cardPadding = _getCardPadding(context);
    final elementSpacing = _getElementSpacing(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: cardHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor1.withOpacity(0.9),
                  backgroundColor2.withOpacity(0.9),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              isHistory
                  ? Positioned(
                    top: 1,
                    left: 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(17),
                          bottomLeft: Radius.circular(2),
                          bottomRight: Radius.circular(2),
                          topRight: Radius.circular(2),
                        ),
                      ),
                      child: Text(
                        "$indexOfNumbers",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  )
                  : SizedBox.shrink(),
              Container(
                height: cardHeight,
                width: double.infinity,
                padding: cardPadding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: progressSize,
                      height: progressSize,
                      child: AnimatedProgressIndicator(
                        value: result.wpm / 100,
                        subtitleFontSize: subtitleFontSize,
                        textColor: textColor,
                        subtitleTextColor: subtitleTextColor ?? Colors.pink,
                        progressBackgroundColor:
                            progressBackgroundColor ?? Colors.pink,
                        size: progressSize,
                      ),
                    ),
                    SizedBox(width: elementSpacing),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF66BB6A,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Icon(
                                    FontAwesomeIcons.circleDot,
                                    color: const Color(0xFF66BB6A),
                                    size: subtitleFontSize - 3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${result.accuracy.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Accuracy',
                                  style: TextStyle(
                                    fontSize: subtitleFontSize - 1,
                                    color: subtitleTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: iconBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.access_time,
                                    size: subtitleFontSize - 1,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  Text(
                                    '${result.duration.inSeconds - 1}s',
                                    style: TextStyle(
                                      fontSize: subtitleFontSize - 2,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Duration',
                                    style: TextStyle(
                                      fontSize: subtitleFontSize - 2,
                                      color: subtitleTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: isHistory ? 6 : 0),
                          isHistory
                              ? Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: iconBackgroundColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        FontAwesomeIcons.chartBar,
                                        size: subtitleFontSize - 1,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed:
                                        onViewDetails ??
                                        () => log("View Details"),
                                    style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        Colors.amber,
                                      ),
                                    ),
                                    child: Text(
                                      'View Details',
                                      style: TextStyle(
                                        fontSize: subtitleFontSize - 5,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedDifficultyContainer(
                      difficultyColor: difficultyColor,
                      difficultyGradientColor: difficultyGradientColor,
                      difficultyIcon: difficultyIcon,
                      difficulty: result.difficulty,
                      subtitleFontSize: subtitleFontSize,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                height: cardHeight,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: difficultyColor.withOpacity(0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
