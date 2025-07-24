import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Login here',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                const Text(
                  'Welcome back you\'ve\nbeen missed!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1565C0),
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Password field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot_password');
                    },
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(color: Color(0xFF1565C0), fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Create account
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Create new account',
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ),
                ),

                const Spacer(),

                // Or continue with
                const Center(
                  child: Text(
                    'Or continue with',
                    style: TextStyle(color: Color(0xFF1565C0), fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      onPressed: () {
                        // Google sign in
                      },
                      icon: Icons.g_mobiledata,
                    ),
                    _buildSocialButton(
                      onPressed: () {
                        // Facebook sign in
                      },
                      icon: Icons.facebook,
                    ),
                    _buildSocialButton(
                      onPressed: () {
                        // Apple sign in
                      },
                      icon: Icons.apple,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 28, color: Colors.black87),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        print('Starting login process...');
        
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signing you in...'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Sign in with Firebase directly
        UserCredential? userCredential;
        
        try {
          userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          print('Login successful: ${userCredential.user!.email}');
        } catch (authError) {
          print('Login auth error: $authError');
          
          // Check if it's the PigeonUserDetails error but user was actually logged in
          if (authError.toString().contains('PigeonUserDetails')) {
            print('PigeonUserDetails error detected during login, checking if user is logged in...');
            
            // Wait a moment for Firebase to sync
            await Future.delayed(const Duration(milliseconds: 1000));
            
            // Check if user is now logged in
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null && currentUser.email == _emailController.text.trim()) {
              print('User was actually logged in successfully despite the error');
              
              // Update last login time
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .update({
                  'lastLoginAt': DateTime.now(),
                });
                print('Last login time updated');
              } catch (e) {
                print('Error updating last login time: $e');
                // Continue anyway since login was successful
              }

              if (mounted) {
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login successful!'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Navigate to home screen after successful login
                Navigator.pushReplacementNamed(context, '/home');
              }
              return; // Exit function successfully
            } else {
              // User wasn't logged in, show error
              throw 'Login failed due to a technical error.';
            }
          } else {
            // Handle other Firebase errors
            if (authError.toString().contains('user-not-found')) {
              throw 'No user found for that email.';
            } else if (authError.toString().contains('wrong-password')) {
              throw 'Wrong password provided.';
            } else if (authError.toString().contains('invalid-email')) {
              throw 'The email address is not valid.';
            } else if (authError.toString().contains('user-disabled')) {
              throw 'This user account has been disabled.';
            } else {
              throw 'Login failed: ${authError.toString()}';
            }
          }
        }

        // If we get here, login was successful without errors
        if (userCredential?.user != null) {
          print('Login successful: ${userCredential!.user!.email}');
          
          // Update last login time
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .update({
              'lastLoginAt': DateTime.now(),
            });
            print('Last login time updated');
          } catch (e) {
            print('Error updating last login time: $e');
            // Continue anyway since login was successful
          }

          if (mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate to home screen after successful login
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } catch (e) {
        print('Login error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }
}
