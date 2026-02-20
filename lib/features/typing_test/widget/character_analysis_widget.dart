// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CharacterAnalysisWidget extends StatelessWidget {
  final String originalText;
  final String userInput;
  final List<int> incorrectCharPositions;
  final bool isDarkMode;

  const CharacterAnalysisWidget({
    super.key,
    required this.originalText,
    required this.userInput,
    required this.incorrectCharPositions,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [characterAnalysisSideBySideComparison()],
    );
  }

  Widget characterAnalysisSideBySideComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        characterAnalysisTextColumn('Original Text', originalText, false),
        const SizedBox(height: 16),
        characterAnalysisTextColumn('Your Typed Text', userInput, true),
      ],
    );
  }

  Widget characterAnalysisTextColumn(
    String title,
    String text,
    bool showErrors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title :",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
            ),
          ),
          child:
              showErrors
                  ? characterAnalysisCharacterWiseHighlightedText()
                  : characterAnalysisOriginalTextWithUnderlineAndErrors(),
        ),
      ],
    );
  }

  Widget characterAnalysisOriginalTextWithUnderlineAndErrors() {
    List<TextSpan> spans = [];

    for (int i = 0; i < originalText.length; i++) {
      bool isCharIncorrect =
          i < userInput.length && incorrectCharPositions.contains(i);
      bool shouldUnderline = i < userInput.length;
      bool isSpace = originalText[i] == ' ';

      spans.add(
        TextSpan(
          text: originalText[i],
          style: TextStyle(
            color:
                isCharIncorrect
                    ? Colors.red
                    : (isDarkMode ? Colors.white : Colors.black),
            backgroundColor:
                isCharIncorrect && !isSpace
                    ? Colors.red.withOpacity(0.2)
                    : Colors.transparent,
            fontSize: 16,
            height: 1.5,
            decoration:
                shouldUnderline
                    ? TextDecoration.underline
                    : TextDecoration.none,
            decorationColor:
                isCharIncorrect
                    ? Colors.red
                    : (isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget characterAnalysisCharacterWiseHighlightedText() {
    List<InlineSpan> children = [];

    for (int i = 0; i < userInput.length; i++) {
      String currentChar = userInput[i];
      bool isCharIncorrect = incorrectCharPositions.contains(i);
      bool isSpace = currentChar == ' ';

      children.add(
        TextSpan(
          text: currentChar,
          style: TextStyle(
            color: isCharIncorrect ? Colors.red : Colors.green,
            backgroundColor:
                isSpace
                    ? Colors.transparent
                    : isCharIncorrect
                    ? Colors.red.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: children,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          height: 1.5,
        ),
      ),
      textAlign: TextAlign.left,
    );
  }
}
