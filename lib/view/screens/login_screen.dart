import 'package:flutter/material.dart';
import './register_screen.dart'; // Import the RegisterScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Regex pattern for email validation
  final String _emailPattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to validate email format
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(_emailPattern).hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Method to validate password length
  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    } else if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // If all validations pass, show a SnackBar for successful login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
        ),
      );
      // Handle further login logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Email TextField with validation
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),
                  // Password TextField with validation
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),
                  // Login Button with validation
                  ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  // Navigate to registration screen
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegistrationScreen()),
                      );
                    },
                    child: const Text('Don\'t have an account? Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}
