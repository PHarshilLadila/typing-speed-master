import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/typing_test/provider/typing_test_provider.dart';
import 'package:typing_speed_master/features/typing_test/typing_test_screen.dart';
import 'package:typing_speed_master/features/typing_test/widget/text_display_widget.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_dropdown.dart';

class MockTypingProvider extends Mock implements TypingProvider {}

class MockThemeProvider extends Mock implements ThemeProvider {}

void main() {
  late MockTypingProvider mockTypingProvider;
  late MockThemeProvider mockThemeProvider;

  setUp(() {
    mockTypingProvider = MockTypingProvider();
    mockThemeProvider = MockThemeProvider();

    when(mockThemeProvider.isDarkMode).thenReturn(true);
    when(mockThemeProvider.primaryColor).thenReturn(Colors.blue);
    when(
      mockTypingProvider.selectedDuration,
    ).thenReturn(const Duration(seconds: 60));
    when(mockTypingProvider.selectedDifficulty).thenReturn('Easy');
    when(
      mockTypingProvider.getCurrentText(),
    ).thenReturn('This is a sample text for typing test.');
    when(
      mockTypingProvider.currentOriginalText,
    ).thenReturn('This is a sample text for typing test.');
  });

  group('TypingTestScreen Widget Tests', () {
    testWidgets('Should render initial screen with all components', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TypingProvider>.value(
              value: mockTypingProvider,
            ),
            ChangeNotifierProvider<ThemeProvider>.value(
              value: mockThemeProvider,
            ),
          ],
          child: MaterialApp(home: TypingTestScreen()),
        ),
      );

      expect(find.text('Typing Speed Test'), findsOneWidget);
      expect(
        find.text('Improve your typing speed and accuracy'),
        findsOneWidget,
      );
      expect(find.byType(TextDisplayWidget), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('Should start test when user starts typing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TypingProvider>.value(
              value: mockTypingProvider,
            ),
            ChangeNotifierProvider<ThemeProvider>.value(
              value: mockThemeProvider,
            ),
          ],
          child: MaterialApp(home: TypingTestScreen()),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'T');
      await tester.pump();

      expect(find.text('Time Remaining'), findsOneWidget);
      expect(find.text('60s'), findsOneWidget);
    });

    testWidgets('Should reset test when Reset button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TypingProvider>.value(
              value: mockTypingProvider,
            ),
            ChangeNotifierProvider<ThemeProvider>.value(
              value: mockThemeProvider,
            ),
          ],
          child: MaterialApp(home: TypingTestScreen()),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test');
      await tester.pump();

      final resetButton = find.text('Reset');
      await tester.tap(resetButton);
      await tester.pump();

      expect(find.text('Test'), findsNothing);
    });

    testWidgets('Should show word count for word-based test', (
      WidgetTester tester,
    ) async {
      when(mockTypingProvider.selectedDuration).thenReturn(Duration.zero);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TypingProvider>.value(
              value: mockTypingProvider,
            ),
            ChangeNotifierProvider<ThemeProvider>.value(
              value: mockThemeProvider,
            ),
          ],
          child: MaterialApp(home: TypingTestScreen()),
        ),
      );

      expect(find.text('Words: 0/50'), findsOneWidget);
    });

    testWidgets('Should change difficulty when dropdown is used', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TypingProvider>.value(
              value: mockTypingProvider,
            ),
            ChangeNotifierProvider<ThemeProvider>.value(
              value: mockThemeProvider,
            ),
          ],
          child: MaterialApp(home: TypingTestScreen()),
        ),
      );

      final dropdownFinder = find.byType(CustomDropdown<String>).first;
      expect(dropdownFinder, findsOneWidget);

      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
    });
  });
}
