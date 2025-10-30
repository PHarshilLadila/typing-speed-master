import 'package:flutter/material.dart';

class AnimatedProgressIndicator extends StatefulWidget {
  final double value;
  final double subtitleFontSize;
  final Color textColor;
  final Color subtitleTextColor;
  final Color progressBackgroundColor;

  const AnimatedProgressIndicator({
    super.key,
    required this.value,
    required this.subtitleFontSize,
    required this.textColor,
    required this.subtitleTextColor,
    required this.progressBackgroundColor,
  });

  @override
  State<AnimatedProgressIndicator> createState() =>
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool hovering) {
    setState(() => _isHovered = hovering);
    if (hovering) {
      _controller.forward(from: 0);
    } else {
      _controller.animateTo(
        widget.value,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: AnimatedBuilder(
              animation: _animation,
              builder:
                  (context, _) => CircularProgressIndicator(
                    value: _isHovered ? _animation.value : widget.value,
                    strokeWidth: 5,
                    backgroundColor: widget.progressBackgroundColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.amber,
                    ),
                  ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(widget.value * 100).toInt()}',
                style: TextStyle(
                  fontSize: widget.subtitleFontSize + 1,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
              ),
              Text(
                'WPM',
                style: TextStyle(
                  fontSize: widget.subtitleFontSize - 7,
                  fontWeight: FontWeight.w500,
                  color: widget.subtitleTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
