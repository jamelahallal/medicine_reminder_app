import 'package:flutter/material.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'RegisterPage.dart';

const String _baseURL = 'medecine.atwebpages.com';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await http.post(
        Uri.http(_baseURL, 'login.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({//send to php to check
          "username": username,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);//php sends to flutter convert to map in dart

      // Convert user_id to int safely
      if (data['success'] == true && data['user_id'] != null) {
        int userId = int.tryParse(data['user_id'].toString()) ?? 0;

        if (userId > 0) {//if I have a user go to home page
          Navigator.pushReplacement(//use thisinstead of (of) to close login page for security
            context,
            MaterialPageRoute(
              builder: (_) => MedicineHomePage(userId: userId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid user ID')),
          );
        }
      } else {
        // Show server error message if available
        String errorMsg = data['error'] ?? 'Invalid username or password';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.teal,
           centerTitle: true,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 250,
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: const Text('Login',style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: Colors.teal,
                    decoration: TextDecoration.underline, // makes it look clickable
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}