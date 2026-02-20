// utils/pdf_font_helper.dart
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

class PdfFontHelper {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  static Future<void> loadFonts() async {
    if (_regularFont != null && _boldFont != null) return;

    try {
      // Load regular font
      final regularFontData = await rootBundle.load(
        'assets/fonts/Roboto-Regular.ttf',
      );
      _regularFont = pw.Font.ttf(regularFontData);

      // Load bold font
      final boldFontData = await rootBundle.load(
        'assets/fonts/Roboto-Bold.ttf',
      );
      _boldFont = pw.Font.ttf(boldFontData);
    } catch (e) {
      debugPrint('Error loading fonts: $e');
      // Fallback to default fonts
      _regularFont = pw.Font.courier();
      _boldFont = pw.Font.courierBold();
    }
  }

  static pw.Font get regularFont => _regularFont ?? pw.Font.courier();
  static pw.Font get boldFont => _boldFont ?? pw.Font.courierBold();

  static pw.TextStyle get regularStyle =>
      pw.TextStyle(font: regularFont, fontSize: 10);

  static pw.TextStyle get boldStyle => pw.TextStyle(
    font: boldFont,
    fontSize: 10,
    fontWeight: pw.FontWeight.bold,
  );
}
