import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isAuthChecked = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    await Future.delayed(const Duration(milliseconds: 100));

    // Read the access token string
    final String? accessToken = prefs.getString('access_token');
    final bool loggedInFlag = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      // The user is truly authenticated only if the flag is true AND the token string exists
      _isLoggedIn = loggedInFlag && (accessToken != null && accessToken.isNotEmpty);
      _isAuthChecked = true;
    });
  } catch (e) {
    setState(() {
      _isLoggedIn = false;
      _isAuthChecked = true;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    // 1. While reading storage files, show a clean, native loading frame
    if (!_isAuthChecked) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    // 2. Once checked, swap out the view inline without disrupting root navigation state paths
    return _isLoggedIn ? const SettingsScreen() : const LoginScreen();
  }
}