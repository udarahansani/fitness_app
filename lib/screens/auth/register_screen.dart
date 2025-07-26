import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedGender = 'Male';
  String _selectedFitnessGoal = 'Lose Fat';
  String _selectedActivityLevel = 'Medium';
  String _selectedDietType = 'Vegan';

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _fitnessGoals = [
    'Lose Fat',
    'Gain Muscle',
    'Maintain Weight',
    'General Fitness',
  ];
  final List<String> _activityLevels = ['Low', 'Medium', 'High', 'Very High'];
  final List<String> _dietTypes = [
    'Vegan',
    'Vegetarian',
    'Non-Vegetarian',
    'Keto',
    'Paleo',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/welcome',
            (route) => false,
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Title
                const Text(
                  "Let's Personalize\nYour Fitness Journey",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),

                // Scrollable form
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        // Email Field
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
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
                        const SizedBox(height: 16),

                        // Password Field
                        _buildPasswordField(
                          controller: _passwordController,
                          hintText: 'Password',
                          isVisible: _isPasswordVisible,
                          onToggle: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
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
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          isVisible: _isConfirmPasswordVisible,
                          onToggle: () => setState(
                            () => _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Name Field
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Age Field
                        _buildTextField(
                          controller: _ageController,
                          hintText: 'Age',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            final age = int.tryParse(value);
                            if (age == null || age < 13 || age > 100) {
                              return 'Please enter a valid age (13-100)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Weight Field
                        _buildTextField(
                          controller: _weightController,
                          hintText: 'Weight(Kg)',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight < 30 || weight > 300) {
                              return 'Please enter a valid weight (30-300 kg)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Height Field
                        _buildTextField(
                          controller: _heightController,
                          hintText: 'Height(cm)',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            final height = double.tryParse(value);
                            if (height == null ||
                                height < 100 ||
                                height > 250) {
                              return 'Please enter a valid height (100-250 cm)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Gender Selection
                        _buildDropdownRow(
                          'Gender :',
                          _selectedGender,
                          _genders,
                          (value) => setState(() => _selectedGender = value!),
                        ),
                        const SizedBox(height: 16),

                        // Fitness Goal Selection
                        _buildDropdownRow(
                          'Fitness Goal :',
                          _selectedFitnessGoal,
                          _fitnessGoals,
                          (value) =>
                              setState(() => _selectedFitnessGoal = value!),
                        ),
                        const SizedBox(height: 16),

                        // Activity Level Selection
                        _buildDropdownRow(
                          'Activity Level :',
                          _selectedActivityLevel,
                          _activityLevels,
                          (value) =>
                              setState(() => _selectedActivityLevel = value!),
                        ),
                        const SizedBox(height: 16),

                        // Diet Type Selection
                        _buildDropdownRow(
                          'Diet Type :',
                          _selectedDietType,
                          _dietTypes,
                          (value) => setState(() => _selectedDietType = value!),
                        ),
                        const SizedBox(height: 40),

                        // Create Account Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Already have account
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'Already have an account? Login',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownRow(
    String label,
    String selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                onChanged: onChanged,
                items: options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Creating your account...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }

      try {
        print('Starting registration process...');

        // Create Firebase account with minimal error handling
        print('Creating Firebase account...');
        UserCredential? userCredential;

        try {
          userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );
          print('Firebase account created successfully');
        } catch (authError) {
          print('Auth error: $authError');

          // Check if it's the PigeonUserDetails error but user was actually created
          if (authError.toString().contains('PigeonUserDetails')) {
            print(
              'PigeonUserDetails error detected, but checking if user was created...',
            );

            // Wait a moment for Firebase to sync
            await Future.delayed(const Duration(milliseconds: 1000));

            // Check if user exists by trying to get current user
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null &&
                currentUser.email == _emailController.text.trim()) {
              print('User was actually created successfully despite the error');
              // Skip the userCredential assignment and go directly to Firestore save
              final userId = currentUser.uid;
              print('User ID: $userId');

              // Save user data to Firestore directly
              print('Saving user data to Firestore...');
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .set({
                      'uid': userId,
                      'email': _emailController.text.trim(),
                      'displayName': _nameController.text.trim(),
                      'age': int.parse(_ageController.text),
                      'weight': double.parse(_weightController.text),
                      'height': double.parse(_heightController.text),
                      'gender': _selectedGender,
                      'fitnessGoal': _selectedFitnessGoal
                          .toLowerCase()
                          .replaceAll(' ', '_'),
                      'activityLevel': _selectedActivityLevel.toLowerCase(),
                      'dietaryRestrictions': [_selectedDietType.toLowerCase()],
                      'profileCompleted': true,
                      'createdAt': DateTime.now(),
                      'lastLoginAt': DateTime.now(),
                    });

                print('User data saved successfully');

                if (mounted) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Account created successfully! Please login with your credentials.',
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // Sign out the user and navigate to login screen
                  await FirebaseAuth.instance.signOut();
                  await Future.delayed(const Duration(milliseconds: 500));
                  Navigator.pushReplacementNamed(context, '/login');
                }
                return; // Exit the function successfully
              } catch (firestoreError) {
                print('Firestore error: $firestoreError');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Account created but profile save failed. Please try logging in.',
                      ),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
                return;
              }
            } else {
              // User wasn't created, show error
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Registration failed due to a technical error. Please try again.',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
              return;
            }
          } else {
            // Handle other Firebase errors
            if (mounted) {
              String errorMessage = 'Registration failed';
              if (authError.toString().contains('email-already-in-use')) {
                errorMessage = 'The account already exists for that email.';
              } else if (authError.toString().contains('weak-password')) {
                errorMessage = 'The password provided is too weak.';
              } else if (authError.toString().contains('invalid-email')) {
                errorMessage = 'The email address is not valid.';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
            return;
          }
        }

        // If we get here, account was created successfully
        if (userCredential.user?.uid != null) {
          final userId = userCredential.user!.uid;
          print('User ID: $userId');

          // Save user data to Firestore
          print('Saving user data to Firestore...');
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .set({
                  'uid': userId,
                  'email': _emailController.text.trim(),
                  'displayName': _nameController.text.trim(),
                  'age': int.parse(_ageController.text),
                  'weight': double.parse(_weightController.text),
                  'height': double.parse(_heightController.text),
                  'gender': _selectedGender,
                  'fitnessGoal': _selectedFitnessGoal.toLowerCase().replaceAll(
                    ' ',
                    '_',
                  ),
                  'activityLevel': _selectedActivityLevel.toLowerCase(),
                  'dietaryRestrictions': [_selectedDietType.toLowerCase()],
                  'profileCompleted': true,
                  'createdAt': DateTime.now(),
                  'lastLoginAt': DateTime.now(),
                });

            print('User data saved successfully');

            if (mounted) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Account created successfully! Please login with your credentials.',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );

              // Sign out the user and navigate to login screen
              await FirebaseAuth.instance.signOut();
              await Future.delayed(const Duration(milliseconds: 500));
              Navigator.pushReplacementNamed(context, '/login');
            }
          } catch (firestoreError) {
            print('Firestore error: $firestoreError');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Account created but profile save failed. Please try logging in.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          }
        }
      } catch (e) {
        print('Unexpected error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }
}
