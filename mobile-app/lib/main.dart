import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const EventCraftApp());
}

class EventCraftApp extends StatelessWidget {
  const EventCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventCraft AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        canvasColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE2E8F0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB), // Royal Blue
          secondary: Color(0xFF0284C7), // Sky Blue
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF0F172A), // Deep Slate
          error: Color(0xFFEF4444),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}