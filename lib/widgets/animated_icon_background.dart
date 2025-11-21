// // import 'package:flutter/material.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// // class AnimatedIconsBackground extends StatefulWidget {
// //   final Widget child;

// //   const AnimatedIconsBackground({super.key, required this.child});

// //   @override
// //   State<AnimatedIconsBackground> createState() =>
// //       _AnimatedIconsBackgroundState();
// // }

// // class _AnimatedIconsBackgroundState extends State<AnimatedIconsBackground>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _controller;
// //   final List<BackgroundIcon> _icons = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = AnimationController(
// //       duration: const Duration(seconds: 12),
// //       vsync: this,
// //     )..repeat(reverse: true);

// //     _initializeIcons();
// //   }

// //   void _initializeIcons() {
// //     _icons.addAll([
// //       BackgroundIcon(
// //         icon: Icons.speed,
// //         size: 30,
// //         color: Colors.blue.withOpacity(0.6),
// //         glowColor: Colors.blue,
// //         position: const Alignment(0.9, -0.7),
// //       ),
// //       BackgroundIcon(
// //         icon: FontAwesomeIcons.bolt,
// //         size: 25,
// //         color: Colors.yellow.withOpacity(0.6),
// //         glowColor: Colors.yellow,
// //         position: const Alignment(-0.8, -0.8),
// //       ),
// //       BackgroundIcon(
// //         icon: Icons.flag,
// //         size: 32,
// //         color: Colors.red.withOpacity(0.6),
// //         glowColor: Colors.red,
// //         position: const Alignment(-0.7, 0.6),
// //       ),

// //       // Medium icons
// //       // BackgroundIcon(
// //       //   icon: Icons.assignment,
// //       //   size: 26,
// //       //   color: Colors.green.withOpacity(0.5),
// //       //   glowColor: Colors.green,
// //       //   position: const Alignment(0.1, -0.9),
// //       //   delay: 4.5,
// //       // ),
// //       BackgroundIcon(
// //         icon: Icons.emoji_events,
// //         size: 30,
// //         color: Colors.orange.withOpacity(0.5),
// //         glowColor: Colors.orange,
// //         position: const Alignment(0.8, 0.3),
// //       ),
// //       BackgroundIcon(
// //         icon: Icons.speed,
// //         size: 40,
// //         color: Colors.purple.withOpacity(0.5),
// //         glowColor: Colors.purple,
// //         position: const Alignment(-0.3, 0.9),
// //       ),

// //       // Large icons
// //       BackgroundIcon(
// //         icon: FontAwesomeIcons.bolt,
// //         size: 70,
// //         color: Colors.cyan.withOpacity(0.4),
// //         glowColor: Colors.cyan,
// //         position: const Alignment(0.1, 0.1),
// //       ),
// //       BackgroundIcon(
// //         icon: Icons.emoji_events,
// //         size: 65,
// //         color: Colors.pink.withOpacity(0.4),
// //         glowColor: Colors.pink,
// //         position: const Alignment(-0.5, -0.2),
// //       ),
// //     ]);
// //   }

// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Stack(
// //       children: [
// //         AnimatedBuilder(
// //           animation: _controller,
// //           builder: (context, child) {
// //             return Stack(
// //               children:
// //                   _icons.map((bgIcon) {
// //                     return _AnimatedIconWidget(
// //                       icon: bgIcon,
// //                       animation: _controller,
// //                     );
// //                   }).toList(),
// //             );
// //           },
// //         ),

// //         widget.child,
// //       ],
// //     );
// //   }
// // }

// // class BackgroundIcon {
// //   final IconData? icon;
// //   final IconData? faIcon;
// //   final double size;
// //   final Color color;
// //   final Color glowColor;
// //   final Alignment position;
// //   final double delay;

