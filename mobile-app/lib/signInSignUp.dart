import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AuthBackground(
        imagePath: 'assets/chiken1.jpg',
        child: Column(
          children: [
            _buildTitle(),
            const SizedBox(height: 50),
            _AuthCard(
              children: [
                _buildTextField(emailController, 'Email', Icons.email),
                const SizedBox(height: 20),
                _buildTextField(passwordController, 'Password', Icons.lock,
                    obscure: true),
                const SizedBox(height: 30),
                _buildActionButton(
                  context,
                  label: 'Sign In',
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      Navigator.pushReplacementNamed(context, '/home');
                    } catch (e) {
                      _showError(context, 'Login failed: $e');
                    }
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  child: const Text("Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AuthBackground(
        imagePath: 'assets/chiken4.jpg',
        child: Column(
          children: [
            _buildTitle(),
            const SizedBox(height: 50),
            _AuthCard(
              children: [
                _buildTextField(emailController, 'Email', Icons.email),
                const SizedBox(height: 20),
                _buildTextField(passwordController, 'Password', Icons.lock,
                    obscure: true),
                const SizedBox(height: 20),
                _buildTextField(
                    confirmPasswordController, 'Confirm Password', Icons.lock,
                    obscure: true),
                const SizedBox(height: 30),
                _buildActionButton(
                  context,
                  label: 'Sign Up',
                  onPressed: () async {
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      _showError(context, 'Passwords do not match.');
                      return;
                    }
                    try {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      Navigator.pushReplacementNamed(context, '/signin');
                    } catch (e) {
                      _showError(context, 'Sign up failed: $e');
                    }
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signin');
                  },
                  child: const Text("Already have an account? Sign In",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 🔧 Widgets & Helpers

Widget _buildTitle() {
  return Center(
    child: Text(
      'aviTech',
      style: GoogleFonts.pacifico(color: Colors.green[400], fontSize: 40),
    ),
  );
}

Widget _buildTextField(
    TextEditingController controller, String label, IconData icon,
    {bool obscure = false}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green),
      labelStyle: const TextStyle(color: Colors.white70),
    ),
  );
}

Widget _buildActionButton(BuildContext context,
    {required String label, required VoidCallback onPressed}) {
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.green),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
    child:
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
  );
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _AuthBackground extends StatelessWidget {
  final String imagePath;
  final Widget child;

  const _AuthBackground({required this.imagePath, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(imagePath, fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.5)),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: child,
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  final List<Widget> children;

  const _AuthCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: children),
      ),
    );
  }
}
