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
    // Register the view factory
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      // Create ad container div
      final adContainer =
          html.DivElement()
            ..style.width = '100%'
            ..style.height = '${widget.height}px'
            ..style.display = 'block'
            ..style.overflow = 'hidden';

      // Create ins element AFTER registration to avoid sanitizer
      // This is the key fix - we create and modify the element after it's registered
      Future.delayed(const Duration(milliseconds: 50), () {
        try {
          // Create ins element using createElement (bypasses sanitizer)
          final insElement = html.document.createElement('ins') as html.Element;

          // Set className (this works)
          insElement.className = 'adsbygoogle';

          // Set attributes using setAttribute (bypasses sanitizer)
          insElement.setAttribute(
            'style',
            'display:block;width:100%;height:100%',
          );
          insElement.setAttribute('data-ad-client', 'ca-pub-3779258307133143');
          insElement.setAttribute('data-ad-slot', widget.adSlot);
          insElement.setAttribute('data-ad-format', 'auto');
          insElement.setAttribute('data-full-width-responsive', 'true');

          // Append to container
          adContainer.append(insElement);

          debugPrint('✅ AdSense element created with attributes');

          // Push ad request after another delay
          // Future.delayed(const Duration(milliseconds: 100), () {
          //   _pushAdRequest();
          // });
        } catch (e) {
          debugPrint('❌ Error creating AdSense element: $e');
          _handleAdError();
        }
      });

      return adContainer;
    });
  }

  // void _pushAdRequest() {
  //   try {
  //     // Check if AdSense script is loaded
  //     if (js_util.hasProperty(html.window, 'adsbygoogle')) {
  //       final adsbygoogle = js_util.getProperty(html.window, 'adsbygoogle');

  //       // Push empty object to trigger ad loading
  //       js_util.callMethod(adsbygoogle, 'push', [js_util.jsify({})]);

  //       debugPrint('✅ AdSense request pushed');

  //       // Mark as loaded after initialization
  //       Future.delayed(const Duration(seconds: 3), () {
  //         if (mounted) {
  //           setState(() {
  //             _isLoading = false;
  //           });
  //         }
  //       });
  //     } else {
  //       debugPrint('⚠️ AdSense script not loaded on window');
  //       // Try again after a delay
  //       Future.delayed(const Duration(seconds: 1), () {
  //         if (mounted && _isLoading) {
  //           _pushAdRequest();
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('❌ AdSense push error: $e');
  //     _handleAdError();
  //   }
  // }

  void _checkAdLoad() {
    // Timeout if ad doesn't load within 15 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (_isLoading && mounted) {
        debugPrint('⏱️ Ad load timeout');
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
    // Check if running on localhost
    final isLocalhost =
        Uri.base.host.contains('localhost') ||
        Uri.base.host.contains('127.0.0.1');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLocalhost ? Icons.computer : Icons.info_outline,
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            isLocalhost ? 'Ads appear after deployment' : 'Advertisement Space',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isLocalhost) ...[
            const SizedBox(height: 4),
            Text(
              'Deploy to production to see ads',
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
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
          height:
          200; // Tablet
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
class AdSenseDebugger extends StatefulWidget {
  const AdSenseDebugger({super.key});

  @override
  State<AdSenseDebugger> createState() => _AdSenseDebuggerState();
}

class _AdSenseDebuggerState extends State<AdSenseDebugger> {
  bool? _isLoaded;

  @override
  void initState() {
    super.initState();
    _checkAdSense();
  }

  void _checkAdSense() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoaded = js_util.hasProperty(html.window, 'adsbygoogle');
        });

        if (_isLoaded == true) {
          final adsbygoogle = js_util.getProperty(html.window, 'adsbygoogle');
          debugPrint('✅ AdSense loaded: $adsbygoogle');
        } else {
          debugPrint('❌ AdSense not found, retrying...');
          // Retry
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _checkAdSense();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '🔄 Checking AdSense...',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange[900],
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _isLoaded! ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _isLoaded! ? '✅ AdSense Script Loaded' : '❌ AdSense Script Not Found',
        style: TextStyle(
          fontSize: 12,
          color: _isLoaded! ? Colors.green[900] : Colors.red[900],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