// //   BackgroundIcon({
// //     this.icon,
// //     this.faIcon,
// //     required this.size,
// //     required this.color,
// //     required this.glowColor,
// //     required this.position,
// //     this.delay = 15,
// //   }) : assert(
// //          icon != null || faIcon != null,
// //          'Either icon or faIcon must be provided',
// //        );
// // }

// // class _AnimatedIconWidget extends StatelessWidget {
// //   final BackgroundIcon icon;
// //   final Animation<double> animation;

// //   const _AnimatedIconWidget({required this.icon, required this.animation});

// //   @override
// //   Widget build(BuildContext context) {
// //     // Calculate safe interval values that don't exceed 1.0
// //     final double start = (icon.delay % 12) / 12;
// //     final double end = start + 0.8; // 40% of the animation cycle

// //     // Ensure end doesn't exceed 1.0
// //     final double safeEnd = end <= 1.0 ? end : 1.0;

// //     final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(
// //         parent: animation,
// //         curve: Interval(start, safeEnd, curve: Curves.easeInOut),
// //       ),
// //     );

// //     return AnimatedBuilder(
// //       animation: delayedAnimation,
// //       builder: (context, child) {
// //         return Align(
// //           alignment: icon.position,
// //           child: Transform.scale(
// //             scale: 1 + (delayedAnimation.value * 0.1),
// //             child: Container(
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 // boxShadow: [
// //                 //   BoxShadow(
// //                 //     color: icon.glowColor.withOpacity(
// //                 //       delayedAnimation.value * 0.2,
// //                 //     ),
// //                 //     blurRadius: 20.0 * delayedAnimation.value,
// //                 //     spreadRadius: 2.0 * delayedAnimation.value,
// //                 //   ),
// //                 // ],
// //               ),
// //               child:
// //                   icon.faIcon != null
// //                       ? FaIcon(
// //                         icon.faIcon!,
// //                         size: icon.size,
// //                         color: icon.color.withOpacity(
// //                           delayedAnimation.value * 0.9,
// //                         ),
// //                       )
// //                       : Icon(
// //                         icon.icon,
// //                         size: icon.size,
// //                         color: icon.color.withOpacity(
// //                           delayedAnimation.value * 0.9,
// //                         ),
// //                       ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class ProfessionalAnimatedBackground extends StatefulWidget {
//   final Widget child;
//   final bool enableParticles;

//   const ProfessionalAnimatedBackground({
//     super.key,
//     required this.child,
//     this.enableParticles = true,
//   });

//   @override
//   State<ProfessionalAnimatedBackground> createState() =>
//       _ProfessionalAnimatedBackgroundState();
// }

// class _ProfessionalAnimatedBackgroundState
//     extends State<ProfessionalAnimatedBackground>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   final List<AnimatedIconData> _icons = [];
//   final List<Particle> _particles = [];

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 25),
//       vsync: this,
//     )..repeat();

//     _initializeIcons();
//     if (widget.enableParticles) {
//       _initializeParticles();
//     }
//   }

//   void _initializeIcons() {
//     _icons.addAll([
//       AnimatedIconData(
//         icon: Icons.auto_awesome,
//         size: 40,
//         color: Colors.blueAccent,
//         position: const Alignment(0.85, -0.75),
//         animationDelay: 0.0,
//         animationType: AnimationType.fadeAndFloat,
//       ),
//       AnimatedIconData(
//         faIcon: FontAwesomeIcons.bolt,
//         size: 32,
//         color: Colors.amberAccent,
//         position: const Alignment(-0.85, -0.8),
//         animationDelay: 1.2,
//         animationType: AnimationType.pulseAndRotate,
//       ),
//       AnimatedIconData(
//         icon: Icons.emoji_events,
//         size: 36,
//         color: Colors.redAccent,
//         position: const Alignment(-0.75, 0.65),
//         animationDelay: 2.4,
//         animationType: AnimationType.fadeAndFloat,
//       ),
//       AnimatedIconData(
//         icon: Icons.speed,
//         size: 44,
//         color: Colors.purpleAccent,
//         position: const Alignment(0.78, 0.35),
//         animationDelay: 3.6,
//         animationType: AnimationType.pulseAndRotate,
//       ),
//       AnimatedIconData(
//         faIcon: FontAwesomeIcons.trophy,
//         size: 38,
//         color: Colors.greenAccent,
//         position: const Alignment(-0.35, 0.85),
//         animationDelay: 4.8,
//         animationType: AnimationType.fadeAndFloat,
//       ),
//       AnimatedIconData(
//         icon: Icons.star,
//         size: 52,
//         color: Colors.cyanAccent,
//         position: const Alignment(0.15, 0.15),
//         animationDelay: 6.0,
//         animationType: AnimationType.pulseAndRotate,
//       ),
//     ]);
//   }

