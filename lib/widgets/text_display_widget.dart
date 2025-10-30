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

class _TextDisplayWidgetState extends State<TextDisplayWidget> {
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
      child: _buildOptimizedText(),
    );
  }

  Widget _buildOptimizedText() {
    return SelectableText.rich(
      TextSpan(children: _buildTextSpans()),
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.5,
        fontFamily: 'Monospace',
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    final List<TextSpan> spans = [];
    final defaultTextColor =
        widget.isDarkMode ? Colors.grey[300] : Colors.grey[800];

    for (int i = 0; i < widget.sampleText.length; i++) {
      final char = widget.sampleText[i];
      final textSpan = _buildTextSpanForChar(i, char, defaultTextColor!);
      spans.add(textSpan);
    }

    return spans;
  }

  TextSpan _buildTextSpanForChar(
    int index,
    String char,
    Color defaultTextColor,
  ) {
    Color color = defaultTextColor;
    Color backgroundColor = Colors.transparent;

    if (index < widget.userInput.length) {
      if (widget.userInput[index] == char) {
        color = Colors.green;
        backgroundColor = Colors.green.withOpacity(
          widget.isDarkMode ? 0.2 : 0.1,
        );
      } else {
        color = Colors.red;
        backgroundColor = Colors.red.withOpacity(widget.isDarkMode ? 0.2 : 0.1);
      }
    } else if (index == widget.userInput.length && widget.isTestActive) {
      backgroundColor = Colors.blue.withOpacity(widget.isDarkMode ? 0.3 : 0.2);
      color = widget.isDarkMode ? Colors.blue[100]! : Colors.blue[800]!;
    }

    return TextSpan(
      text: char,
      style: TextStyle(
        color: color,
        backgroundColor: backgroundColor,
        fontWeight: FontWeight.w400,
        wordSpacing: 4,
      ),
    );
  }
}
