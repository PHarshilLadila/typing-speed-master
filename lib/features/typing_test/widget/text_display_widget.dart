// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class TextDisplayWidget extends StatefulWidget {
  final String sampleText;
  final String userInput;
  final bool isTestActive;
  final bool isDarkMode;

  const TextDisplayWidget({
    super.key,
    required this.sampleText,
    required this.userInput,
    required this.isTestActive,
    required this.isDarkMode,
  });

  @override
  State<TextDisplayWidget> createState() => _TextDisplayWidgetState();
}

class _TextDisplayWidgetState extends State<TextDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> cursorAnimation;
  late Animation<Color?> colorAnimation;

  String previousUserInput = '';
  double currentFontSize = 24.0;
  final double minFontSize = 16.0;
  final double maxFontSize = 38.0;
  final double fontSizeStep = 2.0;

  @override
  void initState() {
    super.initState();
    loadFontSize();
    initializeAnimations();
  }

  void initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    cursorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    colorAnimation = ColorTween(
      begin: Colors.blue.withOpacity(0.3),
      end: Colors.blue.withOpacity(0.7),
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animationController.repeat(reverse: true);
  }

  Future<void> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentFontSize = prefs.getDouble('text_font_size') ?? 24.0;
    });
  }

  Future<void> saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_font_size', fontSize);
  }

  void increaseFontSize() {
    if (currentFontSize < maxFontSize) {
      setState(() {
        currentFontSize += fontSizeStep;
      });
      saveFontSize(currentFontSize);
    }
  }

  void decreaseFontSize() {
    if (currentFontSize > minFontSize) {
      setState(() {
        currentFontSize -= fontSizeStep;
      });
      saveFontSize(currentFontSize);
    }
  }

  @override
  void didUpdateWidget(TextDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.userInput != previousUserInput) {
      handleInputChange(oldWidget.userInput, widget.userInput);
      previousUserInput = widget.userInput;
    }
  }

  void handleInputChange(String oldInput, String newInput) {
    if (newInput.length > oldInput.length) {
      triggerCharacterAnimation();
    }
  }

  void triggerCharacterAnimation() {
    animationController
      ..stop()
      ..forward(from: 0.0);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final containerColor =
        widget.isDarkMode
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.04);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IntrinsicWidth(
            child: IntrinsicHeight(child: typingAnimatedText()),
          ),
        ),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: Container(
            decoration: BoxDecoration(
              color:
                  themeProvider.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: decreaseFontSize,
                  icon: Icon(
                    Icons.remove,
                    size: 18,
                    color:
                        currentFontSize <= minFontSize
                            ? Colors.grey
                            : widget.isDarkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  tooltip: 'Decrease font size',
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${currentFontSize.toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: increaseFontSize,
                  icon: Icon(
                    Icons.add,
                    size: 18,
                    color:
                        currentFontSize >= maxFontSize
                            ? Colors.grey
                            : widget.isDarkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  tooltip: 'Increase font size',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget typingAnimatedText() {
    return Text.rich(
      TextSpan(children: typingAnimatedTextSpans()),
      style: TextStyle(
        fontSize: currentFontSize,
        fontWeight: FontWeight.w400,
        height: 1.5,
        fontFamily: 'Monospace',
      ),
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }

  List<TextSpan> typingAnimatedTextSpans() {
    final List<TextSpan> spans = [];
    final defaultTextColor =
        widget.isDarkMode ? Colors.grey[300] : Colors.grey[800];

    for (int i = 0; i < widget.sampleText.length; i++) {
      final char = widget.sampleText[i];
      final textSpan = typingTextSpanForChar(i, char, defaultTextColor!);
      spans.add(textSpan);
    }

    return spans;
  }

  TextSpan typingTextSpanForChar(
    int index,
    String char,
    Color defaultTextColor,
  ) {
    Color color = defaultTextColor;
    Color backgroundColor = Colors.transparent;
    FontWeight fontWeight = FontWeight.w400;

    if (index < widget.userInput.length) {
      if (widget.userInput[index] == char) {
        color = widget.isDarkMode ? Colors.green[300]! : Colors.green[700]!;
        backgroundColor = getBackgroundColor(Colors.green);
        fontWeight = FontWeight.w500;
      } else {
        color = widget.isDarkMode ? Colors.red[300]! : Colors.red[700]!;
        backgroundColor = getBackgroundColor(Colors.red);
        fontWeight = FontWeight.w500;
      }
    } else if (index == widget.userInput.length && widget.isTestActive) {
      return TextSpan(
        text: char,
        style: TextStyle(
          color: widget.isDarkMode ? Colors.blue[100] : Colors.blue[900],
          backgroundColor: colorAnimation.value,
          fontWeight: FontWeight.w600,
          fontSize: currentFontSize,
        ),
      );
    }

    return TextSpan(
      text: char,
      style: TextStyle(
        color: color,
        backgroundColor: backgroundColor,
        fontWeight: fontWeight,
        fontSize: currentFontSize,
      ),
    );
  }

  Color getBackgroundColor(Color baseColor) {
    if (!widget.isTestActive) return Colors.transparent;

    final animationValue = cursorAnimation.value;
    return baseColor.withOpacity(
      widget.isDarkMode
          ? 0.1 + (animationValue * 0.1)
          : 0.05 + (animationValue * 0.05),
    );
  }
}
