// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfessionalAnimatedBackground extends StatefulWidget {
  final Widget child;

  const ProfessionalAnimatedBackground({super.key, required this.child});

  @override
  State<ProfessionalAnimatedBackground> createState() =>
      _ProfessionalAnimatedBackgroundState();
}

class _ProfessionalAnimatedBackgroundState
    extends State<ProfessionalAnimatedBackground> {
  final List<AnimatedIconData> _icons = [];

  @override
  void initState() {
    super.initState();
    _initializeIcons();
  }

  void _initializeIcons() {
    _icons.addAll([
      AnimatedIconData(
        icon: Icons.auto_awesome,
        size: 40,
        color: Colors.blueAccent,
        position: const Alignment(0.85, -0.75),
      ),
      AnimatedIconData(
        faIcon: FontAwesomeIcons.bolt,
        size: 32,
        color: Colors.amberAccent,
        position: const Alignment(-0.85, -0.8),
      ),
      AnimatedIconData(
        icon: Icons.emoji_events,
        size: 36,
        color: Colors.redAccent,
        position: const Alignment(-0.75, 0.65),
      ),
      AnimatedIconData(
        icon: Icons.speed,
        size: 44,
        color: Colors.purpleAccent,
        position: const Alignment(0.78, 0.35),
      ),
      AnimatedIconData(
        faIcon: FontAwesomeIcons.trophy,
        size: 38,
        color: Colors.greenAccent,
        position: const Alignment(-0.35, 0.85),
      ),
      AnimatedIconData(
        icon: Icons.star,
        size: 52,
        color: Colors.cyanAccent,
        position: const Alignment(0.15, 0.15),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          IgnorePointer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Stack(
                children: [
                  ..._icons.map((iconData) {
                    return _ProfessionalStaticIcon(iconData: iconData);
                  }),
                ],
              ),
            ),
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

  AnimatedIconData({
    this.icon,
    this.faIcon,
    required this.size,
    required this.color,
    required this.position,
  });
}

enum AnimationType { fadeAndFloat, pulseAndRotate }

class ProfessionalAnimatedIcon extends StatelessWidget {
  final AnimatedIconData iconData;

  const ProfessionalAnimatedIcon({super.key, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Align(alignment: iconData.position, child: _buildIcon());
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

class _ProfessionalStaticIcon extends StatelessWidget {
  final AnimatedIconData iconData;

  const _ProfessionalStaticIcon({required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Align(alignment: iconData.position, child: _buildIcon());
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
