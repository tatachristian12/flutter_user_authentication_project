import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<_PasswordFormState> _passwordFormKey =
      GlobalKey<_PasswordFormState>();

  // Controllers for handling login data
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Dummy controller required by the shared PasswordForm signature
  final TextEditingController _dummyConfirmController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _dummyConfirmController.dispose();
    super.dispose();
  }

  // API Call to Django JWT/Token Auth endpoint
  Future<void> _loginUser() async {
    final isEmailValid = _loginFormKey.currentState?.validate() ?? false;
    final isPasswordValid =
        _passwordFormKey.currentState?.validateForm() ?? false;

    if (!isEmailValid || !isPasswordValid) return;

    setState(() {
      _isLoading = true;
    });

    // Replace with your Django login URL endpoint (e.g., /api/v1/token/ or /api/v1/login/)
    final Uri url = Uri.parse('http://10.0.2.2:8000/api/v1/login/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
  final Map<String, dynamic> responseData = jsonDecode(response.body);
  
  // 🛡️ Fix: Use the null-coalescing operator to fall back to an empty string
  final String accessToken = responseData['access'] ?? '';
  final String refreshToken = responseData['refresh'] ?? '';

  // Double-check: If the keys were missing, don't try to log in
  if (accessToken.isEmpty) {
    print("🚨 Key mismatch! Django response keys were: ${responseData.keys.toList()}");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed: Token missing from server response.'), backgroundColor: Colors.red),
      );
    }
    return; 
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', accessToken);
  await prefs.setString('refresh_token', refreshToken);
  await prefs.setBool('isLoggedIn', true);

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome Back!'), backgroundColor: Colors.green),
    );
    Navigator.pushReplacementNamed(context, '/settings');
  }
} else {
        // ─── ADD THIS PRINT LINE TO SEE THE REAL ERROR ───
        print("❌ Django Login Rejection Body: ${response.body}");
        print("❌ Django Status Code: ${response.statusCode}");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid Credentials: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
  // Clean, warning-free catch block
  final String errorMessage = e.toString();
  print("🚨 Caught Network Error Details: $errorMessage");
  // ... Keep snackbar logic the same
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100.0,
        backgroundColor: const Color.fromARGB(255, 244, 241, 241),
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Center(child: Text('ConnectNow', style: TextStyle(fontSize: 25))),
            SizedBox(height: 4),
            Center(
              child: Text(
                'Welcome Back', // Updated header for contextual clarity
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 2),
            Center(
              child: Text(
                'Join us to connect with your world',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // --- EMAIL INPUT ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'name@example.com',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your email'
                        : null,
                  ),
                ),

                // --- REUSABLE PASSWORD FORM FIELD ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: PasswordForm(
                    key: _passwordFormKey,
                    passwordController: _passwordController,
                    confirmPasswordController: _dummyConfirmController,
                    isLogin:
                        true, // 👈 Tells the password widget to hide confirm password
                  ),
                ),

                // --- LOGIN BUTTON ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _loginUser,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('LOGIN'),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                const Center(child: Text("Don't have an account?")),

                // --- SWITCH TO REGISTER BUTTON ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      // Changed to Outlined for improved visual contrast
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepPurple),
                        foregroundColor: Colors.deepPurple,
                      ),
                      onPressed: () {
                        // Navigates directly back to the Registration Screen
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('REGISTER'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── UPDATED MULTI-MODE PASSWORD FORM ───
class PasswordForm extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLogin; // 👈 Controls configuration behavior

  const PasswordForm({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    this.isLogin = false, // Defaults to registration mode if excluded
  });

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter a password';
              if (value.length < 6)
                return 'Password must be at least 6 characters';
              return null;
            },
          ),

          // Conditionally hide the structural confirm layout elements during login state
          if (!widget.isLogin) ...[
            const SizedBox(height: 30.0),
            TextFormField(
              controller: widget.confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_clock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please confirm your password';
                if (value != widget.passwordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
}
