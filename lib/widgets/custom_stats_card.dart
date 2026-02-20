// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomStatsCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final bool isDarkMode;
  final double width;
  final bool isProfile;
  final bool isExtraButton;
  final void Function()? onTapExtraWidget;
  final String extraWidgetToolTip;

  const CustomStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    required this.isDarkMode,
    this.width = double.infinity,
    this.isProfile = false,
    this.isExtraButton = false,
    this.onTapExtraWidget,
    this.extraWidgetToolTip = '',
  });

  @override
  State<CustomStatsCard> createState() => _CustomStatsCardState();
}

class _CustomStatsCardState extends State<CustomStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovering) {
    if (isHovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode ? widget.color : widget.color;
    final titleColor = widget.isDarkMode ? Colors.grey[300] : Colors.grey[800];
    final valueColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final unitColor = widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: backgroundColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              widget.isProfile
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(
                        widget.isDarkMode ? 0.2 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.value,
                        style: TextStyle(
                          fontSize: widget.isProfile ? 20 : 28,
                          fontWeight: FontWeight.bold,
                          color: valueColor,
                        ),
                      ),
                      const TextSpan(text: ' '), // spacing
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            widget.unit,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: unitColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isExtraButton == true)
                  Tooltip(
                    message: widget.extraWidgetToolTip,
                    triggerMode: TooltipTriggerMode.longPress,
                    child: GestureDetector(
                      onTap: widget.onTapExtraWidget ?? () {},
                      child: Icon(Icons.autorenew),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
