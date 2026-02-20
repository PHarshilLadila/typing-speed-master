import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/game_word_reflex/provider/word_reflex_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/features/games/game_word_reflex/widgets/word_reflex_share_dialog.dart';
import 'package:typing_speed_master/widgets/custom_history_not_found_widget.dart';

class GameWordReflexHistoryView extends StatefulWidget {
  const GameWordReflexHistoryView({super.key});

  @override
  State<GameWordReflexHistoryView> createState() =>
      GameWordReflexHistoryViewState();
}

class GameWordReflexHistoryViewState extends State<GameWordReflexHistoryView> {
  String resultFilter = 'All'; // All, Recent, High Score

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<WordReflexProvider>(context);
    final isDark = themeProvider.isDarkMode;
    // final isMobile = MediaQuery.of(context).size.width < 768;

    List<dynamic> history = List.from(provider.history);

    // Apply Filter
    if (resultFilter == 'High Score') {
      history.sort((a, b) => b.score.compareTo(a.score));
    } else if (resultFilter == 'Recent') {
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return Flex(
                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment:
                      isMobile
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                  mainAxisAlignment:
                      isMobile
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Game History',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),

                    if (isMobile) const SizedBox(height: 12),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        wRFXGameHistoryFilterDropdown(isDark, themeProvider),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => provider.resetToSetup(),
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: themeProvider.primaryColor.withOpacity(
                                0.2,
                              ),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ),
                        // IconButton(
                        //   onPressed: () => provider.resetToSetup(),
                        //   icon: const Icon(Icons.close),
                        //   color: isDark ? Colors.grey[400] : Colors.grey[600],
                        // ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),

          provider.isLoadingHistory
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              )
              : history.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: CustomHistoryNotFoundWidget(),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final game = history[index];
                  return wRFXGameHistoryItem(
                    game,
                    index,
                    isDark,
                    themeProvider,
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget wRFXGameHistoryFilterDropdown(
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: resultFilter,
          icon: Icon(
            Icons.filter_list,
            size: 18,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          items:
              ['All', 'Recent', 'High Score'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() => resultFilter = newValue);
            }
          },
        ),
      ),
    );
  }

  Widget wRFXGameHistoryItem(
    dynamic game,
    int index,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    // Format timestamp
    final date = game.timestamp;
    final dateStr = DateFormat('hh:mm a, d MMM yyyy').format(date);

    // Calculate accuracy
    final total = game.correctAnswers + game.wrongAnswers;
    final accuracy =
        total > 0
            ? ((game.correctAnswers / total) * 100).toStringAsFixed(1)
            : '0.0';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? Colors.grey[900] : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[100]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),

          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '#${index + 1}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              'Score: ${game.score}',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              dateStr,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: 12,
                height: 1.8,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    WordReflexShareDialog.show(context, game, themeProvider);
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment:
                        MediaQuery.of(context).size.width < 600
                            ? WrapAlignment.spaceBetween
                            : WrapAlignment.spaceEvenly,
                    children: [
                      wRFXGameStatDetail(
                        'Total Rounds',
                        '${game.totalRounds}',
                        Colors.purple,
                        isDark,
                        Icons.layers,
                      ),
                      wRFXGameStatDetail(
                        'Correct',
                        '${game.correctAnswers}',
                        Color(0xFF4CAF50),
                        isDark,
                        Icons.check_circle_rounded,
                      ),
                      wRFXGameStatDetail(
                        'Wrong',
                        '${game.wrongAnswers}',
                        Colors.red,
                        isDark,
                        Icons.cancel_rounded,
                      ),

                      wRFXGameStatDetail(
                        'Streak',
                        '${game.streak}',
                        Colors.orange,
                        isDark,
                        Icons.local_fire_department,
                      ),
                      wRFXGameStatDetail(
                        'Accuracy',
                        '$accuracy%',
                        Color(0xFF64B5F6),
                        isDark,
                        CupertinoIcons.scope,
                      ),
                      wRFXGameStatDetail(
                        'Time',
                        '${game.gameDuration}s',
                        Colors.lime,
                        isDark,
                        Icons.timer,
                      ),
                    ],
                  ),
                ),
              ),
              if (game.roundResults.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Word History',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '${game.roundResults.length} Words',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...game.roundResults.map<Widget>(
                        (round) => wRFXGameRoundResultItem(
                          round,
                          isDark,
                          themeProvider,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget wRFXGameStatDetail(
    String label,
    String value,
    Color color,
    bool isDark,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.05), color.withOpacity(0.02)],
        ),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: isDark ? Colors.white : Colors.grey[900],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget wRFXGameRoundResultItem(
    dynamic round,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]!.withOpacity(0.3) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              round.isCorrect
                  ? Colors.transparent
                  : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  round.isCorrect
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              round.isCorrect ? Icons.check : Icons.close,
              size: 16,
              color: round.isCorrect ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      round.mainWord.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_right_alt,
                      size: 16,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        round.userAnswer,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: round.isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!round.isCorrect) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Correct: ',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        round.correctAnswer,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
