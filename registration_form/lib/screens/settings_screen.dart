import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 Needed to clear tokens

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  // ─── LOGOUT HANDLER FUNCTION ───
  Future<void> _handleLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // 1. Wipe out your Django JWT tokens and login state completely
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.setBool('isLoggedIn', false); 

    // 2. Safely jump back to the login wall and clear navigation history
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 244, 241, 241),
        automaticallyImplyLeading: false, // Prevents an accidental back button showing up
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (bool value) => setState(() => _notificationsEnabled = value),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (bool value) => setState(() => _darkMode = value),
          ),
          
          const Divider(), // Visual break line separating preferences from actions

          // ─── ADDED LOG OUT ACTION TILE ───
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Log Out',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Securely sign out of your account'),
            onTap: _handleLogout, // Triggers the safe token wipe out
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 213, 213, 213),
        items: const [
          BottomNavigationBarItem(label: "", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "", icon: Icon(Icons.people)),
          BottomNavigationBarItem(label: "", icon: Icon(Icons.settings)),
          BottomNavigationBarItem(label: "", icon: Icon(Icons.update)),
          BottomNavigationBarItem(label: "Profile", icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}