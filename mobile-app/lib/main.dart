import 'package:flutter/material.dart';
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primarySwatch: Colors.cyan,
      ),
      home: const SplashScreen(),
    );
  }
}