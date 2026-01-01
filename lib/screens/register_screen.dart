import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? selectedRole;
  String? selectedCompany;
  List<Map<String, dynamic>> companies = [];
  bool isLoading = false;

  final String getCompaniesUrl = "https://attendtrack.skynue.com/api/get_companies.php";
  final String registerUrl = "https://attendtrack.skynue.com/api/register.php";

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    try {
      final response = await http.get(Uri.parse(getCompaniesUrl));
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          companies = List<Map<String, dynamic>>.from(data['companies']);
        });
      }
    } catch (e) {
      print("Error fetching companies: $e");
    }
  }

  Future<void> registerUser() async {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        selectedRole == null ||
        selectedCompany == null) {
      showMessage("All fields are required");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": _usernameController.text.trim(),
          "password": _passwordController.text.trim(),
          "role": selectedRole!.toLowerCase(),
          "company_id": selectedCompany, // store company id
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        showMessage("Account Created Successfully!", success: true);
      } else {
        showMessage(data['message'] ?? "Registration failed");
      }
    } catch (e) {
      showMessage("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message, {bool success = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          success ? 'Success' : 'Error',
          style: const TextStyle(
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'SFPro',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              if (success) Navigator.pop(context); // back to login
            },
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
      appBar: AppBar(
        title: const Text(
          'AttendTrack',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Create an account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill the details to sign up for this app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SFPro',
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

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

              // Role
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: const TextStyle(fontFamily: 'SFPro'),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: selectedRole,
                items: const [
                  DropdownMenuItem(
                    value: 'employee',
                    child: Text('Employee', style: TextStyle(fontFamily: 'SFPro')),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin', style: TextStyle(fontFamily: 'SFPro')),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
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
              const SizedBox(height: 16),

              // Company Dropdown from API
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Company',
                  labelStyle: const TextStyle(fontFamily: 'SFPro'),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: selectedCompany,
                items: companies.map((company) {
                  return DropdownMenuItem<String>(
                    value: company['id'].toString(),
                    child: Text(company['name'], style: const TextStyle(fontFamily: 'SFPro')),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCompany = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Create Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading ? null : registerUser,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Create',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back to Login',
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

