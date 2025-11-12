// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CharecterAnalysisWidget extends StatelessWidget {
  final String originalText;
  final String userInput;
  final List<int> incorrectCharPositions;
  final bool isDarkMode;

  const CharecterAnalysisWidget({
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
      children: [_buildSideBySideComparison()],
    );
  }

  Widget _buildSideBySideComparison() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTextColumn('Original Text', originalText, false)),
        const SizedBox(width: 16),
        Expanded(child: _buildTextColumn('Your Typed Text', userInput, true)),
      ],
    );
  }

  Widget _buildTextColumn(String title, String text, bool showErrors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
            ),
          ),
          child:
              showErrors
                  ? _buildWordWiseHighlightedText()
                  : _buildOriginalTextWithUnderline(),
        ),
      ],
    );
  }

  Widget _buildOriginalTextWithUnderline() {
    // Create a RichText that underlines only the portion that matches user input length
    List<TextSpan> spans = [];

    if (userInput.isNotEmpty) {
      // Underlined portion (up to user input length)
      String underlinedText =
          originalText.length > userInput.length
              ? originalText.substring(0, userInput.length)
              : originalText;

      spans.add(
        TextSpan(
          text: underlinedText,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            height: 1.5,
            decoration: TextDecoration.underline,
          ),
        ),
      );

      // Remaining portion without underline (if any)
      if (originalText.length > userInput.length) {
        String remainingText = originalText.substring(userInput.length);
        spans.add(
          TextSpan(
            text: remainingText,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
              height: 1.5,
              decoration: TextDecoration.none,
            ),
          ),
        );
      }
    } else {
      // No user input, show entire text without underline
      spans.add(
        TextSpan(
          text: originalText,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            height: 1.5,
            decoration: TextDecoration.none,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildWordWiseHighlightedText() {
    List<String> originalWords = _splitIntoWords(originalText);
    List<String> userWords = _splitIntoWords(userInput);

    List<InlineSpan> children = [];

    for (int wordIndex = 0; wordIndex < userWords.length; wordIndex++) {
      String userWord = userWords[wordIndex];
      String originalWord =
          wordIndex < originalWords.length ? originalWords[wordIndex] : "";

      bool isWordIncorrect = _isWordIncorrect(
        userWord,
        originalWord,
        wordIndex,
        userWords,
      );

      children.add(
        TextSpan(
          text: userWord,
          style: TextStyle(
            color: isWordIncorrect ? Colors.red : Colors.green,
            backgroundColor:
                isWordIncorrect
                    ? Colors.red.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      );

      if (wordIndex < userWords.length - 1) {
        children.add(
          const TextSpan(
            text: ' ',
            style: TextStyle(backgroundColor: Colors.transparent),
          ),
        );
      }
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

  List<String> _splitIntoWords(String text) {
    List<String> words = [];
    String currentWord = '';

    for (int i = 0; i < text.length; i++) {
      if (text[i] == ' ') {
        if (currentWord.isNotEmpty) {
          words.add(currentWord);
          currentWord = '';
        }
      } else {
        currentWord += text[i];
      }
    }

    if (currentWord.isNotEmpty) {
      words.add(currentWord);
    }

    return words;
  }

  bool _isWordIncorrect(
    String userWord,
    String originalWord,
    int wordIndex,
    List<String> userWords,
  ) {
    if (originalWord.isEmpty) {
      return true;
    }

    if (userWord != originalWord) {
      return true;
    }

    int wordStartPosition = _getWordStartPosition(wordIndex, userWords);

    for (int i = 0; i < userWord.length; i++) {
      int charPosition = wordStartPosition + i;
      if (incorrectCharPositions.contains(charPosition)) {
        return true;
      }
    }

    return false;
  }

  int _getWordStartPosition(int wordIndex, List<String> userWords) {
    int position = 0;
    for (int i = 0; i < wordIndex; i++) {
      position += userWords[i].length;
      position += 1;
    }
    return position;
  }
}

class WordInfo {
  final String text;
  final bool isIncorrect;
  final bool isExtra;

  WordInfo({
    required this.text,
    required this.isIncorrect,
    required this.isExtra,
  });
}

class SimpleWordWiseErrorText extends StatelessWidget {
  final String originalText;
  final String userInput;
  final List<int> incorrectCharPositions;
  final bool isDarkMode;

  const SimpleWordWiseErrorText({
    super.key,
    required this.originalText,
    required this.userInput,
    required this.incorrectCharPositions,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    List<TextSpan> wordSpans = _createWordSpans();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Typed Text (Word-wise Errors Highlighted)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: RichText(
              text: TextSpan(
                children: wordSpans,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<TextSpan> _createWordSpans() {
    List<TextSpan> spans = [];
    List<String> userWords = userInput.split(' ');
    List<String> originalWords = originalText.split(' ');

    for (int i = 0; i < userWords.length; i++) {
      String userWord = userWords[i];
      String originalWord = i < originalWords.length ? originalWords[i] : "";

      bool isWordCorrect = _isWordCorrect(userWord, originalWord, i, userWords);

      spans.add(
        TextSpan(
          text: userWord,
          style: TextStyle(
            backgroundColor:
                isWordCorrect
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
            color: isWordCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

      if (i < userWords.length - 1) {
        spans.add(
          const TextSpan(
            text: ' ',
            style: TextStyle(backgroundColor: Colors.transparent),
          ),
        );
      }
    }

    return spans;
  }

  bool _isWordCorrect(
    String userWord,
    String originalWord,
    int wordIndex,
    List<String> userWords,
  ) {
    if (originalWord.isEmpty) return false;

    if (userWord != originalWord) return false;

    int wordStartPosition = _calculateWordPosition(wordIndex, userWords);
    for (int i = 0; i < userWord.length; i++) {
      if (incorrectCharPositions.contains(wordStartPosition + i)) {
        return false;
      }
    }

    return true;
  }

  int _calculateWordPosition(int wordIndex, List<String> words) {
    int position = 0;
    for (int i = 0; i < wordIndex; i++) {
      position += words[i].length + 1;
    }
    return position;
  }
}
