// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/utils/constants.dart';
import '../providers/typing_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/text_display_widget.dart';
import '../models/typing_result.dart';
import 'results_screen.dart';

class TypingTestScreen extends StatefulWidget {
  const TypingTestScreen({super.key});

  @override
  _TypingTestScreenState createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends State<TypingTestScreen> {
  final TextEditingController _textController = TextEditingController();
  String _userInput = '';
  DateTime? _startTime;
  bool _testStarted = false;
  bool _testCompleted = false;
  Duration _remainingTime = Duration.zero;
  late Duration _testDuration;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TypingProvider>(context, listen: false);
    _testDuration = provider.selectedDuration;
    _remainingTime = _testDuration;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
      _startTime = DateTime.now();
      _userInput = '';
      _textController.clear();
      _remainingTime = _testDuration;
    });

    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_testStarted && !_testCompleted && mounted) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });

        if (_remainingTime.inSeconds <= 0) {
          _completeTest();
        } else {
          _startTimer();
        }
      }
    });
  }

  void _completeTest() {
    if (_startTime == null) return;

    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    final words = _userInput.split(' ').where((word) => word.isNotEmpty).length;

    final wpm = (words / (duration.inSeconds / 60)).round();

    int correctChars = 0;
    final sampleText =
        Provider.of<TypingProvider>(context, listen: false).getCurrentText();

    for (int i = 0; i < _userInput.length && i < sampleText.length; i++) {
      if (_userInput[i] == sampleText[i]) correctChars++;
    }

    final accuracy = (correctChars / sampleText.length) * 100;

    final result = TypingResult(
      wpm: wpm,
      accuracy: accuracy,
      correctChars: correctChars,
      incorrectChars: _userInput.length - correctChars,
      totalChars: _userInput.length,
      duration: duration,
      timestamp: DateTime.now(),
      difficulty:
          Provider.of<TypingProvider>(
            context,
            listen: false,
          ).selectedDifficulty,
    );

    setState(() {
      _testCompleted = true;
      _testStarted = false;
    });

    Provider.of<TypingProvider>(context, listen: false).saveResult(result);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResultsScreen(result: result)),
    );
  }

  void _onTextChanged(String value) {
    if (!_testStarted && value.isNotEmpty) {
      _startTest();
    }

    setState(() {
      _userInput = value;
    });

    final sampleText =
        Provider.of<TypingProvider>(context, listen: false).getCurrentText();
    if (value.length >= sampleText.length) {
      _completeTest();
    }
  }

  void _resetTest() {
    setState(() {
      _testStarted = false;
      _testCompleted = false;
      _userInput = '';
      _textController.clear();
      _remainingTime = _testDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final sampleText = provider.getCurrentText();

    final backgroundColor =
        themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[50];
    final cardColor =
        themeProvider.isDarkMode ? Colors.grey[800] : Colors.white;
    final borderColor =
        themeProvider.isDarkMode ? Colors.grey[500]! : Colors.grey[500]!;
    // final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final inputBorderColor =
        themeProvider.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;
    final titleColor = themeProvider.isDarkMode ? Colors.white : Colors.black;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
        child: Column(
          children: [
            _buildHeader(context, 24, 18, false),
            const SizedBox(height: 40),

            _buildTimerAndStats(
              themeProvider,
              cardColor ?? Colors.grey,
              subtitleColor ?? Colors.grey,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type the text below:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextDisplayWidget(
                    sampleText: sampleText,
                    userInput: _userInput,
                    isTestActive: _testStarted && !_testCompleted,
                    isDarkMode: themeProvider.isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textController,
                    enabled: !_testCompleted,
                    maxLines: 8,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                      ),
                      hintText: 'Type the text shown above...',

                      hintStyle: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[600],
                      ),
                      fillColor: Colors.white,
                      filled: false,
                    ),
                    onChanged: _onTextChanged,
                    autofocus: true,
                    style: TextStyle(
                      color:
                          themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildInputField(
              themeProvider,
              cardColor ?? Colors.grey,
              inputBorderColor,
              subtitleColor ?? Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double titleFontSize,
    double subtitleFontSize,
    bool isMobile,
  ) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final titleColor =
        themeProvider.isDarkMode ? Colors.white : Colors.grey[800];
    final subtitleColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Typing Speed Test',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Improve your typing speed and accuracy',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color:
                    themeProvider.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 40,
              width: isMobile ? 150 : 200,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: DropdownButton<String>(
                underline: const SizedBox(),
                value: provider.selectedDifficulty,
                onChanged:
                    _testStarted
                        ? null
                        : (value) {
                          if (value != null) {
                            provider.setDifficulty(value);
                            _resetTest();
                          }
                        },
                items:
                    AppConstants.difficultyLevels.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(
                          level,
                          style: TextStyle(
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                isExpanded: true,
                dropdownColor:
                    themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color:
                    themeProvider.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 40,
              width: isMobile ? 150 : 200,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: DropdownButton<Duration>(
                value: provider.selectedDuration,
                onChanged:
                    _testStarted
                        ? null
                        : (value) {
                          if (value != null) {
                            provider.setDuration(value);
                            _testDuration = value;
                            _remainingTime = value;
                            _resetTest();
                          }
                        },
                items:
                    AppConstants.testDurations.map((duration) {
                      return DropdownMenuItem(
                        value: duration,
                        child: Text(
                          '${duration.inSeconds} seconds',
                          style: TextStyle(
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor:
                    themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerAndStats(
    ThemeProvider themeProvider,
    Color cardColor,
    Color subtitleColor,
  ) {
    final provider = Provider.of<TypingProvider>(context, listen: false);
    final currentDifficulty = provider.selectedDifficulty;

    final words = _userInput.split(' ').where((word) => word.isNotEmpty).length;

    double wpm = 0;
    if (_startTime != null && _testStarted) {
      final elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
      if (elapsedSeconds > 0) {
        wpm = (words / (elapsedSeconds / 60));
      }
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration: BoxDecoration(
              color:
                  _remainingTime.inSeconds <= 10
                      ? Colors.red.withOpacity(
                        themeProvider.isDarkMode ? 0.2 : 0.1,
                      )
                      : Colors.blue.withOpacity(
                        themeProvider.isDarkMode ? 0.2 : 0.1,
                      ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _remainingTime.inSeconds <= 10
                        ? Colors.red.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Time Remaining',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_remainingTime.inSeconds}s',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        _remainingTime.inSeconds <= 10
                            ? Colors.red
                            : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(
                themeProvider.isDarkMode ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Current WPM',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),
                const SizedBox(height: 8),
                Text(
                  wpm.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(
                themeProvider.isDarkMode ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Words',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),
                const SizedBox(height: 8),
                Text(
                  '$words',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(
                themeProvider.isDarkMode ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Difficulty',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),
                const SizedBox(height: 8),
                Text(
                  currentDifficulty,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    ThemeProvider themeProvider,
    Color cardColor,
    Color borderColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_testStarted || _testCompleted)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        themeProvider.isDarkMode
                            ? Colors.grey[700]
                            : Colors.grey[200],
                    foregroundColor:
                        themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Restart Test'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _testStarted ? _completeTest : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Complete Test'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
