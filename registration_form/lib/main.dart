import 'package:flutter/material.dart';
import 'package:registration_form/screens/login_screen.dart';
// ─── IMPORT YOUR NEW FILES HERE ───
import 'screens/auth_gate.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(), 
        '/register': (context) => const HomeScreen(),        // Found via import
        '/settings': (context) => const SettingsScreen(), // Found via import
      },
    );
  }
}