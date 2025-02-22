import 'package:flutter/material.dart';

class ResponsiveUtils {
  static void updateResponsiveValues(BuildContext context, Function setState) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1200;

    setState(() {
      if (isSmallScreen) {
        return {
          'toolbarWidth': screenSize.width * 0.15,
          'iconSize': 24.0,
          'bottomBarHeight': 60.0,
          'strokeWidth': 3.0,
          'spacing': 4.0,
        };
      } else if (isTablet) {
        return {
          'toolbarWidth': screenSize.width * 0.12,
          'iconSize': 28.0,
          'bottomBarHeight': 70.0,
          'strokeWidth': 4.0,
          'spacing': 6.0,
        };
      } else {
        return {
          'toolbarWidth': screenSize.width * 0.1,
          'iconSize': 32.0,
          'bottomBarHeight': 80.0,
          'strokeWidth': 5.0,
          'spacing': 8.0,
        };
      }
    });
  }

  static Map<String, double> initializeResponsiveValues() {
    return {
      'toolbarWidth': 80.0,
      'iconSize': 30.0,
      'bottomBarHeight': 80.0,
      'strokeWidth': 4.0,
      'spacing': 8.0,
    };
  }
}
