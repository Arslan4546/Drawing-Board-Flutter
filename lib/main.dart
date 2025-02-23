import 'package:drawing_board/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor:
            const Color(0xFF4A90E2), // Bright blue for app bar (light theme)
        scaffoldBackgroundColor:
            const Color(0xFFF7F9FC), // Very light grey-blue
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        iconTheme:
            const IconThemeData(color: Colors.black87), // Icons in light mode
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.white,
          textTheme: ButtonTextTheme.normal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2), // Match primary color
          titleTextStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Button text/icon color
            backgroundColor: const Color(0xFF4A90E2), // Bright blue for buttons
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A90E2)),
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF1A2526), // Deep teal (dark theme)
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep grey
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        iconTheme:
            const IconThemeData(color: Colors.white70), // Icons in dark mode
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.grey[800],
          textTheme: ButtonTextTheme.normal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A2526), // Match primary color
          titleTextStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Button text/icon color
            backgroundColor: const Color(0xFF2D4A52), // Subtle teal for buttons
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal[300]!),
          ),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}
