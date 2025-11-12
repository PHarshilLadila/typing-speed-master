// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class TextDisplayWidget extends StatefulWidget {
  final String sampleText;
  final String userInput;
  final bool isTestActive;
  final bool isDarkMode;

  const TextDisplayWidget({
    super.key,
    required this.sampleText,
    required this.userInput,
    required this.isTestActive,
    required this.isDarkMode,
  });

  @override
  State<TextDisplayWidget> createState() => _TextDisplayWidgetState();
}

class _TextDisplayWidgetState extends State<TextDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _cursorAnimation;
  late Animation<Color?> _colorAnimation;

  String _previousUserInput = '';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cursorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue.withOpacity(0.3),
      end: Colors.blue.withOpacity(0.7),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(TextDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.userInput != _previousUserInput) {
      _handleInputChange(oldWidget.userInput, widget.userInput);
      _previousUserInput = widget.userInput;
    }
  }

  void _handleInputChange(String oldInput, String newInput) {
    if (newInput.length > oldInput.length) {
      _triggerCharacterAnimation();
    } else if (newInput.length < oldInput.length) {}
  }

  void _triggerCharacterAnimation() {
    _animationController
      ..stop()
      ..forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final containerColor =
        widget.isDarkMode
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.04);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildAnimatedText(),
    );
  }

  Widget _buildAnimatedText() {
    return Text.rich(
      TextSpan(children: _buildAnimatedTextSpans()),
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.5,
        fontFamily: 'Monospace',
      ),
    );
  }

  List<TextSpan> _buildAnimatedTextSpans() {
    final List<TextSpan> spans = [];
    final defaultTextColor =
        widget.isDarkMode ? Colors.grey[300] : Colors.grey[800];

    for (int i = 0; i < widget.sampleText.length; i++) {
      final char = widget.sampleText[i];
      final textSpan = _buildAnimatedTextSpanForChar(
        i,
        char,
        defaultTextColor!,
      );
      spans.add(textSpan);
    }

    return spans;
  }

  TextSpan _buildAnimatedTextSpanForChar(
    int index,
    String char,
    Color defaultTextColor,
  ) {
    Color color = defaultTextColor;
    Color backgroundColor = Colors.transparent;
    FontWeight fontWeight = FontWeight.w400;
    double fontSize = 24.0;

    if (index < widget.userInput.length) {
      if (widget.userInput[index] == char) {
        color = _getAnimatedColor(Colors.green, Colors.green[700]!);
        backgroundColor = _getBackgroundColor(Colors.green);
        fontWeight = FontWeight.w500;
      } else {
        color = _getAnimatedColor(Colors.red, Colors.red[700]!);
        backgroundColor = _getBackgroundColor(Colors.red);
        fontWeight = FontWeight.w500;
      }
    } else if (index == widget.userInput.length && widget.isTestActive) {
      return TextSpan(
        text: char,
        style: TextStyle(
          color: widget.isDarkMode ? Colors.blue[100] : Colors.blue[800],
          backgroundColor: _colorAnimation.value,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
          wordSpacing: 4,
        ),
      );
    } else if (index == widget.userInput.length - 1 &&
        widget.userInput.isNotEmpty &&
        widget.isTestActive) {
      color = _getLastCharacterColor();
      backgroundColor = _getLastCharacterBackgroundColor();
      fontWeight = FontWeight.w600;
      fontSize = 25.0;
    }

    return TextSpan(
      text: char,
      style: TextStyle(
        color: color,
        backgroundColor: backgroundColor,
        fontWeight: fontWeight,
        fontSize: fontSize,
        wordSpacing: 4,
      ),
    );
  }

  Color _getAnimatedColor(Color baseColor, Color darkColor) {
    if (!widget.isTestActive) return baseColor;

    final animationValue = _cursorAnimation.value;
    return Color.lerp(baseColor, darkColor, animationValue * 0.3)!;
  }

  Color _getBackgroundColor(Color baseColor) {
    if (!widget.isTestActive) return Colors.transparent;

    final animationValue = _cursorAnimation.value;
    return baseColor.withOpacity(
      widget.isDarkMode
          ? 0.1 + (animationValue * 0.1)
          : 0.05 + (animationValue * 0.05),
    );
  }

  Color _getLastCharacterColor() {
    final animationValue = _cursorAnimation.value;
    if (widget.userInput.isNotEmpty &&
        widget.userInput[widget.userInput.length - 1] ==
            widget.sampleText[widget.userInput.length - 1]) {
      return Color.lerp(
        Colors.green,
        Colors.green[800]!,
        animationValue * 0.4,
      )!;
    } else {
      return Color.lerp(Colors.red, Colors.red[800]!, animationValue * 0.4)!;
    }
  }

  Color _getLastCharacterBackgroundColor() {
    final animationValue = _cursorAnimation.value;
    if (widget.userInput.isNotEmpty &&
        widget.userInput[widget.userInput.length - 1] ==
            widget.sampleText[widget.userInput.length - 1]) {
      return Colors.green.withOpacity(
        widget.isDarkMode
            ? 0.15 + (animationValue * 0.1)
            : 0.08 + (animationValue * 0.05),
      );
    } else {
      return Colors.red.withOpacity(
        widget.isDarkMode
            ? 0.15 + (animationValue * 0.1)
            : 0.08 + (animationValue * 0.05),
      );
    }
  }
}
