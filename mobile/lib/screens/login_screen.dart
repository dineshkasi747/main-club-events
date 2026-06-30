import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _errorMessage = '';

  void _handleGoogleLogin() async {
    setState(() {
      _errorMessage = '';
    });

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '151448477468-2h599a70upkj7plglafifgdp77tafah9.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return; // User cancelled the sign-in flow
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final String? email = userCredential.user?.email;
      final String displayName = userCredential.user?.displayName ?? 'Student';

      if (email == null) {
        throw Exception("Could not retrieve email from Google Account.");
      }

      // Check domain restriction: only @gvpce.ac.in is allowed
      if (!email.toLowerCase().endsWith('@gvpce.ac.in')) {
        await FirebaseAuth.instance.signOut();
        await googleSignIn.signOut();
        setState(() {
          _errorMessage = 'Access denied. Only @gvpce.ac.in emails are permitted.';
        });
        return;
      }

      // Proceed with backend login and registration
      final success = await Provider.of<AppState>(context, listen: false).googleLogin(email, displayName);

      if (success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Backend authentication failed. Please try again.';
        });
      }
    } catch (e) {
      print('Google sign-in error: $e');
      setState(() {
        _errorMessage = 'Google Sign-In failed or was cancelled.';
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

              // Google Sign-In Card Container
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
                      const SizedBox(height: 20),
                    ],

                    const Text(
                      'Welcome! Please sign in using your college Google account (@gvpce.ac.in) to access your dashboard, registered events, scanner tickets, and broadcast notifications.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.45),
                    ),
                    const SizedBox(height: 24),

                    // Google Sign In Button
                    ElevatedButton.icon(
                      onPressed: appState.isLoading ? null : _handleGoogleLogin,
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.white),
                      label: const Text('Sign In with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFFEA4335), // Google Red branding
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
