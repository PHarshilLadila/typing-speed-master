// ignore_for_file: unnecessary_import, deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart' show HtmlElementView;

class AdWidgetWeb extends StatefulWidget {
  final String adSlotId;
  final String adClient;
  final double adHeight;

  const AdWidgetWeb({
    super.key,
    required this.adSlotId,
    required this.adClient,
    this.adHeight = 250.0,
  });

  @override
  AdWidgetWebState createState() => AdWidgetWebState();
}

class AdWidgetWebState extends State<AdWidgetWeb> {
  late final String viewId;
  bool adLoaded = false;

  @override
  void initState() {
    super.initState();
    viewId = 'ad-container-${widget.adSlotId}';
    initializeAd();
  }

  void initializeAd() {
    debugPrint(
      'AD_WIDGET_DART: Initializing AdSense for slot: ${widget.adSlotId}',
    );

    // Create container
    final html.DivElement container =
        html.DivElement()
          ..id = viewId
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.textAlign = 'center'
          ..style.overflow = 'hidden';

    // Create ad element
    final html.Element adElement =
        html.Element.tag('ins')
          ..className = 'adsbygoogle'
          ..style.display = 'block'
          ..attributes['data-ad-client'] = widget.adClient
          ..attributes['data-ad-slot'] = widget.adSlotId
          ..attributes['data-ad-format'] = 'auto'
          ..attributes['data-full-width-responsive'] = 'true';

    container.children.add(adElement);

    // Create script with unique variable names and better error handling
    final html.ScriptElement scriptElement =
        html.ScriptElement()
          ..innerHtml = '''
        (function() {
          try {
            var adElement_${widget.adSlotId.replaceAll('-', '_')} = document.getElementById('$viewId').firstChild;
            
            if (!adElement_${widget.adSlotId.replaceAll('-', '_')}) {
              console.error('AD_DEBUG: Ad element not found for slot ${widget.adSlotId}');
              return;
            }
            
            setTimeout(function() {
              var currentWidth = adElement_${widget.adSlotId.replaceAll('-', '_')}.offsetWidth;
              console.log('AD_DEBUG: Slot ${widget.adSlotId} - Width: ' + currentWidth + 'px');
              
              if (currentWidth === 0) {
                console.warn('AD_DEBUG: Slot ${widget.adSlotId} - Width is 0, retrying in 1s');
                setTimeout(function() {
                  if (window.adsbygoogle && window.adsbygoogle.push) {
                    (window.adsbygoogle = window.adsbygoogle || []).push({});
                  }
                }, 1000);
                return;
              }
              
              if (window.adsbygoogle && window.adsbygoogle.push) {
                (window.adsbygoogle = window.adsbygoogle || []).push({});
                console.log('AD_DEBUG: SUCCESS! Ad pushed for slot ${widget.adSlotId}');
              } else {
                console.error('AD_DEBUG: AdSense not loaded for slot ${widget.adSlotId}');
              }
            }, 800);
          } catch (error) {
            console.error('AD_DEBUG: Error in ad script for slot ${widget.adSlotId}:', error);
          }
        })();
      ''';

    container.children.add(scriptElement);

    // Register the view
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => container,
    );

    debugPrint('AD_WIDGET_DART: ViewFactory registered for $viewId');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.adHeight,
      child: Stack(
        children: [
          // Placeholder background
          Container(
            color: Colors.grey[100],
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ad_units, size: 40, color: Colors.grey[400]),
                SizedBox(height: 8),
                Text(
                  'Ad Loading...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          // Ad container
          HtmlElementView(
            viewType: viewId,
            onPlatformViewCreated: (id) {
              debugPrint('AD_WIDGET_DART: Platform view created with id: $id');
            },
          ),
        ],
      ),
    );
  }
}