//   void _initializeParticles() {
//     for (int i = 0; i < 15; i++) {
//       _particles.add(
//         Particle(
//           id: i,
//           size: 2 + (i % 3).toDouble(),
//           color:
//               [
//                 Colors.blueAccent.withOpacity(0.3),
//                 Colors.purpleAccent.withOpacity(0.3),
//                 Colors.amberAccent.withOpacity(0.3),
//               ][i % 3],
//           position: Alignment(-1.0 + (i * 0.13) % 2.0, -1.0 + (i * 0.08) % 2.0),
//           speed: 0.5 + (i % 3) * 0.2,
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return SizedBox.expand(
//       child: Stack(
//         children: [
//           AnimatedBuilder(
//             animation: _controller,
//             builder: (context, child) {
//               return IgnorePointer(
//                 child: Container(
//                   width: double.infinity,
//                   height: double.infinity,
//                   decoration: BoxDecoration(color: Colors.transparent),
//                   child: Stack(
//                     children: [
//                       // Floating particles
//                       if (widget.enableParticles)
//                         ..._particles.map((particle) {
//                           return _ParticleWidget(
//                             particle: particle,
//                             controller: _controller,
//                           );
//                         }),

//                       // Animated icons
//                       ..._icons.map((iconData) {
//                         return _ProfessionalAnimatedIcon(
//                           iconData: iconData,
//                           controller: _controller,
//                         );
//                       }),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),

//           // Main content
//           widget.child,
//         ],
//       ),
//     );
//   }
// }

// class AnimatedIconData {
//   final IconData? icon;
//   final IconData? faIcon;
//   final double size;
//   final Color color;
//   final Alignment position;
//   final double animationDelay;
//   final AnimationType animationType;

//   AnimatedIconData({
//     this.icon,
//     this.faIcon,
//     required this.size,
//     required this.color,
//     required this.position,
//     required this.animationDelay,
//     required this.animationType,
//   });
// }

// enum AnimationType { fadeAndFloat, pulseAndRotate }

// class Particle {
//   final int id;
//   final double size;
//   final Color color;
//   final Alignment position;
//   final double speed;

//   Particle({
//     required this.id,
//     required this.size,
//     required this.color,
//     required this.position,
//     required this.speed,
//   });
// }

// class _ProfessionalAnimatedIcon extends StatelessWidget {
//   final AnimatedIconData iconData;
//   final AnimationController controller;

//   const _ProfessionalAnimatedIcon({
//     required this.iconData,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final time = controller.value;
//     final adjustedTime = (time + iconData.animationDelay / 25) % 1.0;

//     // Base opacity with gentle pulsing
//     final baseOpacity = 0.44 + 0.03 * sin(adjustedTime * 2 * pi);

//     switch (iconData.animationType) {
//       case AnimationType.fadeAndFloat:
//         return _buildFadeAndFloatIcon(adjustedTime, baseOpacity);
//       case AnimationType.pulseAndRotate:
//         return _buildPulseAndRotateIcon(adjustedTime, baseOpacity);
//     }
//   }

//   Widget _buildFadeAndFloatIcon(double time, double baseOpacity) {
//     final verticalOffset = 20 * sin(time * 2 * pi);
//     final horizontalOffset = 10 * cos(time * 1.5 * pi);
//     final scale = 0.9 + 0.1 * sin(time * pi);

//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         return Align(
//           alignment: iconData.position,
//           child: Transform.translate(
//             offset: Offset(horizontalOffset, verticalOffset),
//             child: Transform.scale(
//               scale: scale,
//               child: Opacity(opacity: baseOpacity, child: _buildIcon()),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPulseAndRotateIcon(double time, double baseOpacity) {
//     final rotation = 5 * sin(time * 2 * pi);
//     final scale = 0.85 + 0.15 * sin(time * pi);
//     final opacity = baseOpacity + 0.09 * sin(time * 5 * pi);

//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         return Align(
//           alignment: iconData.position,
//           child: Transform.rotate(
//             angle: rotation * pi / 180,
//             child: Transform.scale(
//               scale: scale,
//               child: Opacity(opacity: opacity, child: _buildIcon()),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildIcon() {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: iconData.color.withOpacity(0.15),
//             blurRadius: 20,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child:
//           iconData.faIcon != null
//               ? FaIcon(
//                 iconData.faIcon!,
//                 size: iconData.size,
//                 color: iconData.color.withOpacity(0.25),
//               )
//               : Icon(
//                 iconData.icon,
//                 size: iconData.size,
//                 color: iconData.color.withOpacity(0.25),
//               ),
//     );
//   }
// }

// class _ParticleWidget extends StatelessWidget {
//   final Particle particle;
//   final AnimationController controller;

//   const _ParticleWidget({required this.particle, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final time = controller.value;
//     final particleTime = (time * particle.speed + particle.id * 0.1) % 1.0;

//     final verticalOffset = 100 * sin(particleTime * 2 * pi);
//     final horizontalOffset = 50 * cos(particleTime * 1.5 * pi);
//     final opacity = 0.3 + 0.2 * sin(particleTime * 3 * pi);

// ignore_for_file: deprecated_member_use

//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         return Align(
//           alignment: Alignment(
//             particle.position.x + horizontalOffset / 500,
//             particle.position.y + verticalOffset / 500,
//           ),
//           child: Transform.rotate(
//             angle: particleTime * 2 * pi,
//             child: Opacity(
//               opacity: opacity,
//               child: Container(
//                 width: particle.size,
//                 height: particle.size,
//                 decoration: BoxDecoration(
//                   color: particle.color,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfessionalAnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool enableParticles;
  final int particleCount;

  const ProfessionalAnimatedBackground({
    super.key,
    required this.child,
    this.enableParticles = true,
    this.particleCount = 35,
  });

  @override
  State<ProfessionalAnimatedBackground> createState() =>
      _ProfessionalAnimatedBackgroundState();
}

