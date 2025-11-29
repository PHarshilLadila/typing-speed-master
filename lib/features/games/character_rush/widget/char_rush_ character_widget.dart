// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';

class CharRushCharacterWidget extends StatefulWidget {
  final String character;
  final VoidCallback onCollected;

  const CharRushCharacterWidget({
    super.key,
    required this.character,
    required this.onCollected,
  });

  @override
  State<CharRushCharacterWidget> createState() =>
      _CharRushCharacterWidgetState();
}

class _CharRushCharacterWidgetState extends State<CharRushCharacterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    try {
      if (!_isDisposed) {
        await _controller.forward().orCancel;
      }
    } catch (e) {
      if (!_isDisposed) rethrow;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _scaleAnimation.value.clamp(0.0, 1.0);
        final opacity = _opacityAnimation.value.clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blueAccent, Colors.purpleAccent],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  widget.character,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
