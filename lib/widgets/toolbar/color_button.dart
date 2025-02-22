import 'package:flutter/material.dart';

class ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  ColorButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
    );
  }
}
