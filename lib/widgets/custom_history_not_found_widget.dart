import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class CustomHistoryNotFoundWidget extends StatelessWidget {
  final String title;
  const CustomHistoryNotFoundWidget({
    super.key,
    this.title = 'No history yet!',
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.network(
            "https://static.vecteezy.com/system/resources/thumbnails/007/104/553/small/search-no-result-not-found-concept-illustration-flat-design-eps10-modern-graphic-element-for-landing-page-empty-state-ui-infographic-icon-vector.jpg",
            height: isMobile ? 140 : 100,
            width: isMobile ? 140 : 100,
            fit: BoxFit.cover,
            errorBuilder: (
              BuildContext context,
              Object exception,
              StackTrace? stackTrace,
            ) {
              return Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  Text(
                    "Image not loaded, something went wrong",
                    style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
                  ),
                ],
              );
            },
            loadingBuilder: (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  color: themeProvider.primaryColor,
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
