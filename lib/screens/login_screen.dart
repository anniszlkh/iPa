import 'dart:convert';
import 'package:attend_track/screens/employee_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attend_track/screens/admin_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  final String loginUrl = "https://attendtrack.skynue.com/api/login.php";

  Future<void> loginUser() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      showMessage("Username and password are required");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": _usernameController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        String role = data['role'];
        String username = data['username'];

        if (role == 'admin') {
          // admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminHomeScreen(username: username),
            ),
          );
        } else {
          // employee
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EmployeeHomeScreen(username: username),
            ),
          );
        }
      }
      else {
        showMessage(data['message'] ?? "Login failed");
      }
    } catch (e) {
      showMessage("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Login',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'SFPro'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // App Title
              const Text(
                'AttendTrack',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),

              // Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(fontFamily: 'SFPro'),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(fontFamily: 'SFPro'),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading ? null : loginUser,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Register Link
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  'Create an account',
                  style: TextStyle(fontFamily: 'SFPro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