class _ProfessionalAnimatedBackgroundState
    extends State<ProfessionalAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // final List<AnimatedIconData> _icons = [];
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    // _initializeIcons();
    if (widget.enableParticles) {
      _initializeParticles();
    }
  }

  // void _initializeIcons() {
  //   _icons.addAll([
  //     AnimatedIconData(
  //       icon: Icons.auto_awesome,
  //       size: 40,
  //       color: Colors.blueAccent,
  //       position: const Alignment(0.85, -0.75),
  //       animationDelay: 0.0,
  //       animationType: AnimationType.fadeAndFloat,
  //     ),
  //     AnimatedIconData(
  //       faIcon: FontAwesomeIcons.bolt,
  //       size: 32,
  //       color: Colors.amberAccent,
  //       position: const Alignment(-0.85, -0.8),
  //       animationDelay: 1.2,
  //       animationType: AnimationType.pulseAndRotate,
  //     ),
  //     AnimatedIconData(
  //       icon: Icons.emoji_events,
  //       size: 36,
  //       color: Colors.redAccent,
  //       position: const Alignment(-0.75, 0.65),
  //       animationDelay: 2.4,
  //       animationType: AnimationType.fadeAndFloat,
  //     ),
  //     AnimatedIconData(
  //       icon: Icons.speed,
  //       size: 44,
  //       color: Colors.purpleAccent,
  //       position: const Alignment(0.78, 0.35),
  //       animationDelay: 3.6,
  //       animationType: AnimationType.pulseAndRotate,
  //     ),
  //     AnimatedIconData(
  //       faIcon: FontAwesomeIcons.trophy,
  //       size: 38,
  //       color: Colors.greenAccent,
  //       position: const Alignment(-0.35, 0.85),
  //       animationDelay: 4.8,
  //       animationType: AnimationType.fadeAndFloat,
  //     ),
  //     AnimatedIconData(
  //       icon: Icons.star,
  //       size: 52,
  //       color: Colors.cyanAccent,
  //       position: const Alignment(0.15, 0.15),
  //       animationDelay: 6.0,
  //       animationType: AnimationType.pulseAndRotate,
  //     ),
  //   ]);
  // }

  void _initializeParticles() {
    final random = Random();

    final particleColors = [
      Colors.blueAccent.withOpacity(0.4),
      Colors.purpleAccent.withOpacity(0.4),
      Colors.amberAccent.withOpacity(0.4),
      Colors.cyanAccent.withOpacity(0.4),
      Colors.greenAccent.withOpacity(0.4),
      Colors.pinkAccent.withOpacity(0.4),
      Colors.orangeAccent.withOpacity(0.4),
      Colors.tealAccent.withOpacity(0.4),
    ];

    for (int i = 0; i < widget.particleCount; i++) {
      final size = 1.5 + random.nextDouble() * 4.0;
      final x = -1.0 + random.nextDouble() * 2.0;
      final y = -1.0 + random.nextDouble() * 2.0;
      final speed = 0.3 + random.nextDouble() * 0.8;

      _particles.add(
        Particle(
          id: i,
          size: size,
          color: particleColors[i % particleColors.length],
          position: Alignment(x, y),
          speed: speed,
          movementType:
              ParticleMovementType.values[random.nextInt(
                ParticleMovementType.values.length,
              )],
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return IgnorePointer(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Stack(
                    children: [
                      if (widget.enableParticles)
                        ..._particles.map((particle) {
                          return _ParticleWidget(
                            particle: particle,
                            controller: _controller,
                          );
                        }),
                      // ..._icons.map((iconData) {
                      //   return _ProfessionalAnimatedIcon(
                      //     iconData: iconData,
                      //     controller: _controller,
                      //   );
                      // }),
                    ],
                  ),
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class AnimatedIconData {
  final IconData? icon;
  final IconData? faIcon;
  final double size;
  final Color color;
  final Alignment position;
  final double animationDelay;
  final AnimationType animationType;

  AnimatedIconData({
    this.icon,
    this.faIcon,
    required this.size,
    required this.color,
    required this.position,
    required this.animationDelay,
    required this.animationType,
  });
}

enum AnimationType { fadeAndFloat, pulseAndRotate }

enum ParticleMovementType { circular, horizontal, vertical, diagonal, wave }

class Particle {
  final int id;
  final double size;
  final Color color;
  final Alignment position;
  final double speed;
  final ParticleMovementType movementType;

  Particle({
    required this.id,
    required this.size,
    required this.color,
    required this.position,
    required this.speed,
    this.movementType = ParticleMovementType.circular,
  });
}

class ProfessionalAnimatedIcon extends StatelessWidget {
  final AnimatedIconData iconData;
  final AnimationController controller;

  const ProfessionalAnimatedIcon({
    super.key,
    required this.iconData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final time = controller.value;
    final adjustedTime = (time + iconData.animationDelay / 25) % 1.0;

    // FIXED: Ensure opacity stays within bounds
    final baseOpacity = _clampOpacity(0.44 + 0.03 * sin(adjustedTime * 2 * pi));

    switch (iconData.animationType) {
      case AnimationType.fadeAndFloat:
        return _buildFadeAndFloatIcon(adjustedTime, baseOpacity);
      case AnimationType.pulseAndRotate:
        return _buildPulseAndRotateIcon(adjustedTime, baseOpacity);
    }
  }

  Widget _buildFadeAndFloatIcon(double time, double baseOpacity) {
    final verticalOffset = 20 * sin(time * 2 * pi);
    final horizontalOffset = 10 * cos(time * 1.5 * pi);
    final scale = 0.9 + 0.1 * sin(time * pi);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Align(
          alignment: iconData.position,
          child: Transform.translate(
            offset: Offset(horizontalOffset, verticalOffset),
            child: Transform.scale(
              scale: scale,
              child: Opacity(opacity: baseOpacity, child: _buildIcon()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseAndRotateIcon(double time, double baseOpacity) {
    final rotation = 5 * sin(time * 2 * pi);
    final scale = 0.85 + 0.15 * sin(time * pi);
    // FIXED: Ensure opacity stays within bounds
    final opacity = _clampOpacity(baseOpacity + 0.09 * sin(time * 5 * pi));

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Align(
          alignment: iconData.position,
          child: Transform.rotate(
            angle: rotation * pi / 180,
            child: Transform.scale(
              scale: scale,
              child: Opacity(opacity: opacity, child: _buildIcon()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: iconData.color.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child:
          iconData.faIcon != null
              ? FaIcon(
                iconData.faIcon!,
                size: iconData.size,
                color: iconData.color.withOpacity(0.25),
              )
              : Icon(
                iconData.icon,
                size: iconData.size,
                color: iconData.color.withOpacity(0.25),
              ),
    );
  }

  // Helper method to clamp opacity between 0.0 and 1.0
  double _clampOpacity(double opacity) {
    return opacity.clamp(0.0, 1.0);
  }
}

class _ParticleWidget extends StatelessWidget {
  final Particle particle;
  final AnimationController controller;

  const _ParticleWidget({required this.particle, required this.controller});

  @override
  Widget build(BuildContext context) {
    final time = controller.value;
    final particleTime = (time * particle.speed + particle.id * 0.05) % 1.0;

    double horizontalOffset = 0;
    double verticalOffset = 0;
    double rotation = 0;

    switch (particle.movementType) {
      case ParticleMovementType.circular:
        horizontalOffset = 40 * cos(particleTime * 2 * pi);
        verticalOffset = 40 * sin(particleTime * 2 * pi);
        rotation = particleTime * 2 * pi;
        break;
      case ParticleMovementType.horizontal:
        horizontalOffset = 60 * sin(particleTime * pi);
        verticalOffset = 0;
        rotation = particleTime * pi;
        break;
      case ParticleMovementType.vertical:
        horizontalOffset = 0;
        verticalOffset = 60 * cos(particleTime * pi);
        rotation = particleTime * pi;
        break;
      case ParticleMovementType.diagonal:
        horizontalOffset = 40 * sin(particleTime * pi);
        verticalOffset = 40 * cos(particleTime * pi);
        rotation = particleTime * 1.5 * pi;
        break;
      case ParticleMovementType.wave:
        horizontalOffset = 30 * sin(particleTime * 3 * pi);
        verticalOffset = 20 * cos(particleTime * 2 * pi);
        rotation = particleTime * pi;
        break;
    }

    // FIXED: Ensure opacity stays within bounds
    final opacity = _clampOpacity(0.2 + 0.3 * sin(particleTime * 4 * pi));

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment(
            particle.position.x + horizontalOffset / 500,
            particle.position.y + verticalOffset / 500,
          ),
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  color: particle.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: particle.color.withOpacity(0.5),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to clamp opacity between 0.0 and 1.0
  double _clampOpacity(double opacity) {
    return opacity.clamp(0.0, 1.0);
  }
}
