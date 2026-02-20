import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:typing_speed_master/features/games/game_word_reflex/sections/game_word_reflex_history_view.dart';
import 'provider/word_reflex_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/features/games/game_word_reflex/widgets/word_reflex_share_dialog.dart';

class GameWordReflexScreen extends StatefulWidget {
  const GameWordReflexScreen({super.key});

  @override
  State<GameWordReflexScreen> createState() => GameWordReflexScreenState();
}

class GameWordReflexScreenState extends State<GameWordReflexScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController answerController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  late ConfettiController confettiController;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );
    animationController.forward();
  }

  @override
  void dispose() {
    answerController.dispose();
    focusNode.dispose();
    confettiController.dispose();
    animationController.dispose();
    super.dispose();
  }

  void submitAnswer(WordReflexProvider provider) {
    if (answerController.text.isNotEmpty) {
      provider.checkAnswer(answerController.text);
      answerController.clear();
      focusNode.requestFocus();
    }
  }

  EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) {
      return EdgeInsets.symmetric(
        vertical: 50,
        horizontal: MediaQuery.of(context).size.width / 5,
      );
    } else if (width > 768) {
      return const EdgeInsets.all(40.0);
    } else {
      return const EdgeInsets.symmetric(vertical: 40.0, horizontal: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<WordReflexProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: getResponsivePadding(context),
          child: Column(
            children: [
              wordReflexHeader(context, themeProvider, provider),
              const SizedBox(height: 40),
              wordReflexStats(context, provider, themeProvider),
              const SizedBox(height: 20),
              wRFXGameArea(
                context,
                provider,
                themeProvider,
                screenSize,
                true,
                true,
              ),
              const SizedBox(height: 20),
              wordReflexInstructions(themeProvider.isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget wordReflexHeader(
    BuildContext context,
    ThemeProvider themeProvider,
    WordReflexProvider provider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Word Reflex',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Test your memory! Remember the synonym and type it.",
                style: GoogleFonts.outfit(
                  fontSize: 16,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                provider.showHistory();
              },
              icon: Icon(
                Icons.leaderboard,
                color:
                    themeProvider.isDarkMode ? Colors.white : Colors.grey[600],
              ),
              tooltip: 'Score History',
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const WordReflexSettingsDialog(),
                );
              },
              icon: Icon(
                Icons.settings,
                color:
                    themeProvider.isDarkMode ? Colors.white : Colors.grey[600],
              ),
              tooltip: 'Game Settings',
            ),
          ],
        ),
      ],
    );
  }

  Widget wordReflexStats(
    BuildContext context,
    WordReflexProvider provider,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black12 : Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          gameWordReflexStatItem(
            'Score',
            provider.score.toString(),
            Icons.emoji_events,
            Colors.amber,
            themeProvider,
          ),
          gameWordReflexStatItem(
            'Streak',
            provider.streak.toString(),
            Icons.local_fire_department,
            Colors.red,
            themeProvider,
          ),
          gameWordReflexStatItem(
            'Time',
            '${provider.remainingGameTime}s',
            Icons.timer,
            Colors.blue,
            themeProvider,
          ),

          gameWordReflexRestartButton(themeProvider, () {
            provider.resetToSetup();
          }),
          // IconButton(
          //   onPressed: () {
          //     provider.resetToSetup();
          //   },
          //   icon: Icon(
          //     Icons.restart_alt,
          //     color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
          //   ),
          //   tooltip: 'Restart Game',
          // ),
        ],
      ),
    );
  }

  // Widget gameWordReflexRestartButton(
  //   ThemeProvider themeProvider,
  //   VoidCallback onRestart,
  // ) {
  //   return GestureDetector(
  //     onTap: onRestart,
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(Icons.restart_alt, color: Colors.green, size: 24),
  //         const SizedBox(height: 4),
  //         Flexible(
  //           fit: FlexFit.loose,
  //           child: Text(
  //             'Restart\nGame',
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.bold,
  //               color: themeProvider.isDarkMode ? Colors.white : Colors.black,
  //             ),
  //             textAlign: TextAlign.center,
  //             maxLines: 2,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget gameWordReflexRestartButton(
    ThemeProvider themeProvider,
    VoidCallback onRestart,
  ) {
    return GestureDetector(
      onTap: onRestart,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restart_alt, color: Colors.green, size: 24),
          const SizedBox(height: 4),
          Flexible(
            fit: FlexFit.loose,
            child: RichText(
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: 'Restart\nGame',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget gameWordReflexStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color:
                themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget wRFXGameArea(
    BuildContext context,
    WordReflexProvider provider,
    ThemeProvider themeProvider,
    Size screenSize,
    bool isBuildResultOverlay,
    bool isGameWordReflexHistoryOverlay,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black12 : Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: wRFXGameBackground(themeProvider.isDarkMode)),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: wRFXGameActiveGameContent(
                context,
                provider,
                themeProvider,
                screenSize,
              ),
            ),
          ),
          if (provider.stage == GameStage.result &&
              isBuildResultOverlay == true)
            Center(
              child: wRFXGameResultOverlay(context, provider, themeProvider),
            ),
          if (provider.stage == GameStage.setup)
            wRFXGameSetupSection(context, provider, themeProvider),
          if (provider.stage == GameStage.history &&
              isGameWordReflexHistoryOverlay == true)
            const GameWordReflexHistoryView(),
        ],
      ),
    );
  }

  Widget wRFXGameBackground(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDarkMode
                  ? [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                  ]
                  : [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget wRFXGameActiveGameContent(
    BuildContext context,
    WordReflexProvider provider,
    ThemeProvider themeProvider,
    Size screenSize,
  ) {
    if (provider.stage == GameStage.setup ||
        provider.stage == GameStage.result ||
        provider.stage == GameStage.history) {
      return const SizedBox();
    }

    final isReading = provider.stage == GameStage.reading;
    final isDark = themeProvider.isDarkMode;

    if (!isReading && !focusNode.hasFocus) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () => focusNode.requestFocus(),
      );
    }

    final isMobile = screenSize.width <= 800;
    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MAIN WORD',
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.primaryColor.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.primaryColor.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                provider.currentRound?.mainWord.toUpperCase() ?? '',
                style: GoogleFonts.outfit(
                  fontSize: isMobile ? 36 : 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              "Memorize the correct synonym of main word (1 out of 3) before the words disappear!",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: List.generate(provider.currentOptions.length, (index) {
                final word = provider.currentOptions[index];
                final showWord = isReading || provider.isEyeButtonActive;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width:
                      (screenSize.width > 600)
                          ? 160
                          : (screenSize.width - 100) / 3,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        showWord
                            ? (isDark ? Colors.grey[900] : Colors.grey[200])
                            : (isDark ? Colors.grey[900] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.transparent, width: 1),
                  ),
                  child: Text(
                    showWord ? word : '?',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color:
                          showWord
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.grey,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 48),

            if (isReading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Memorize the synonym...',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: answerController,
                      focusNode: focusNode,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            isDark
                                ? Colors.grey[900]!.withOpacity(0.2)
                                : Colors.grey[100],
                        hintText: 'Type synonym here...',
                        hintStyle: GoogleFonts.outfit(fontSize: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: themeProvider.primaryColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => submitAnswer(provider),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      IconButton.filled(
                        onPressed:
                            provider.eyeButtonUses > 0
                                ? () => provider.useEyeButton()
                                : null,
                        icon: const Icon(Icons.remove_red_eye),
                        tooltip: 'Reveal Words (-5 pts)',
                      ),
                      Text(
                        '${provider.eyeButtonUses}/5',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: provider.remainingRoundTime / 10,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  provider.remainingRoundTime < 4
                      ? Colors.red
                      : themeProvider.primaryColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                'Time: ${provider.remainingRoundTime}s',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget wRFXGameSetupSection(
    BuildContext context,
    WordReflexProvider provider,
    ThemeProvider themeProvider,
  ) {
    final isDark = themeProvider.isDarkMode;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.grey[900]!.withOpacity(0.95)
                  : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.bolt,
              size: 64,
              color: themeProvider.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Select Duration',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children:
                  provider.timeOptions.map((time) {
                    final isSelected = provider.selectedGameTime == time;
                    return ChoiceChip(
                      label: Text('${time}s'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) provider.setSelectedTime(time);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      selectedColor: themeProvider.primaryColor,
                      labelStyle: GoogleFonts.outfit(
                        color:
                            isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => provider.startGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'START GAME',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (provider.history.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Recent Best Score: ${provider.history.first.score}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget wRFXGameResultOverlay(
    BuildContext context,
    WordReflexProvider provider,
    ThemeProvider themeProvider,
  ) {
    final isDark = themeProvider.isDarkMode;
    confettiController.play();
    final totalQuestion = provider.correctAnswers + provider.wrongAnswers;
    final screenWidth = MediaQuery.of(context).size.width;
    final score = provider.score;

    String getPerformanceRating() {
      final percentage = (provider.correctAnswers / totalQuestion) * 100;
      if (percentage >= 90) return 'EXCELLENT!';
      if (percentage >= 70) return 'GREAT JOB!';
      if (percentage >= 50) return 'GOOD WORK!';
      return 'KEEP PRACTICING!';
    }

    final performanceRating = getPerformanceRating();

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth > 800 ? 20 : 16,
                vertical: 24,
              ),
              constraints: BoxConstraints(
                maxWidth: screenWidth > 800 ? 500 : 380,
                minWidth: 280,
              ),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          performanceRating,
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth > 600 ? 22 : 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Game Complete',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth > 600 ? 14 : 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SCORE',
                              style: GoogleFonts.outfit(
                                fontSize: screenWidth > 600 ? 11 : 10,
                                fontWeight: FontWeight.w700,
                                color:
                                    isDark
                                        ? Colors.white.withOpacity(0.9)
                                        : Colors.black.withOpacity(0.9),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "$score",
                              style: GoogleFonts.outfit(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black,
                                height: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            SizedBox(
                              width:
                                  screenWidth > 500
                                      ? null
                                      : (screenWidth - 72) / 2,
                              child: wRFXGameStatCard(
                                context: context,
                                title: 'Correct',
                                value: provider.correctAnswers.toString(),
                                icon: Icons.check_circle,
                                color: Colors.green,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(
                              width:
                                  screenWidth > 500
                                      ? null
                                      : (screenWidth - 72) / 2,
                              child: wRFXGameStatCard(
                                context: context,
                                title: 'Wrong',
                                value: provider.wrongAnswers.toString(),
                                icon: Icons.close,
                                color: Colors.red,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(
                              width:
                                  screenWidth > 500
                                      ? null
                                      : (screenWidth - 72) / 2,
                              child: wRFXGameStatCard(
                                context: context,
                                title: 'Streaks',
                                value: provider.streak.toString(),
                                icon: Icons.local_fire_department,
                                color: Colors.orange,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(
                              width:
                                  screenWidth > 500
                                      ? null
                                      : (screenWidth - 72) / 2,
                              child: wRFXGameStatCard(
                                context: context,
                                title: 'Total',
                                value: totalQuestion.toString(),
                                icon: Icons.format_list_numbered,
                                color: Colors.blue,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: themeProvider.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: themeProvider.primaryColor,
                                    width: 0.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.trending_up,
                                  color: themeProvider.primaryColor,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Accuracy',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isDark
                                                ? Colors.grey[300]
                                                : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${totalQuestion > 0 ? ((provider.correctAnswers / totalQuestion) * 100).toStringAsFixed(1) : 0}%',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 80,
                                height: 6,
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor:
                                      totalQuestion > 0
                                          ? (provider.correctAnswers /
                                              totalQuestion)
                                          : 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green,
                                          Colors.lightGreen,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isDark
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () {
                                      answerController.clear();
                                      provider.resetToSetup();
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.home,
                                            color:
                                                isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'MENU',
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  isDark
                                                      ? Colors.grey[300]
                                                      : Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: themeProvider.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeProvider.primaryColor
                                          .withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () {
                                      provider.startGame();
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.replay,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'PLAY AGAIN',
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (screenWidth > 500)
                          TextButton.icon(
                            onPressed: () {
                              if (provider.history.isNotEmpty) {
                                WordReflexShareDialog.show(
                                  context,
                                  provider.history.first,
                                  themeProvider,
                                );
                              }
                            },
                            icon: Icon(
                              Icons.share,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              size: 16,
                            ),
                            label: Text(
                              'Share Results',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Confetti
        performanceRating == "KEEP PRACTICING!"
            ? SizedBox.shrink()
            : Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors:
                    isDark
                        ? [Color(0xFFFFFFFF)]
                        : [
                          Color(0xFFD4AF37),
                          Color(0xFF0B1C2D),
                          Color(0xFFFFFFFF),
                        ],
                numberOfParticles: 14,
                maxBlastForce: 10,
                minBlastForce: 2,
              ),
            ),
      ],
    );
  }

  Widget wRFXGameStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 500;

    return Container(
      constraints: BoxConstraints(
        minWidth: isLargeScreen ? 100 : 0,
        maxWidth: isLargeScreen ? 120 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isLargeScreen ? 18 : 16),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: isLargeScreen ? 12 : 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget wordReflexInstructions(bool isDarkMode) {
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
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• A main word and 3 options will appear.\n'
            '• One of the options is a synonym for the main word.\n'
            '• Memorize the synonym before the words disappear!\n'
            '• Type the synonym correctly to score points.\n'
            '• Use the Eye button to reveal words if you forget (costs 5 points).\n',
            style: GoogleFonts.outfit(
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

class WordReflexSettingsDialog extends StatefulWidget {
  const WordReflexSettingsDialog({super.key});

  @override
  State<WordReflexSettingsDialog> createState() =>
      WordReflexSettingsDialogState();
}

class WordReflexSettingsDialogState extends State<WordReflexSettingsDialog> {
  late int readingTime;
  late int typingTime;
  late String wordLengthMode;
  late int gameDuration;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WordReflexProvider>(context, listen: false);
    readingTime = provider.readingTime;
    typingTime = provider.typingTime;
    wordLengthMode = provider.wordLengthMode;
    gameDuration = provider.selectedGameTime;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final color = themeProvider.primaryColor;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Game Settings',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              wRFXGameSectionSettingTitle("Reading Time", isDark),
              const SizedBox(height: 8),
              wRFXGameSettingSlider(
                readingTime.toDouble(),
                3,
                8,
                (val) => setState(() => readingTime = val.toInt()),
                "${readingTime}s",
                color,
                isDark,
              ),
              const SizedBox(height: 20),
              wRFXGameSectionSettingTitle("Typing Time", isDark),
              const SizedBox(height: 8),
              wRFXGameSettingSlider(
                typingTime.toDouble(),
                4,
                12,
                (val) => setState(() => typingTime = val.toInt()),
                "${typingTime}s",
                color,
                isDark,
              ),
              const SizedBox(height: 20),
              wRFXGameSectionSettingTitle("Word Length", isDark),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    ['Short', 'Medium', 'Long', 'Mix'].map((mode) {
                      final isSelected = wordLengthMode == mode;
                      return FilterChip(
                        label: Text(mode),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => wordLengthMode = mode);
                        },
                        selectedColor: color.withOpacity(0.2),
                        checkmarkColor: color,
                        labelStyle: GoogleFonts.outfit(
                          color:
                              isSelected
                                  ? color
                                  : (isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700]),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        backgroundColor:
                            isDark ? Colors.grey[800] : Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            width: 0.5,
                            color:
                                isSelected
                                    ? color
                                    : (isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              wRFXGameSectionSettingTitle("Game Duration", isDark),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      [30, 60, 120, 180, 240, 300, 400, 600].map((time) {
                        final isSelected = gameDuration == time;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('${time}s'),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => gameDuration = time);
                              }
                            },
                            selectedColor: color,
                            labelStyle: GoogleFonts.outfit(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.grey[400]
                                          : Colors.black),
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                            backgroundColor:
                                isDark ? Colors.grey[800] : Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final provider = Provider.of<WordReflexProvider>(
                      context,
                      listen: false,
                    );
                    provider.updateSettings(
                      readingTime: readingTime,
                      typingTime: typingTime,
                      wordLengthMode: wordLengthMode,
                    );
                    provider.setSelectedTime(gameDuration);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "SAVE CHANGES",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget wRFXGameSectionSettingTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget wRFXGameSettingSlider(
    double value,
    double min,
    double max,
    Function(double) onChanged,
    String label,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.2),
                thumbColor: color,
                overlayColor: color.withOpacity(0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                onChanged: onChanged,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
