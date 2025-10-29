import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget smallMobile;
  final Widget bigMobile;
  final Widget smallTablet;
  final Widget bigTablet;
  final Widget smallDesktop;
  final Widget bigDesktop;

  const ResponsiveLayout({
    super.key,
    required this.smallMobile,
    required this.bigMobile,
    required this.smallTablet,
    required this.bigTablet,
    required this.smallDesktop,
    required this.bigDesktop,
  });

  static const double smallMobileMax = 400;
  static const double bigMobileMax = 600;
  static const double smallTabletMax = 900;
  static const double bigTabletMax = 1200;
  static const double smallDesktopMax = 1600;

  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= smallMobileMax;

  static bool isBigMobile(BuildContext context) =>
      MediaQuery.of(context).size.width > smallMobileMax &&
      MediaQuery.of(context).size.width <= bigMobileMax;

  static bool isSmallTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > bigMobileMax &&
      MediaQuery.of(context).size.width <= smallTabletMax;

  static bool isBigTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > smallTabletMax &&
      MediaQuery.of(context).size.width <= bigTabletMax;

  static bool isSmallDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > bigTabletMax &&
      MediaQuery.of(context).size.width <= smallDesktopMax;

  static bool isBigDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > smallDesktopMax;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width > smallDesktopMax) {
          return bigDesktop;
        } else if (width > bigTabletMax) {
          return smallDesktop;
        } else if (width > smallTabletMax) {
          return bigTablet;
        } else if (width > bigMobileMax) {
          return smallTablet;
        } else if (width > smallMobileMax) {
          return bigMobile;
        } else {
          return smallMobile;
        }
      },
    );
  }
}
