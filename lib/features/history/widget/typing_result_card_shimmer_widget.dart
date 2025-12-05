import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class TypingHistoryShimmerCard extends StatelessWidget {
  final double cardHeight;
  final double progressSize;
  final double subtitleFontSize;

  const TypingHistoryShimmerCard({
    super.key,
    required this.cardHeight,
    required this.progressSize,
    required this.subtitleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Define shimmer colors based on theme
    final Color shimmerBaseColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

    final Color shimmerHighlightColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100;

    final Color containerColor =
        isDarkMode
            ? Colors.grey.shade800.withOpacity(0.8)
            : Colors.grey.shade200;

    final Color borderColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;

    return ShimmerWrapper(
      isLoading: true,
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background container with gradient
            Container(
              height: cardHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDarkMode
                          ? [
                            Colors.grey.shade900.withOpacity(0.4),
                            Colors.grey.shade800.withOpacity(0.4),
                          ]
                          : [
                            Colors.grey.withOpacity(0.3),
                            Colors.grey.withOpacity(0.3),
                          ],
                ),
              ),
            ),

            // Main content container
            Container(
              height: cardHeight,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Progress Circle Placeholder
                  Container(
                    width: progressSize,
                    height: progressSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: containerColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Middle Column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shimmerRow(isDarkMode: isDarkMode),
                        const SizedBox(height: 8),
                        shimmerRow(isDarkMode: isDarkMode),
                        const SizedBox(height: 8),
                        shimmerButton(isDarkMode: isDarkMode),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right Side
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      shimmerBox(width: 60, height: 25, isDarkMode: isDarkMode),
                      const SizedBox(height: 12),
                      shimmerBox(width: 60, height: 30, isDarkMode: isDarkMode),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget shimmerRow({required bool isDarkMode}) => Row(
    children: [
      shimmerBox(width: 25, height: 25, radius: 6, isDarkMode: isDarkMode),
      const SizedBox(width: 10),
      shimmerBox(width: 80, height: 14, isDarkMode: isDarkMode),
      const SizedBox(width: 10),
      shimmerBox(width: 60, height: 12, isDarkMode: isDarkMode),
    ],
  );

  Widget shimmerButton({required bool isDarkMode}) =>
      shimmerBox(width: 100, height: 30, radius: 6, isDarkMode: isDarkMode);

  Widget shimmerBox({
    required double width,
    required double height,
    double radius = 4,
    required bool isDarkMode,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class ShimmerWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Default colors if not provided
    final Color defaultBaseColor =
        baseColor ?? (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300);

    final Color defaultHighlightColor =
        highlightColor ??
        (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100);

    return Shimmer.fromColors(
      baseColor: defaultBaseColor,
      highlightColor: defaultHighlightColor,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}
