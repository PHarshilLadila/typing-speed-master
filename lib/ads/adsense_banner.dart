import 'dart:html'
    as html; // Prefix for pure DOM manipulation elements (DivElement, ScriptElement, etc.)
import 'package:flutter/material.dart';
import 'dart:ui_web'
    as ui_web; // IMPORTANT: Fix for the platformViewRegistry deprecation
import 'package:flutter/widgets.dart'
    show HtmlElementView; // Explicitly import HtmlElementView

// This widget handles displaying a Google AdSense ad unit specifically for Flutter Web.
class AdWidgetWeb extends StatefulWidget {
  final String adSlotId;
  final String adClient;

  const AdWidgetWeb({
    super.key,
    required this.adSlotId,
    required this.adClient,
  });

  @override
  _AdWidgetWebState createState() => _AdWidgetWebState();
}

class _AdWidgetWebState extends State<AdWidgetWeb> {
  // A unique identifier for the Platform View
  late final String viewId;
  static const double adHeight = 250.0;

  @override
  void initState() {
    super.initState();
    viewId = 'ad-container-${widget.adSlotId}';

    debugPrint(
      'AD_WIDGET_DART: Initializing AdSense platform view for slot: ${widget.adSlotId}',
    );

    // 1. Create a DivElement
    final html.DivElement container =
        html.DivElement()
          // Ensure the container itself can fill the space provided by Flutter
          ..style.textAlign = 'center'
          ..style.overflow = 'hidden'
          ..style.width = '100%'
          ..style.height = '100%';

    // 2. Create the <ins> tag (The Ad Unit)
    final html.Element insElement =
        html.Element.tag('ins')
          ..id =
              'ins-${widget.adSlotId}' // Assign an ID for easier JavaScript targeting
          ..className = 'adsbygoogle'
          ..style.display = 'block'
          ..attributes['data-ad-client'] = "ca-pub-3779258307133143"
          ..attributes['data-ad-slot'] = "4355381273"
          ..attributes['data-ad-format'] = 'auto'
          ..attributes['data-full-width-responsive'] = 'true';

    // 3. Append the ins tag to the container
    container.children.add(insElement);

    // 4. Inject the JavaScript push command and logging with a DELAY.
    final html.ScriptElement scriptElement =
        html.ScriptElement()
          ..innerHtml = '''
          const adContainer = document.getElementById('ins-${widget.adSlotId}');
          
          // Wait 500ms for Flutter to finish laying out the HtmlElementView, which sets the container width.
          setTimeout(() => {
              const currentWidth = adContainer.offsetWidth;
              console.log('AD_DEBUG: Delay finished. Current width of INS element: ' + currentWidth);

              if (currentWidth === 0) {
                  console.error('AD_DEBUG: FAILED! Width is still 0. Cannot push ad for slot ${widget.adSlotId}. Try increasing the delay.');
                  return; 
              }

              console.log('AD_DEBUG: Attempting AdSense push for slot ${widget.adSlotId}...');
              
              if (window.adsbygoogle && window.adsbygoogle.push) {
                  window.adsbygoogle.push({});
                  console.log('AD_DEBUG: SUCCESS! AdSense push executed for slot ${widget.adSlotId}.');
              } else {
                  console.error('AD_DEBUG: ERROR! window.adsbygoogle object NOT found. Main script missing in web/index.html.');
              }
          }, 500); // 500ms delay to allow Flutter to apply layout constraints
        ''';

    // Append the script element to run the ad-loading logic
    container.children.add(scriptElement);

    // 5. Register the DivElement as a Platform View using the new dart:ui_web import
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => container,
    );

    debugPrint(
      'AD_WIDGET_DART: ViewFactory registered successfully for $viewId.',
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AD_WIDGET_DART: Building HtmlElementView for $viewId.');

    // 6. Use the HtmlElementView, wrapped in a Stack with a placeholder background for confirmation.
    return SizedBox(
      height:
          adHeight, // Setting a definite height here is crucial for AdSense to load
      child: Stack(
        children: [
          // This container acts as a placeholder to visually confirm the space is being rendered
          // by Flutter correctly, even if the ad fails to load.
          Container(
            color: Colors.grey[100],
            alignment: Alignment.center,
            child: const Text(
              'Ad Space (Waiting for AdSense content...)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          // The actual platform view holding the ad unit
          HtmlElementView(viewType: viewId),
        ],
      ),
    );
  }
}
