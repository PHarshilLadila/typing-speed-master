// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class TextDisplayWidget extends StatelessWidget {
  final String sampleText;
  final String userInput;
  final bool isTestActive;

  const TextDisplayWidget({
    super.key,
    required this.sampleText,
    required this.userInput,
    required this.isTestActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type the text below:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _buildTextWithHighlighting(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWithHighlighting() {
    return Wrap(
      children: [
        for (int i = 0; i < sampleText.length; i++) ...[
          _buildCharacterWidget(i),
        ],
      ],
    );
  }

  Widget _buildCharacterWidget(int index) {
    Color color = Colors.grey[800]!;
    Color backgroundColor = Colors.transparent;
    String char = sampleText[index];

    if (index < userInput.length) {
      if (userInput[index] == sampleText[index]) {
        color = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
      } else {
        color = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.1);
      }
    } else if (index == userInput.length && isTestActive) {
      backgroundColor = Colors.blue.withOpacity(0.2);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        char,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: color,
        ),
      ),
    );
  }
}
