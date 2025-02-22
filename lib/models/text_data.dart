import 'package:flutter/material.dart';

class TextData {
  String text;
  Offset position;
  Color color;
  bool isDragging;
  bool isSelected;

  TextData({
    required this.text,
    required this.position,
    required this.color,
    this.isDragging = false,
    this.isSelected = false,
  });
}
