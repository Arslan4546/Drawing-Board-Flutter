import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double toolbarWidth(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (screenSize.width < 600) {
      return screenSize.width * 0.15;
    } else if (screenSize.width >= 600 && screenSize.width < 1200) {
      return screenSize.width * 0.12;
    } else {
      return screenSize.width * 0.1;
    }
  }

  static double iconSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (screenSize.width < 600) {
      return 24;
    } else if (screenSize.width >= 600 && screenSize.width < 1200) {
      return 28;
    } else {
      return 32;
    }
  }

  static double bottomBarHeight(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (screenSize.width < 600) {
      return 60;
    } else if (screenSize.width >= 600 && screenSize.width < 1200) {
      return 70;
    } else {
      return 80;
    }
  }

  static double strokeWidth(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (screenSize.width < 600) {
      return 3.0;
    } else if (screenSize.width >= 600 && screenSize.width < 1200) {
      return 4.0;
    } else {
      return 5.0;
    }
  }

  static double spacing(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (screenSize.width < 600) {
      return 4.0;
    } else if (screenSize.width >= 600 && screenSize.width < 1200) {
      return 6.0;
    } else {
      return 8.0;
    }
  }
}
