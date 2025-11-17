// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:typing_speed_master/screens/main_entry_point_.dart';
import 'package:typing_speed_master/utils/constants.dart';
import 'package:typing_speed_master/widgets/custom_dropdown.dart';
import '../providers/typing_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/text_display_widget.dart';
import '../models/typing_result.dart';

class TypingTestScreen extends StatefulWidget {
  const TypingTestScreen({super.key});

  @override
  _TypingTestScreenState createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends State<TypingTestScreen> {
  final TextEditingController textController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();
  String userInput = '';
  DateTime? startTime;
  bool testStarted = false;
  bool testCompleted = false;
  Duration remainingTime = Duration.zero;
  late Duration testDuration;
  int wordsTyped = 0;
  bool get isWordBasedTest => testDuration.inSeconds == 0;

  int lastProcessedLength = 0;
  bool isProcessingInput = false;

  bool isFullScreen = false;

  Timer? typingSampleTimer;
  int lastSampleCharCount = 0;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TypingProvider>(context, listen: false);
    testDuration = provider.selectedDuration;
    remainingTime = testDuration;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        textFocusNode.requestFocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<TypingProvider>(context, listen: false);
    if (testDuration != provider.selectedDuration) {
      testDuration = provider.selectedDuration;
      remainingTime = testDuration;
    }
  }

  @override
  void dispose() {
    textController.dispose();
    textFocusNode.dispose();
    typingSampleTimer?.cancel();
    super.dispose();
  }

  void startTest() {
    if (!mounted) return;

    setState(() {
      testStarted = true;
      startTime = DateTime.now();
      wordsTyped = 0;
      lastProcessedLength = 0;
      remainingTime = testDuration;
    });

    final provider = Provider.of<TypingProvider>(context, listen: false);
    provider.resetConsistencyTracking();
    lastSampleCharCount = 0;

    startTypingSampleTimer();

    if (!isWordBasedTest) {
      startTimer();
    }
  }

  void startTypingSampleTimer() {
    typingSampleTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!testStarted || testCompleted || !mounted) {
        timer.cancel();
        return;
      }

      final provider = Provider.of<TypingProvider>(context, listen: false);
      final currentCharCount = userInput.length;

