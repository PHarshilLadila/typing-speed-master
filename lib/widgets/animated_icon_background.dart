// ignore_for_file: deprecated_member_use

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
  final List<AnimatedIconData> _icons = [];
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _initializeIcons();
    if (widget.enableParticles) {
      _initializeParticles();
    }
  }

  void _initializeIcons() {
    _icons.addAll([
      AnimatedIconData(
        icon: Icons.auto_awesome,
        size: 40,
        color: Colors.blueAccent,
        position: const Alignment(0.85, -0.75),
        animationDelay: 0.0,
        animationType: AnimationType.fadeAndFloat,
      ),
      AnimatedIconData(
        faIcon: FontAwesomeIcons.bolt,
        size: 32,
        color: Colors.amberAccent,
        position: const Alignment(-0.85, -0.8),
        animationDelay: 1.2,
        animationType: AnimationType.pulseAndRotate,
      ),
      AnimatedIconData(
        icon: Icons.emoji_events,
        size: 36,
        color: Colors.redAccent,
        position: const Alignment(-0.75, 0.65),
        animationDelay: 2.4,
        animationType: AnimationType.fadeAndFloat,
      ),
      AnimatedIconData(
        icon: Icons.speed,
        size: 44,
        color: Colors.purpleAccent,
        position: const Alignment(0.78, 0.35),
        animationDelay: 3.6,
        animationType: AnimationType.pulseAndRotate,
      ),
      AnimatedIconData(
        faIcon: FontAwesomeIcons.trophy,
        size: 38,
        color: Colors.greenAccent,
        position: const Alignment(-0.35, 0.85),
        animationDelay: 4.8,
        animationType: AnimationType.fadeAndFloat,
      ),
      AnimatedIconData(
        icon: Icons.star,
        size: 52,
        color: Colors.cyanAccent,
        position: const Alignment(0.15, 0.15),
        animationDelay: 6.0,
        animationType: AnimationType.pulseAndRotate,
      ),
    ]);
  }

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
                      ..._icons.map((iconData) {
                        return _ProfessionalAnimatedIcon(
                          iconData: iconData,
                          controller: _controller,
                        );
                      }),
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

  double _clampOpacity(double opacity) {
    return opacity.clamp(0.0, 1.0);
  }
}

class _ProfessionalAnimatedIcon extends StatelessWidget {
  final AnimatedIconData iconData;
  final AnimationController controller;

  const _ProfessionalAnimatedIcon({
    required this.iconData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final time = controller.value;
    final adjustedTime = (time + iconData.animationDelay / 25) % 1.0;

    final baseOpacity = 0.44 + 0.03 * sin(adjustedTime * 2 * pi);

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
    final opacity = baseOpacity + 0.09 * sin(time * 5 * pi);

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
}
