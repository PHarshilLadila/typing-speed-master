// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';

// class CharecterAnalysisWidget extends StatelessWidget {
//   final String originalText;
//   final String userInput;
//   final List<int> incorrectCharPositions;
//   final bool isDarkMode;

//   const CharecterAnalysisWidget({
//     super.key,
//     required this.originalText,
//     required this.userInput,
//     required this.incorrectCharPositions,
//     required this.isDarkMode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [_buildSideBySideComparison()],
//     );
//   }

//   Widget _buildSideBySideComparison() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(child: _buildTextColumn('Original Text', originalText, false)),
//         const SizedBox(width: 16),
//         Expanded(child: _buildTextColumn('Your Typed Text', userInput, true)),
//       ],
//     );
//   }

//   Widget _buildTextColumn(String title, String text, bool showErrors) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
//             fontSize: 14,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: isDarkMode ? Colors.black : Colors.white,
//             borderRadius: BorderRadius.circular(6),
//             border: Border.all(
//               color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
//             ),
//           ),
//           child:
//               showErrors
//                   ? _buildCharacterWiseHighlightedText()
//                   : _buildOriginalTextWithUnderline(),
//         ),
//       ],
//     );
//   }

//   Widget _buildOriginalTextWithUnderline() {
//     // Create a RichText that underlines only the portion that matches user input length
//     List<TextSpan> spans = [];

//     if (userInput.isNotEmpty) {
//       // Underlined portion (up to user input length)
//       String underlinedText =
//           originalText.length > userInput.length
//               ? originalText.substring(0, userInput.length)
//               : originalText;

//       spans.add(
//         TextSpan(
//           text: underlinedText,
//           style: TextStyle(
//             color: isDarkMode ? Colors.white : Colors.black,
//             fontSize: 16,
//             height: 1.5,
//             decoration: TextDecoration.underline,
//           ),
//         ),
//       );

//       // Remaining portion without underline (if any)
//       if (originalText.length > userInput.length) {
//         String remainingText = originalText.substring(userInput.length);
//         spans.add(
//           TextSpan(
//             text: remainingText,
//             style: TextStyle(
//               color: isDarkMode ? Colors.white : Colors.black,
//               fontSize: 16,
//               height: 1.5,
//               decoration: TextDecoration.none,
//             ),
//           ),
//         );
//       }
//     } else {
//       // No user input, show entire text without underline
//       spans.add(
//         TextSpan(
//           text: originalText,
//           style: TextStyle(
//             color: isDarkMode ? Colors.white : Colors.black,
//             fontSize: 16,
//             height: 1.5,
//             decoration: TextDecoration.none,
//           ),
//         ),
//       );
//     }

//     return RichText(text: TextSpan(children: spans));
//   }

//   Widget _buildCharacterWiseHighlightedText() {
//     List<InlineSpan> children = [];

//     for (int i = 0; i < userInput.length; i++) {
//       String currentChar = userInput[i];
//       bool isCharIncorrect = incorrectCharPositions.contains(i);
//       bool isSpace = currentChar == ' ';

//       children.add(
//         TextSpan(
//           text: currentChar,
//           style: TextStyle(
//             color: isCharIncorrect ? Colors.red : Colors.green,
//             backgroundColor:
//                 isSpace
//                     ? Colors.transparent
//                     : isCharIncorrect
//                     ? Colors.red.withOpacity(0.2)
//                     : Colors.green.withOpacity(0.2),
//             fontWeight: FontWeight.normal,
//             fontSize: 16,
//           ),
//         ),
//       );
//     }

//     return RichText(
//       text: TextSpan(
//         children: children,
//         style: TextStyle(
//           color: isDarkMode ? Colors.white : Colors.black,
//           height: 1.5,
//         ),
//       ),
//       textAlign: TextAlign.left,
//     );
//   }
// }

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
                  ? _buildCharacterWiseHighlightedText()
                  : _buildOriginalTextWithUnderlineAndErrors(),
        ),
      ],
    );
  }

  Widget _buildOriginalTextWithUnderlineAndErrors() {
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

  Widget _buildCharacterWiseHighlightedText() {
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
