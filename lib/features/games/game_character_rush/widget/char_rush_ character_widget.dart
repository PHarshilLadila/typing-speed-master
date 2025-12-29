// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';

class GameCharacterAndWordWidget extends StatefulWidget {
  final bool isWordMasterGame;
  final String characterOrWords;
  final VoidCallback onCollected;

  const GameCharacterAndWordWidget({
    super.key,
    required this.characterOrWords,
    required this.onCollected,
    this.isWordMasterGame = false,
  });

  @override
  State<GameCharacterAndWordWidget> createState() =>
      _GameCharacterAndWordWidgetState();
}

class _GameCharacterAndWordWidgetState extends State<GameCharacterAndWordWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<double> opacityAnimation;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    startAnimation();
  }

  Future<void> startAnimation() async {
    try {
      if (!isDisposed) {
        await controller.forward().orCancel;
      }
    } catch (e) {
      if (!isDisposed) rethrow;
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = scaleAnimation.value.clamp(0.0, 1.0);
        final opacity = opacityAnimation.value.clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child:
                widget.isWordMasterGame == true
                    ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blueAccent, Colors.purpleAccent],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 0.5),
                      ),
                      child: Center(
                        child: Text(
                          widget.characterOrWords,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    : Container(
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
                          widget.characterOrWords,
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
