import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class AdSenseBanner extends StatefulWidget {
  final double width;
  final double height;

  const AdSenseBanner({
    super.key,
    this.width = double.infinity,
    this.height = 250,
  });

  @override
  State<AdSenseBanner> createState() => _AdSenseBannerState();
}

class _AdSenseBannerState extends State<AdSenseBanner> {
  bool _adFailed = false;
  bool _adLoaded = false;

  String get _htmlContent => '''
    <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-3779258307133143"
     crossorigin="anonymous"></script>
<ins class="adsbygoogle"
     style="display:block"
     data-ad-client="ca-pub-3779258307133143"
     data-ad-slot="4355381273"
     data-ad-format="auto"
     data-full-width-responsive="true"></ins>
<script>
     (adsbygoogle = window.adsbygoogle || []).push({});
</script>
  ''';

  @override
  void initState() {
    super.initState();
    // Check if ad loads within 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (!_adLoaded && mounted) {
        setState(() {
          _adFailed = true;
          _adLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_adFailed) {
      return _buildErrorWidget();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _buildHtmlAd(),
    );
  }

  Widget _buildHtmlAd() {
    return HtmlWidget(
      _htmlContent,
      onLoadingBuilder:
          (context, element, loadingProgress) => _buildPlaceholder(),
      onErrorBuilder: (context, element, error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _adFailed = true;
            });
          }
        });
        return _buildErrorWidget();
      },
    );
  }
}

Widget _buildPlaceholder() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[200],
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.ad_units, size: 32, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Loading Ad...',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    ),
  );
}

Widget _buildErrorWidget() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[100],
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 32, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Ad not available',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    ),
  );
}
