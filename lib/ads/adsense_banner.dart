// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';

class AdSenseBanner extends StatefulWidget {
  final String adSlot;
  final double width;
  final double height;

  const AdSenseBanner({
    super.key,
    required this.adSlot,
    this.width = double.infinity,
    this.height = 250,
  });

  @override
  State<AdSenseBanner> createState() => _AdSenseBannerState();
}

class _AdSenseBannerState extends State<AdSenseBanner> {
  final String _viewType = 'adsense-${DateTime.now().millisecondsSinceEpoch}';
  bool _adFailed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _registerAdView();
    _checkAdLoad();
  }

  void _registerAdView() {
    // Create ad container div
    final adContainer =
        html.DivElement()
          ..style.width = '100%'
          ..style.height = '${widget.height}px'
          ..style.display = 'flex'
          ..style.alignItems = 'center'
          ..style.justifyContent = 'center';

    // Create ins element for AdSense
    final insElement = html.Element.html('''
      <ins class="adsbygoogle"
           style="display:block; width:100%; height:100%;"
           data-ad-client="ca-pub-3779258307133143"
           data-ad-slot="${widget.adSlot}"
           data-ad-format="auto"
           data-full-width-responsive="true"></ins>
    ''');

    adContainer.append(insElement);

    // Register the view factory
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      // Push ad after a short delay to ensure DOM is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          // Use js_util to access window.adsbygoogle
          if (js_util.hasProperty(html.window, 'adsbygoogle')) {
            final adsbygoogle = js_util.getProperty(html.window, 'adsbygoogle');

            // Push empty object to trigger ad loading
            js_util.callMethod(adsbygoogle, 'push', [js_util.jsify({})]);

            // Mark as loaded after initialization
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            });
          } else {
            debugPrint('⚠️ AdSense script not loaded');
            _handleAdError();
          }
        } catch (e) {
          debugPrint('❌ AdSense error: $e');
          _handleAdError();
        }
      });

      return adContainer;
    });
  }

  void _checkAdLoad() {
    // Timeout if ad doesn't load within 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (_isLoading && mounted) {
        _handleAdError();
      }
    });
  }

  void _handleAdError() {
    if (mounted) {
      setState(() {
        _adFailed = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_adFailed) {
      return _buildErrorWidget();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Ad view
          HtmlElementView(viewType: _viewType),

          // Loading overlay
          if (_isLoading) _buildLoadingWidget(),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Loading Advertisement...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
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
          Icon(Icons.info_outline, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Advertisement Space',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Alternative: Responsive Ad Widget
class ResponsiveAdSenseBanner extends StatelessWidget {
  final String adSlot;

  const ResponsiveAdSenseBanner({super.key, required this.adSlot});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust height based on width
        double height = 250;
        if (constraints.maxWidth < 600) {
          height = 100; // Mobile banner
        } else if (constraints.maxWidth < 900) {
          height = 200; // Tablet
        }

        return AdSenseBanner(
          adSlot: adSlot,
          width: constraints.maxWidth,
          height: height,
        );
      },
    );
  }
}

// Helper widget to check if AdSense is loaded (for debugging)
class AdSenseDebugger extends StatelessWidget {
  const AdSenseDebugger({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if AdSense script is loaded
    final bool isLoaded = js_util.hasProperty(html.window, 'adsbygoogle');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isLoaded ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isLoaded ? '✅ AdSense Script Loaded' : '❌ AdSense Script Not Found',
        style: TextStyle(
          fontSize: 12,
          color: isLoaded ? Colors.green[900] : Colors.red[900],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
