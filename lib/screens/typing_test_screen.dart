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
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  String _userInput = '';
  DateTime? _startTime;
  bool _testStarted = false;
  bool _testCompleted = false;
  Duration _remainingTime = Duration.zero;
  late Duration _testDuration;
  int _wordsTyped = 0;
  bool get _isWordBasedTest => _testDuration.inSeconds == 0;

  int _lastProcessedLength = 0;
  bool _isProcessingInput = false;

  bool _isFullScreen = false;

  Timer? _typingSampleTimer;
  int _lastSampleCharCount = 0;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TypingProvider>(context, listen: false);
    _testDuration = provider.selectedDuration;
    _remainingTime = _testDuration;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _textFocusNode.requestFocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<TypingProvider>(context, listen: false);
    if (_testDuration != provider.selectedDuration) {
      _testDuration = provider.selectedDuration;
      _remainingTime = _testDuration;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _typingSampleTimer?.cancel();
    super.dispose();
  }

  void _startTest() {
    if (!mounted) return;

    setState(() {
      _testStarted = true;
      _startTime = DateTime.now();
      _userInput = '';
      _wordsTyped = 0;
      _lastProcessedLength = 0;
      _textController.clear();
      _remainingTime = _testDuration;
    });

    final provider = Provider.of<TypingProvider>(context, listen: false);
    provider.resetConsistencyTracking();
    _lastSampleCharCount = 0;

    _startTypingSampleTimer();

    if (!_isWordBasedTest) {
      _startTimer();
    }
  }

  void _startTypingSampleTimer() {
    _typingSampleTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!_testStarted || _testCompleted || !mounted) {
        timer.cancel();
        return;
      }

      final provider = Provider.of<TypingProvider>(context, listen: false);
      final currentCharCount = _userInput.length;

      if (currentCharCount > _lastSampleCharCount) {
        provider.recordTypingSpeedSample(currentCharCount, DateTime.now());
        _lastSampleCharCount = currentCharCount;
      }
    });
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
    if (_startTime == null || !mounted) return;

    _typingSampleTimer?.cancel();

    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    final words = _userInput.split(' ').where((word) => word.isNotEmpty).length;

    final wpm = (words / (duration.inSeconds / 60)).round();

    int correctChars = 0;
    final sampleText = _getTargetText();

    for (int i = 0; i < _userInput.length && i < sampleText.length; i++) {
      if (_userInput[i] == sampleText[i]) correctChars++;
    }

    final accuracy =
        sampleText.isNotEmpty ? (correctChars / sampleText.length) * 100 : 0;

    final provider = Provider.of<TypingProvider>(context, listen: false);
    final consistency = provider.calculateConsistency();

    final result = TypingResult(
      wpm: wpm,
      accuracy: accuracy.toDouble(),
      consistency: consistency,
      correctChars: correctChars,
      incorrectChars: _userInput.length - correctChars,
      totalChars: _userInput.length,
      duration: duration,
      timestamp: DateTime.now(),
      difficulty: provider.selectedDifficulty,
      isWordBasedTest: _isWordBasedTest,
      targetWords:
          _isWordBasedTest ? AppConstants.wordBasedTestWordCount : null,
    );

    setState(() {
      _testCompleted = true;
      _testStarted = false;
    });

    dev.log('Saving typing result - WPM: $wpm, Accuracy: $accuracy');

    provider.saveResult(result);

    final resultsProvider = TypingTestResultsProvider.of(context);
    if (resultsProvider != null) {
      resultsProvider.showResults(result);
    }
  }

  String _getTargetText() {
    final provider = Provider.of<TypingProvider>(context, listen: false);
    return provider.getCurrentText();
  }

  void _onTextChanged(String value) {
    if (_isProcessingInput) return;

    _isProcessingInput = true;

    try {
      if (!_testStarted && value.isNotEmpty) {
        _startTest();
      }

      if (value != _userInput) {
        final words = value.split(' ').where((word) => word.isNotEmpty).length;

        if (words != _wordsTyped || value.length != _lastProcessedLength) {
          setState(() {
            _userInput = value;
            _wordsTyped = words;
            _lastProcessedLength = value.length;
          });
        } else {
          _userInput = value;
        }

        final sampleText = _getTargetText();

        if (_isWordBasedTest) {
          if (words >= AppConstants.wordBasedTestWordCount) {
            _completeTest();
          }
        } else {
          if (value.length >= sampleText.length) {
            _completeTest();
          }
        }
      }
    } finally {
      _isProcessingInput = false;
    }
  }

  void _resetTest() {
    _typingSampleTimer?.cancel();

    setState(() {
      _testStarted = false;
      _testCompleted = false;
      _userInput = '';
      _wordsTyped = 0;
      _lastProcessedLength = 0;
      _textController.clear();
      _remainingTime = _testDuration;
    });

    _textFocusNode.requestFocus();
  }

  void _changeText() {
    Provider.of<TypingProvider>(context, listen: false).moveToNextText();
    _resetTest();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  String getDurationDisplay() {
    if (_isWordBasedTest) {
      return '${AppConstants.wordBasedTestWordCount} Words';
    }
    return '${_testDuration.inSeconds} seconds';
  }

  String _getTimerDisplay() {
    if (_isWordBasedTest) {
      return 'Words: $_wordsTyped/${AppConstants.wordBasedTestWordCount}';
    }

    if (_remainingTime.inSeconds <= 0) {
      return '0s';
    }
    return '${_remainingTime.inSeconds}s';
  }

  Color _getTimerColor(ThemeProvider themeProvider) {
    if (_isWordBasedTest) {
      final progress = _wordsTyped / AppConstants.wordBasedTestWordCount;
      if (progress >= 1.0) return Colors.green;
      if (progress >= 0.7) return Colors.orange;
      return Colors.blue;
    }

    if (_remainingTime.inSeconds <= 10) return Colors.red;
    return Colors.blue;
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return EdgeInsets.all(40);
    } else if (width > 768) {
      return const EdgeInsets.all(40.0);
    } else {
      return const EdgeInsets.all(20.0);
    }
  }

  double _getResponsiveTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 28.0;
    } else if (width > 768) {
      return 26.0;
    } else {
      return 24.0;
    }
  }

  double _getResponsiveSubtitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 18.0;
    } else if (width > 768) {
      return 17.0;
    } else {
      return 16.0;
    }
  }

  double _getResponsiveSpacing(BuildContext context) {
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

          return _isFullScreen
              ? _buildFullScreenContent(context, isMobile, isTablet, isDesktop)
              : _buildNormalContent(
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

  Widget _buildNormalContent(
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

    final padding = _getResponsivePadding(context);
    final titleFontSize = _getResponsiveTitleFontSize(context);
    final subtitleFontSize = _getResponsiveSubtitleFontSize(context);
    final spacing = _getResponsiveSpacing(context);

    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              context,
              titleFontSize,
              subtitleFontSize,
              isMobile,
              isTablet,
              isDesktop,
              isSmallMobile,
            ),
            SizedBox(height: spacing * 2.5),

            _buildTimerAndStats(
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
                          _isWordBasedTest
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
                            onPressed: _changeText,
                            icon: Icon(
                              FontAwesomeIcons.syncAlt,
                              size: isMobile ? 16 : 20,
                            ),
                            tooltip: 'Change Text',
                          ),
                          SizedBox(width: isMobile ? 4 : 8),
                          IconButton.filled(
                            onPressed: _toggleFullScreen,
                            icon: Icon(
                              FontAwesomeIcons.maximize,
                              size: isMobile ? 16 : 20,
                            ),
                            tooltip: 'Full Screen',
                          ),
                          SizedBox(width: isMobile ? 4 : 8),
                          TextButton(
                            onPressed: _resetTest,
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.amber,
                              ),
                            ),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
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
                    userInput: _userInput,
                    isTestActive: _testStarted && !_testCompleted,
                    isDarkMode: themeProvider.isDarkMode,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  TextField(
                    controller: _textController,
                    focusNode: _textFocusNode,
                    enabled: !_testCompleted,
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
            SizedBox(height: spacing * 1.25),

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

  Widget _buildFullScreenContent(
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
    final spacing = _getResponsiveSpacing(context);

    return Padding(
      padding: padding,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _isWordBasedTest
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
                    onPressed: _changeText,
                    icon: Icon(
                      FontAwesomeIcons.syncAlt,
                      size: isMobile ? 16 : 20,
                    ),
                    tooltip: 'Change Text',
                  ),
                  SizedBox(width: isMobile ? 4 : 8),
                  IconButton.filled(
                    onPressed: _toggleFullScreen,
                    icon: Icon(
                      FontAwesomeIcons.minimize,
                      size: isMobile ? 16 : 20,
                    ),
                    tooltip: 'Minimize',
                  ),
                  SizedBox(width: isMobile ? 4 : 8),
                  TextButton(
                    onPressed: _resetTest,
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.amber),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: spacing),

          _buildTimerAndStatsFullScreen(themeProvider, isMobile),
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
                      userInput: _userInput,
                      isTestActive: _testStarted && !_testCompleted,
                      isDarkMode: themeProvider.isDarkMode,
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    TextField(
                      controller: _textController,
                      focusNode: _textFocusNode,
                      enabled: !_testCompleted,
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
            ),
          ),
          SizedBox(height: spacing),

          _buildInputField(
            themeProvider,
            cardColor ?? Colors.grey,
            inputBorderColor,
            subtitleColor ?? Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerAndStatsFullScreen(
    ThemeProvider themeProvider,
    bool isMobile,
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

    final timerColor = _getTimerColor(themeProvider);

    return isMobile
        ? Column(
          children: [
            _buildStatCardFullScreen(
              _isWordBasedTest ? 'Words Progress' : 'Time Remaining',
              _getTimerDisplay(),
              timerColor,
              themeProvider,
              isMobile,
            ),
            SizedBox(height: 8),
            _buildStatCardFullScreen(
              'Current WPM',
              wpm.toStringAsFixed(2),
              Colors.green,
              themeProvider,
              isMobile,
            ),
            SizedBox(height: 8),
            _buildStatCardFullScreen(
              'Words Typed',
              '$words',
              Colors.orange,
              themeProvider,
              isMobile,
            ),
            SizedBox(height: 8),
            _buildStatCardFullScreen(
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
              child: _buildStatCardFullScreen(
                _isWordBasedTest ? 'Words Progress' : 'Time Remaining',
                _getTimerDisplay(),
                timerColor,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCardFullScreen(
                'Current WPM',
                wpm.toStringAsFixed(2),
                Colors.green,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCardFullScreen(
                'Words Typed',
                '$words',
                Colors.orange,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCardFullScreen(
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

  Widget _buildStatCardFullScreen(
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

  Widget _buildHeader(
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
    final titleColor =
        themeProvider.isDarkMode ? Colors.white : Colors.grey[800];
    final subtitleColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600];

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
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    'Improve your typing speed and accuracy',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: subtitleColor,
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
                          isDarkMode: themeProvider.isDarkMode,
                          lightModeColor: Colors.grey.shade200,
                          darkModeColor: Colors.grey.shade800,
                          enabled: !_testStarted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: isMobile ? 130 : 200,
                        child: CustomDropdown<Duration>(
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
                          enabled: !_testStarted,
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
                    isDarkMode: themeProvider.isDarkMode,
                    lightModeColor: Colors.grey.shade200,
                    darkModeColor: Colors.grey.shade800,
                    enabled: !_testStarted,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: isMobile ? 100 : 200,
                  child: CustomDropdown<Duration>(
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
                    enabled: !_testStarted,
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
                    isDarkMode: themeProvider.isDarkMode,
                    lightModeColor: Colors.grey.shade200,
                    darkModeColor: Colors.grey.shade800,
                    enabled: !_testStarted,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: isMobile ? 150 : 200,
                  child: CustomDropdown<Duration>(
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
                    enabled: !_testStarted,
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
    bool isMobile,
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

    final timerColor = _getTimerColor(themeProvider);

    return isMobile
        ? Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    _isWordBasedTest ? 'Words Progress' : 'Time Remaining',
                    _getTimerDisplay(),
                    timerColor,
                    themeProvider,
                    isMobile,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
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
                  child: _buildStatCard(
                    'Words Typed',
                    '$words',
                    Colors.orange,
                    themeProvider,
                    isMobile,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
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
              child: _buildStatCard(
                _isWordBasedTest ? 'Words Progress' : 'Time Remaining',
                _getTimerDisplay(),
                timerColor,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Current WPM',
                wpm.toStringAsFixed(2),
                Colors.green,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Words Typed',
                '$words',
                Colors.orange,
                themeProvider,
                isMobile,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
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

  Widget _buildStatCard(
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
