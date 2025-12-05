import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TypingTestScreenTestUtils {
  static Future<void> startTypingTest(WidgetTester tester) async {
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'T');
    await tester.pump();
  }

  static Future<void> completeWordBasedTest(
    WidgetTester tester,
    int wordCount,
  ) async {
    final textField = find.byType(TextField);

    final testText = List.generate(
      wordCount,
      (index) => 'word${index + 1}',
    ).join(' ');

    await tester.enterText(textField, testText);
    await tester.pump();
  }

  static Future<void> simulateTyping(
    WidgetTester tester,
    String text, {
    int delayMs = 100,
  }) async {
    final textField = find.byType(TextField);

    for (int i = 0; i < text.length; i++) {
      await tester.enterText(textField, text.substring(0, i + 1));
      await tester.pump(Duration(milliseconds: delayMs));
    }
  }
}
