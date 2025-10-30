// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AnimatedDifficultyContainer extends StatefulWidget {
  final Color difficultyColor;
  final Color difficultyGradientColor;
  final IconData difficultyIcon;
  final String difficulty;
  final double subtitleFontSize;

  const AnimatedDifficultyContainer({
    super.key,
    required this.difficultyColor,
    required this.difficultyGradientColor,
    required this.difficultyIcon,
    required this.difficulty,
    required this.subtitleFontSize,
  });

  @override
  State<AnimatedDifficultyContainer> createState() =>
      _AnimatedDifficultyContainerState();
}

class _AnimatedDifficultyContainerState
    extends State<AnimatedDifficultyContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        transform:
            _isHovered
                ? Matrix4.translationValues(0, -12, 0)
                : Matrix4.identity(),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.difficultyColor, widget.difficultyGradientColor],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.difficultyColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.difficultyIcon,
                size: widget.subtitleFontSize + 2,
                color: Colors.white,
              ),
              const SizedBox(height: 6),
              Text(
                widget.difficulty,
                style: TextStyle(
                  fontSize: widget.subtitleFontSize - 5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
