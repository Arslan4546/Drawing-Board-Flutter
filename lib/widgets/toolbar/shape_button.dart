import 'package:flutter/material.dart';

class ShapeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ShapeButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              Colors.white, // White background for consistency in both themes
          border:
              Border.all(color: isDarkMode ? Colors.grey[600]! : Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: isDarkMode
                ? Colors.black
                : Colors.black87, // Black in dark mode, black87 in light mode
          ),
        ),
      ),
    );
  }
}
