// ignore_for_file: dead_code, deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:typing_speed_master/features/games/game_word_reflex/model/word_reflex_model.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/utils/pdf_font_helper.dart';

class WordReflexShareDialog {
  static void show(
    BuildContext context,
    WordReflexResult game,
    ThemeProvider themeProvider,
  ) {
    final totalQuestions = game.correctAnswers + game.wrongAnswers;
    final accuracy =
        totalQuestions > 0
            ? ((game.correctAnswers / totalQuestions) * 100).toStringAsFixed(1)
            : '0.0';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isGenerating = false;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                decoration: BoxDecoration(
                  color:
                      themeProvider.isDarkMode
                          ? const Color(0xFF1A1A1A)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Elegant Header with Gradient
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeProvider.primaryColor,
                                themeProvider.primaryColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.stars_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Game Victory!',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'Share your impressive results',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.2,
                                  ),
                                  hoverColor: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Grid Stats Section
                              GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1,
                                children: [
                                  _buildProfessionalStatCard(
                                    'Score',
                                    game.score.toString(),
                                    Icons.emoji_events_outlined,
                                    Colors.orange,
                                    themeProvider,
                                  ),
                                  _buildProfessionalStatCard(
                                    'Streak',
                                    game.streak.toString(),
                                    Icons.whatshot_rounded,
                                    Colors.redAccent,
                                    themeProvider,
                                  ),
                                  _buildProfessionalStatCard(
                                    'Accuracy',
                                    '$accuracy%',
                                    Icons.track_changes_rounded,
                                    Colors.blueAccent,
                                    themeProvider,
                                  ),
                                  _buildProfessionalStatCard(
                                    'Correct',
                                    game.correctAnswers.toString(),
                                    Icons.check_circle_outline_rounded,
                                    Colors.green,
                                    themeProvider,
                                  ),
                                  _buildProfessionalStatCard(
                                    'Wrong',
                                    game.wrongAnswers.toString(),
                                    Icons.cancel_outlined,
                                    Colors.red,
                                    themeProvider,
                                  ),
                                  _buildProfessionalStatCard(
                                    'Time',
                                    '${game.gameDuration}s',
                                    Icons.timer_outlined,
                                    Colors.teal,
                                    themeProvider,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Export Options Label
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: themeProvider.primaryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'EXPORT RESULTS',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color:
                                          themeProvider.isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[700],
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Professional Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      onPressed:
                                          isGenerating
                                              ? null
                                              : () async {
                                                setState(
                                                  () => isGenerating = true,
                                                );
                                                try {
                                                  final bytes =
                                                      await generateWordReflexPdfBytes(
                                                        game,
                                                      );
                                                  if (bytes != null) {
                                                    if (kIsWeb) {
                                                      await Share.shareXFiles(
                                                        [
                                                          XFile.fromData(
                                                            bytes,
                                                            mimeType:
                                                                'application/pdf',
                                                            name:
                                                                'word_reflex_result.pdf',
                                                          ),
                                                        ],
                                                        text:
                                                            'Check out my Word Reflex score! 🎮\nScore: ${game.score}',
                                                      );
                                                    } else {
                                                      final output =
                                                          await getTemporaryDirectory();
                                                      final file = File(
                                                        '${output.path}/word_reflex_result_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                                      );
                                                      await file.writeAsBytes(
                                                        bytes,
                                                      );
                                                      await Share.shareXFiles(
                                                        [XFile(file.path)],
                                                        text:
                                                            'Check out my Word Reflex score! 🎮\nScore: ${game.score}',
                                                      );
                                                    }
                                                  }
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error: $e',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                } finally {
                                                  setState(
                                                    () => isGenerating = false,
                                                  );
                                                }
                                              },
                                      icon: Icons.share_rounded,
                                      label: 'Share',
                                      primary: true,
                                      isGenerating: isGenerating,
                                      themeProvider: themeProvider,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionButton(
                                      onPressed:
                                          isGenerating
                                              ? null
                                              : () async {
                                                setState(
                                                  () => isGenerating = true,
                                                );
                                                try {
                                                  final bytes =
                                                      await generateWordReflexPdfBytes(
                                                        game,
                                                      );
                                                  if (bytes != null) {
                                                    if (kIsWeb) {
                                                      final blob = html.Blob([
                                                        bytes,
                                                      ], 'application/pdf');
                                                      final url = html
                                                          .Url.createObjectUrlFromBlob(
                                                        blob,
                                                      );
                                                      html.AnchorElement(
                                                          href: url,
                                                        )
                                                        ..setAttribute(
                                                          "download",
                                                          "word_reflex_result.pdf",
                                                        )
                                                        ..click();
                                                      html.Url.revokeObjectUrl(
                                                        url,
                                                      );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'PDF Downloading...',
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    } else {
                                                      final output =
                                                          await getTemporaryDirectory();
                                                      final file = File(
                                                        '${output.path}/word_reflex_result_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                                      );
                                                      await file.writeAsBytes(
                                                        bytes,
                                                      );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'PDF saved: ${file.path}',
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error: $e',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                } finally {
                                                  setState(
                                                    () => isGenerating = false,
                                                  );
                                                }
                                              },
                                      icon: Icons.file_download_rounded,
                                      label: 'Download',
                                      primary: false,
                                      isGenerating: isGenerating,
                                      themeProvider: themeProvider,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Full Width Preview Button
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed:
                                      isGenerating
                                          ? null
                                          : () async {
                                            setState(() => isGenerating = true);
                                            try {
                                              final bytes =
                                                  await generateWordReflexPdfBytes(
                                                    game,
                                                  );
                                              if (bytes != null) {
                                                await Printing.layoutPdf(
                                                  onLayout: (_) => bytes,
                                                );
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            } finally {
                                              setState(
                                                () => isGenerating = false,
                                              );
                                            }
                                          },
                                  icon: const Icon(
                                    Icons.visibility_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Quick Preview Result'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    foregroundColor:
                                        themeProvider.isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
            );
          },
        );
      },
    );
  }

  static Widget _buildProfessionalStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeProvider themeProvider,
  ) {
    final isDark = themeProvider.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required bool primary,
    required bool isGenerating,
    required ThemeProvider themeProvider,
  }) {
    if (primary) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeProvider.primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: themeProvider.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          icon:
              isGenerating
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Icon(icon, size: 20),
          label: Text(
            isGenerating ? 'Processing...' : label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: themeProvider.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: themeProvider.primaryColor, width: 2),
        ),
        icon:
            isGenerating
                ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: themeProvider.primaryColor,
                  ),
                )
                : Icon(icon, size: 20),
        label: Text(
          isGenerating ? 'Wait...' : label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      );
    }
  }

  static Future<Uint8List?> generateWordReflexPdfBytes(
    WordReflexResult game,
  ) async {
    final totalQuestions = game.correctAnswers + game.wrongAnswers;
    final accuracy =
        totalQuestions > 0
            ? ((game.correctAnswers / totalQuestions) * 100).toStringAsFixed(1)
            : '0.0';
    final date = DateFormat('dd MMM yyyy, hh:mm a').format(game.timestamp);

    await PdfFontHelper.loadFonts();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: PdfFontHelper.regularFont,
          bold: PdfFontHelper.boldFont,
        ),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Word Reflex Game Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    date,
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              padding: const pw.EdgeInsets.all(12),
              child: pw.Column(
                children: [
                  pw.Text(
                    'GAME SUMMARY',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          'SCORE: ',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '${game.score}',
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.GridView(
                    crossAxisCount: 3,
                    childAspectRatio: 0.5,
                    children: [
                      _buildPdfStatBox(
                        'Correct',
                        '${game.correctAnswers}',
                        PdfColors.green,
                      ),
                      _buildPdfStatBox(
                        'Wrong',
                        '${game.wrongAnswers}',
                        PdfColors.red,
                      ),
                      _buildPdfStatBox(
                        'Streak',
                        '${game.streak}',
                        PdfColors.orange,
                      ),
                      _buildPdfStatBox(
                        'Accuracy',
                        '$accuracy%',
                        PdfColors.blue,
                      ),
                      _buildPdfStatBox(
                        'Total Rounds',
                        '${game.totalRounds}',
                        PdfColors.purple,
                      ),
                      _buildPdfStatBox(
                        'Duration',
                        '${game.gameDuration}s',
                        PdfColors.teal,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Performance Accuracy',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        height: 20,
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey),
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Stack(
                          children: [
                            pw.Container(
                              width:
                                  (totalQuestions > 0
                                      ? (game.correctAnswers / totalQuestions)
                                      : 0) *
                                  500,
                              decoration: pw.BoxDecoration(
                                gradient: const pw.LinearGradient(
                                  colors: [
                                    PdfColors.green,
                                    PdfColors.lightGreen,
                                  ],
                                ),
                                borderRadius: pw.BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('0%'),
                          pw.Text('$accuracy%'),
                          pw.Text('100%'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            if (game.roundResults.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Word History (${game.roundResults.length} words)',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                border: null,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
                headers: ['Word', 'Your Answer', 'Correct Answer', 'Status'],
                data:
                    game.roundResults.map((round) {
                      return [
                        round.mainWord.toUpperCase(),
                        round.userAnswer,
                        round.correctAnswer,
                        round.isCorrect ? 'Correct' : 'Wrong',
                      ];
                    }).toList(),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.center,
                },
                cellDecoration: (rowIndex, columnIndex, _) {
                  if (rowIndex == 0) return const pw.BoxDecoration();
                  if (rowIndex - 1 >= game.roundResults.length) {
                    return const pw.BoxDecoration();
                  }
                  final round = game.roundResults[rowIndex - 1];
                  if (columnIndex == 3) {
                    return pw.BoxDecoration(
                      color:
                          round.isCorrect ? PdfColors.green50 : PdfColors.red50,
                    );
                  }
                  return const pw.BoxDecoration();
                },
              ),
            ],
            pw.SizedBox(height: 40),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Generated by Typing Speed Master App',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '© ${DateTime.now().year} - All Rights Reserved',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildPdfStatBox(
    String title,
    String value,
    PdfColor color,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(4),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 0.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }
}
