import 'package:flutter/material.dart';

class CharRushInstructionWidget extends StatelessWidget {
  final bool isDarkMode;
  const CharRushInstructionWidget({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Play:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Type the falling characters on your keyboard\n'
            '• Characters can be typed in uppercase or lowercase\n'
            '• Game speed increases every 15 seconds\n'
            '• Score more points for faster characters\n'
            '• Game automatically pauses when opening settings/score history\n'
            '• Click the timer to change game duration (before starting)',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