      if (currentCharCount > lastSampleCharCount) {
        provider.recordTypingSpeedSample(currentCharCount, DateTime.now());
        lastSampleCharCount = currentCharCount;
      }
    });
  }

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (testStarted && !testCompleted && mounted) {
        setState(() {
          remainingTime = remainingTime - const Duration(seconds: 1);
        });

        if (remainingTime.inSeconds <= 0) {
          completeTest();
        } else {
          startTimer();
        }
      }
    });
  }

  void completeTest() {
    if (startTime == null || !mounted) return;

    typingSampleTimer?.cancel();

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime!);
    final words = userInput.split(' ').where((word) => word.isNotEmpty).length;

    final wpm = (words / (duration.inSeconds / 60)).round();

    final provider = Provider.of<TypingProvider>(context, listen: false);
    final originalText = provider.currentOriginalText;

    final incorrectCharPositions = provider.calculateIncorrectCharPositions(
      userInput,
      originalText,
    );

    int correctChars = userInput.length - incorrectCharPositions.length;
    int incorrectChars = incorrectCharPositions.length;
    int totalChars = userInput.length;

    final accuracy = totalChars > 0 ? (correctChars / totalChars) * 100 : 0.0;
    final consistency = provider.calculateConsistency();

    final result = TypingResult(
      wpm: wpm,
      accuracy: accuracy,
      consistency: consistency,
      correctChars: correctChars,
      incorrectChars: incorrectChars,
      totalChars: totalChars,
      duration: duration,
      timestamp: DateTime.now(),
      difficulty: provider.selectedDifficulty,
      isWordBasedTest: isWordBasedTest,
      targetWords: isWordBasedTest ? AppConstants.wordBasedTestWordCount : null,
      incorrectCharPositions: incorrectCharPositions,
      originalText: originalText,
      userInput: userInput,
    );

    setState(() {
      testCompleted = true;
      testStarted = false;
    });

    dev.log(
      'Saving typing result - WPM: $wpm, Accuracy: $accuracy, Errors: $incorrectChars',
    );

    provider.saveResult(result);

    final resultsProvider = TypingTestResultsProvider.of(context);
    if (resultsProvider != null) {
      resultsProvider.showResults(result);
    }
  }

  String getTargetText() {
    final provider = Provider.of<TypingProvider>(context, listen: false);
    return provider.getCurrentText();
  }

  void onTextChanged(String value) {
    if (isProcessingInput) return;

    isProcessingInput = true;

    try {
      if (!testStarted && value.trim().isNotEmpty) {
        userInput = value;
        startTest();
        isProcessingInput = false;
        return;
      }

      if (value != userInput) {
        final words = value.split(' ').where((word) => word.isNotEmpty).length;

        if (words != wordsTyped || value.length != lastProcessedLength) {
          setState(() {
            userInput = value;
            wordsTyped = words;
            lastProcessedLength = value.length;
          });
        } else {
          userInput = value;
        }

        final sampleText = getTargetText();

        if (isWordBasedTest) {
          if (words >= AppConstants.wordBasedTestWordCount) {
            completeTest();
          }
        } else {
          if (value.length >= sampleText.length) {
            completeTest();
          }
        }
      }
    } finally {
      isProcessingInput = false;
    }
  }

  void resetTest() {
    typingSampleTimer?.cancel();

    setState(() {
      testStarted = false;
      testCompleted = false;
      userInput = '';
      wordsTyped = 0;
      lastProcessedLength = 0;
      remainingTime = testDuration;
    });

    textController.clear();
    textFocusNode.requestFocus();
  }

  void changeText() {
    Provider.of<TypingProvider>(context, listen: false).moveToNextText();
    resetTest();
  }

  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  String getDurationDisplay() {
    if (isWordBasedTest) {
      return '${AppConstants.wordBasedTestWordCount} Words';
    }
    return '${testDuration.inSeconds} seconds';
  }

  String getTimerDisplay() {
    if (isWordBasedTest) {
      return 'Words: $wordsTyped/${AppConstants.wordBasedTestWordCount}';
    }

    if (remainingTime.inSeconds <= 0) {
      return '0s';
    }
    return '${remainingTime.inSeconds}s';
  }

  Color getTimerColor(ThemeProvider themeProvider) {
    if (isWordBasedTest) {
      final progress = wordsTyped / AppConstants.wordBasedTestWordCount;
      if (progress >= 1.0) return Colors.green;
      if (progress >= 0.7) return Colors.orange;
      return Colors.blue;
    }

    if (remainingTime.inSeconds <= 10) return Colors.red;
    return Colors.blue;
  }

  EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return EdgeInsets.all(40);
    } else if (width > 768) {
      return const EdgeInsets.all(40.0);
    } else {
      return const EdgeInsets.all(20.0);
    }
  }

  double getResponsiveTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 28.0;
    } else if (width > 768) {
      return 26.0;
    } else {
      return 24.0;
    }
  }

  double getResponsiveSubtitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 18.0;
    } else if (width > 768) {
      return 17.0;
    } else {
      return 16.0;
    }
  }

  double getResponsiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 24.0;
    } else if (width > 768) {
      return 20.0;
    } else {
      return 16.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey('typing_test_screen'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isSmallMobile = screenWidth < 599;
          final isMobile = screenWidth < 600;
          final isTablet = screenWidth >= 600 && screenWidth < 1200;
          final isDesktop = screenWidth >= 1200;

          return isFullScreen
              ? typingTestFullScreenContent(
                context,
                isMobile,
                isTablet,
                isDesktop,
              )
              : typingTestNormalContent(
                context,
                isMobile,
                isTablet,
                isDesktop,
                isSmallMobile,
              );
        },
      ),
    );
  }

  Widget typingTestNormalContent(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    bool isSmallMobile,
  ) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final sampleText = provider.getCurrentText();

    final backgroundColor =
        themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[50];
    final cardColor =
        themeProvider.isDarkMode ? Colors.grey[800] : Colors.white;
    final borderColor =
        themeProvider.isDarkMode ? Colors.grey[500]! : Colors.grey[500]!;
    final subtitleColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final inputBorderColor =
        themeProvider.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;
    final titleColor = themeProvider.isDarkMode ? Colors.white : Colors.black;

    final padding = getResponsivePadding(context);
    final titleFontSize = getResponsiveTitleFontSize(context);
    final subtitleFontSize = getResponsiveSubtitleFontSize(context);
    final spacing = getResponsiveSpacing(context);

    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            typingTestHeader(
              context,
              titleFontSize,
              subtitleFontSize,
              isMobile,
              isTablet,
              isDesktop,
              isSmallMobile,
            ),
            SizedBox(height: spacing * 1.5),

            typingTestTimerAndStats(
              themeProvider,
              cardColor ?? Colors.grey,
              subtitleColor ?? Colors.grey,
              isMobile,
            ),
            SizedBox(height: spacing * 1.25),
            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 26),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SelectableText(
                          isWordBasedTest
                              ? 'Type the text below (${AppConstants.wordBasedTestWordCount} words):'
                              : 'Type the text below:',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: titleColor,
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filled(
                            onPressed: changeText,
                            icon: Icon(
                              FontAwesomeIcons.syncAlt,
                              size: isMobile ? 16 : 20,
                            ),
                            tooltip: 'Change Text',
                          ),
                          SizedBox(width: isMobile ? 4 : 8),
                          IconButton.filled(
                            onPressed: toggleFullScreen,
                            icon: Icon(
                              FontAwesomeIcons.maximize,
                              size: isMobile ? 16 : 20,
                            ),
                            tooltip: 'Full Screen',
                          ),
                          SizedBox(width: isMobile ? 4 : 8),
                          TextButton(
                            onPressed: resetTest,
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                themeProvider.primaryColor,
                              ),
                            ),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    themeProvider.primaryColor ==
                                                Colors.amber ||
                                            themeProvider.primaryColor ==
                                                Colors.yellow ||
                                            themeProvider.primaryColor ==
                                                Colors.lime
                                        ? Colors.black
                                        : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 20 : 28),
                  TextDisplayWidget(
                    sampleText: sampleText,
                    userInput: userInput,
                    isTestActive: testStarted && !testCompleted,
                    isDarkMode: themeProvider.isDarkMode,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  TextField(
                    controller: textController,
                    focusNode: textFocusNode,
                    enabled: !testCompleted,
                    maxLines: isMobile ? 6 : 8,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 0.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 0.2),
                      ),
                      enabled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 0.2),
                      ),
                      hintText:
                          'Ready? Start typing from the very first letter to begin your test.',
                      hintStyle: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[600],
                      ),
                      fillColor: Colors.white,
                      filled: false,
                    ),
                    onChanged: onTextChanged,
                    autofocus: true,
                    style: TextStyle(
                      color:
                          themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  SizedBox(height: spacing * 1),

                  Align(
                    alignment: Alignment.centerRight,
                    child: typingTestInputField(
                      themeProvider,
                      cardColor ?? Colors.grey,
                      inputBorderColor,
                      subtitleColor ?? Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget typingTestFullScreenContent(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final sampleText = provider.getCurrentText();

    final borderColor =
        themeProvider.isDarkMode ? Colors.grey[500]! : Colors.grey[500]!;
    final titleColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final cardColor =
        themeProvider.isDarkMode ? Colors.grey[800] : Colors.white;
    final subtitleColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final inputBorderColor =
        themeProvider.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;

    final padding = EdgeInsets.all(isMobile ? 16 : 20);
    final spacing = getResponsiveSpacing(context);

    return Padding(
      padding: padding,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isWordBasedTest
                      ? 'Type the text below (${AppConstants.wordBasedTestWordCount} words)'
                      : 'Type the text below',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filled(
                    onPressed: changeText,
                    icon: Icon(
                      FontAwesomeIcons.syncAlt,
                      size: isMobile ? 16 : 20,
                    ),
                    tooltip: 'Change Text',
                  ),
                  SizedBox(width: isMobile ? 4 : 8),
                  IconButton.filled(
                    onPressed: toggleFullScreen,
                    icon: Icon(
                      FontAwesomeIcons.minimize,
                      size: isMobile ? 16 : 20,
                    ),
                    tooltip: 'Minimize',
                  ),
                  SizedBox(width: isMobile ? 4 : 8),
                  TextButton(
                    onPressed: resetTest,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        themeProvider.primaryColor,
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color:
                            themeProvider.primaryColor == Colors.amber ||
                                    themeProvider.primaryColor ==
                                        Colors.yellow ||
                                    themeProvider.primaryColor == Colors.lime
                                ? Colors.black
                                : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: spacing),

          typingTestTimerAndStatsFullScreen(themeProvider, isMobile),
          SizedBox(height: spacing),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextDisplayWidget(
                      sampleText: sampleText,
                      userInput: userInput,
                      isTestActive: testStarted && !testCompleted,
                      isDarkMode: themeProvider.isDarkMode,
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    TextField(
                      controller: textController,
                      focusNode: textFocusNode,
                      enabled: !testCompleted,
                      maxLines: isMobile ? 8 : 10,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: borderColor,
                            width: 0.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: borderColor,
                            width: 0.2,
                          ),
                        ),
                        enabled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: borderColor,
                            width: 0.2,
                          ),
                        ),
                        hintText:
                            'Ready? Start typing from the very first letter to begin your test.',
                        hintStyle: TextStyle(
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                        ),
                        fillColor: Colors.white,
                        filled: false,
                      ),
                      onChanged: onTextChanged,
                      autofocus: true,
                      style: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                    SizedBox(height: spacing),

                    Align(
                      alignment: Alignment.centerRight,
                      child: typingTestInputField(
                        themeProvider,
                        cardColor ?? Colors.grey,
                        inputBorderColor,
                        subtitleColor ?? Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget typingTestTimerAndStatsFullScreen(
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    final provider = Provider.of<TypingProvider>(context, listen: false);
    final currentDifficulty = provider.selectedDifficulty;

    final words = userInput.split(' ').where((word) => word.isNotEmpty).length;

    double wpm = 0;
    if (startTime != null && testStarted) {
      final elapsedSeconds = DateTime.now().difference(startTime!).inSeconds;
      if (elapsedSeconds > 0) {
        wpm = (words / (elapsedSeconds / 60));
      }
    }

    final timerColor = getTimerColor(themeProvider);

    return isMobile
        ? Column(
          children: [
            typingTestStatCardFullScreen(
              isWordBasedTest ? 'Words Progress' : 'Time Remaining',
              getTimerDisplay(),
              timerColor,
              themeProvider,
              isMobile,
            ),
            SizedBox(height: 8),
            typingTestStatCardFullScreen(
              'Current WPM',
              wpm.toStringAsFixed(2),
              Colors.green,
              themeProvider,
              isMobile,
            ),
            SizedBox(height: 8),
            typingTestStatCardFullScreen(
              'Words Typed',
              '$words',
              Colors.orange,
              themeProvider,
              isMobile,
            ),
            SizedBox(height: 8),
            typingTestStatCardFullScreen(
              'Difficulty',
              currentDifficulty,
              Colors.purple,
              themeProvider,
              isMobile,
            ),
          ],
        )
        : Row(
          children: [
            Expanded(
              child: typingTestStatCardFullScreen(
                isWordBasedTest ? 'Words Progress' : 'Time Remaining',
                getTimerDisplay(),
                timerColor,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: typingTestStatCardFullScreen(
                'Current WPM',
                wpm.toStringAsFixed(2),
                Colors.green,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: typingTestStatCardFullScreen(
                'Words Typed',
                '$words',
                Colors.orange,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: typingTestStatCardFullScreen(
                'Difficulty',
                currentDifficulty,
                Colors.purple,
                themeProvider,
                isMobile,
              ),
            ),
          ],
        );
  }

  Widget typingTestStatCardFullScreen(
    String title,
    String value,
    Color color,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    final subtitleColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 16 : 20,
        horizontal: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(themeProvider.isDarkMode ? 0.03 : 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget typingTestHeader(
    BuildContext context,
    double titleFontSize,
    double subtitleFontSize,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    bool isSmallMobile,
  ) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment:
          isSmallMobile
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
      children: [
        isSmallMobile
            ? SizedBox()
            : Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    'Typing Speed Test',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    'Improve your typing speed and accuracy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        isSmallMobile
            ? Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Typing Speed Test',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Improve your typing speed and accuracy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 18),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: isMobile ? 105 : 200,
                        child: CustomDropdown<String>(
                          value: provider.selectedDifficulty,
                          onChanged:
                              testStarted
                                  ? null
                                  : (value) {
                                    if (value != null) {
                                      provider.setDifficulty(value);
                                      resetTest();
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
                          isDarkMode: themeProvider.isDarkMode,
                          lightModeColor: Colors.grey.shade200,
                          darkModeColor: Colors.grey.shade800,
                          enabled: !testStarted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: isMobile ? 130 : 200,
                        child: CustomDropdown<Duration>(
                          value: provider.selectedDuration,
                          onChanged:
                              testStarted
                                  ? null
                                  : (value) {
                                    if (value != null) {
                                      provider.setDuration(value);
                                      testDuration = value;
                                      remainingTime = value;
                                      resetTest();
                                    }
                                  },
                          items:
                              AppConstants.testDurations.map((duration) {
                                return DropdownMenuItem(
                                  value: duration,
                                  child: Text(
                                    duration.inSeconds == 0
                                        ? '${AppConstants.wordBasedTestWordCount} Words'
                                        : '${duration.inSeconds} seconds',
                                    style: TextStyle(
                                      color:
                                          themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                          isDarkMode: themeProvider.isDarkMode,
                          lightModeColor: Colors.grey.shade200,
                          darkModeColor: Colors.grey.shade800,
                          enabled: !testStarted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
            : isMobile
            ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: isMobile ? 100 : 200,
                  child: CustomDropdown<String>(
                    value: provider.selectedDifficulty,
                    onChanged:
                        testStarted
                            ? null
                            : (value) {
                              if (value != null) {
                                provider.setDifficulty(value);
                                resetTest();
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
                    isDarkMode: themeProvider.isDarkMode,
                    lightModeColor: Colors.grey.shade200,
                    darkModeColor: Colors.grey.shade800,
                    enabled: !testStarted,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: isMobile ? 100 : 200,
                  child: CustomDropdown<Duration>(
                    value: provider.selectedDuration,
                    onChanged:
                        testStarted
                            ? null
                            : (value) {
                              if (value != null) {
                                provider.setDuration(value);
                                testDuration = value;
                                remainingTime = value;
                                resetTest();
                              }
                            },
                    items:
                        AppConstants.testDurations.map((duration) {
                          return DropdownMenuItem(
                            value: duration,
                            child: Text(
                              duration.inSeconds == 0
                                  ? '${AppConstants.wordBasedTestWordCount} Words'
                                  : '${duration.inSeconds} seconds',
                              style: TextStyle(
                                color:
                                    themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                    isDarkMode: themeProvider.isDarkMode,
                    lightModeColor: Colors.grey.shade200,
                    darkModeColor: Colors.grey.shade800,
                    enabled: !testStarted,
                  ),
                ),
              ],
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: isMobile ? 150 : 200,
                  child: CustomDropdown<String>(
                    value: provider.selectedDifficulty,
                    onChanged:
                        testStarted
                            ? null
                            : (value) {
                              if (value != null) {
                                provider.setDifficulty(value);
                                resetTest();
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
                    isDarkMode: themeProvider.isDarkMode,
                    lightModeColor: Colors.grey.shade200,
                    darkModeColor: Colors.grey.shade800,
                    enabled: !testStarted,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: isMobile ? 150 : 200,
                  child: CustomDropdown<Duration>(
                    value: provider.selectedDuration,
                    onChanged:
                        testStarted
                            ? null
                            : (value) {
                              if (value != null) {
                                provider.setDuration(value);
                                testDuration = value;
                                remainingTime = value;
                                resetTest();
                              }
                            },
                    items:
                        AppConstants.testDurations.map((duration) {
                          return DropdownMenuItem(
                            value: duration,
                            child: Text(
                              duration.inSeconds == 0
                                  ? '${AppConstants.wordBasedTestWordCount} Words'
                                  : '${duration.inSeconds} seconds',
                              style: TextStyle(
                                color:
                                    themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                    isDarkMode: themeProvider.isDarkMode,
                    lightModeColor: Colors.grey.shade200,
                    darkModeColor: Colors.grey.shade800,
                    enabled: !testStarted,
                  ),
                ),
              ],
            ),
      ],
    );
  }

  Widget typingTestTimerAndStats(
    ThemeProvider themeProvider,
    Color cardColor,
    Color subtitleColor,
    bool isMobile,
  ) {
    final provider = Provider.of<TypingProvider>(context, listen: false);
    final currentDifficulty = provider.selectedDifficulty;

    final words = userInput.split(' ').where((word) => word.isNotEmpty).length;

    double wpm = 0;
    if (startTime != null && testStarted) {
      final elapsedSeconds = DateTime.now().difference(startTime!).inSeconds;
      if (elapsedSeconds > 0) {
        wpm = (words / (elapsedSeconds / 60));
      }
    }

    final timerColor = getTimerColor(themeProvider);

    return isMobile
        ? Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: typingTestStatCard(
                    isWordBasedTest ? 'Words Progress' : 'Time Remaining',
                    getTimerDisplay(),
                    timerColor,
                    themeProvider,
                    isMobile,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: typingTestStatCard(
                    'Current WPM',
                    wpm.toStringAsFixed(2),
                    Colors.green,
                    themeProvider,
                    isMobile,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: typingTestStatCard(
                    'Words Typed',
                    '$words',
                    Colors.orange,
                    themeProvider,
                    isMobile,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: typingTestStatCard(
                    'Difficulty',
                    currentDifficulty,
                    Colors.purple,
                    themeProvider,
                    isMobile,
                  ),
                ),
              ],
            ),
          ],
        )
        : Row(
          children: [
            Expanded(
              child: typingTestStatCard(
                isWordBasedTest ? 'Words Progress' : 'Time Remaining',
                getTimerDisplay(),
                timerColor,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: typingTestStatCard(
                'Current WPM',
                wpm.toStringAsFixed(2),
                Colors.green,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: typingTestStatCard(
                'Words Typed',
                '$words',
                Colors.orange,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: typingTestStatCard(
                'Difficulty',
                currentDifficulty,
                Colors.purple,
                themeProvider,
                isMobile,
              ),
            ),
          ],
        );
  }

  Widget typingTestStatCard(
    String title,
    String value,
    Color color,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    final subtitleColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 20 : 26,
        horizontal: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget typingTestInputField(
    ThemeProvider themeProvider,
    Color cardColor,
    Color borderColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (testStarted || testCompleted)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: resetTest,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    themeProvider.isDarkMode ? Colors.white : Colors.black12,
                  ),
                ),
                child: Text(
                  'Restart Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: testStarted ? completeTest : null,
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    themeProvider.primaryColor,
                  ),
                ),
                child: Text(
                  'Complete Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        themeProvider.primaryColor == Colors.amber ||
                                themeProvider.primaryColor == Colors.yellow ||
                                themeProvider.primaryColor == Colors.lime
                            ? Colors.black
                            : Colors.white,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
