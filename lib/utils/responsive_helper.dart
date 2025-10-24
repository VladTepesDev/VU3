import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 16.0;
    if (width < 600) return 24.0;
    return 32.0;
  }

  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final width = MediaQuery.of(context).size.width;
    if (width < 375) return baseFontSize * 0.9;
    if (width < 600) return baseFontSize;
    return baseFontSize * 1.1;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  static double getMaxContentWidth(BuildContext context) {
    return isMobile(context) ? double.infinity : 600;
  }
}
