import 'package:flutter/material.dart';
import 'screens/drawing_board_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF2C3E50),
        scaffoldBackgroundColor: Color(0xFFF5F6FA),
      ),
      home: DrawingBoardScreen(),
    );
  }
}
