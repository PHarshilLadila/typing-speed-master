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
      duration: const Duration(milliseconds: 500), // Faster animation
      vsync: this,
    );

    // Smoother scale animation
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack, // Smoother curve
      ),
    );

    // Faster opacity animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start animation safely
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    try {
      if (!_isDisposed) {
        await _controller.forward().orCancel;
      }
    } catch (e) {
      // Ignore animation errors when widget is disposed
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
        // Safe guard against invalid animation values
        final scale = _scaleAnimation.value.clamp(0.0, 1.0);
        final opacity = _opacityAnimation.value.clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 60,
              height: 60,
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

// import 'package:flutter/material.dart';

// class CharRushCharacterWidget extends StatefulWidget {
//   final String character;
//   final VoidCallback onCollected;
//   final double initialTop;
//   final double targetTop;
//   final Duration duration;

//   const CharRushCharacterWidget({
//     super.key,
//     required this.character,
//     required this.onCollected,
//     required this.initialTop,
//     required this.targetTop,
//     required this.duration,
//   });

//   @override
//   State<CharRushCharacterWidget> createState() =>
//       _CharRushCharacterWidgetState();
// }

// class _CharRushCharacterWidgetState extends State<CharRushCharacterWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _positionAnimation;
//   late Animation<double> _opacityAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(duration: widget.duration, vsync: this);

//     _positionAnimation = Tween<double>(
//       begin: widget.initialTop,
//       end: widget.targetTop,
//     ).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.linear, // Smooth linear movement
//       ),
//     );

//     _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.2, curve: Curves.easeIn), // Quick fade in
//       ),
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Positioned(
//           left: 0, // You'll need to pass the left position as well
//           top: _positionAnimation.value,
//           child: Opacity(
//             opacity: _opacityAnimation.value,
//             child: Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Colors.blueAccent, Colors.purpleAccent],
//                 ),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blueAccent.withOpacity(0.5),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//                 border: Border.all(color: Colors.white, width: 2),
//               ),
//               child: Center(
//                 child: Text(
//                   widget.character,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
