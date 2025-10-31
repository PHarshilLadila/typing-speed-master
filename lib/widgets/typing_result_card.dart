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

  const TypingResultCard({
    super.key,
    required this.result,
    this.subtitleFontSize = 16,
    this.isDarkMode = false,
    this.onViewDetails,
    this.isHistory = true,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: isHistory ? 125 : 100,
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
          Container(
            height: isHistory ? 125 : 100,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimatedProgressIndicator(
                  value: result.wpm / 100,
                  subtitleFontSize: subtitleFontSize,
                  textColor: textColor,
                  subtitleTextColor: subtitleTextColor ?? Colors.pink,
                  progressBackgroundColor:
                      progressBackgroundColor ?? Colors.pink,
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF66BB6A).withOpacity(0.1),
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
                        Text(
                          'Accuracy',
                          style: TextStyle(
                            fontSize: subtitleFontSize - 1,
                            color: subtitleTextColor,
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
                                  onViewDetails ?? () => log("View Details"),
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
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        )
                        : SizedBox.shrink(),
                  ],
                ),
                const Spacer(),
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
          Positioned(
            right: 0,
            top: 0,
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                height: isHistory ? 125 : 100,
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
