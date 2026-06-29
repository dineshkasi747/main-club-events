import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'student@college.edu');
  final _passwordController = TextEditingController(text: 'password');
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _errorMessage = '';
    });

    final success = await Provider.of<AppState>(context, listen: false).login(
      email.isEmpty ? 'student@college.edu' : email,
      password.isEmpty ? 'password' : password,
    );

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid credentials or connection issue.';
      });
    }
  }

  void _handleDemoLogin() async {
    setState(() {
      _errorMessage = '';
    });
    
    final success = await Provider.of<AppState>(context, listen: false).demoLogin();
    
    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Demo login failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light grey background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium brand logo
              Center(
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.school, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'College Clubs Hub',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Student Mobile Portal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 40),

              // Glassmorphic Style White Input Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email input
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email, color: Color(0xFF4F46E5), size: 20),
                          labelText: 'College Email Address',
                          labelStyle: const TextStyle(color: Color(0xFF475569)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password input
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (v) => v == null || v.isEmpty ? 'Password required' : null,
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFF4F46E5), size: 20),
                          labelText: 'Secret Password',
                          labelStyle: const TextStyle(color: Color(0xFF475569)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign In Button
                      ElevatedButton(
                        onPressed: appState.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: appState.isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Log In Session', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),

                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text('OR FOR TESTING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                          ),
                          Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Demo Sign In Button
                      OutlinedButton(
                        onPressed: appState.isLoading ? null : _handleDemoLogin,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('One-Tap Demo Student Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
