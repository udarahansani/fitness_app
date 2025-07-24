import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

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
  String _selectedDietType = 'Non-Vegetarian';

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _fitnessGoals = ['Lose Fat', 'Gain Muscle', 'Maintain Weight', 'General Fitness'];
  final List<String> _activityLevels = ['Low', 'Medium', 'High', 'Very High'];
  final List<String> _dietTypes = ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Keto', 'Paleo'];

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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                const Text(
                  'Fill in your details to create your fitness profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        _buildPasswordField(
                          controller: _passwordController,
                          hintText: 'Password',
                          isVisible: _isPasswordVisible,
                          onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
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

                        // Confirm Password field
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          isVisible: _isConfirmPasswordVisible,
                          onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
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

                        // Personal Details Section
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Personal Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name field
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Age and Gender Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _ageController,
                                hintText: 'Age',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter age';
                                  }
                                  final age = int.tryParse(value);
                                  if (age == null || age < 13 || age > 100) {
                                    return 'Invalid age';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdown(
                                value: _selectedGender,
                                items: _genders,
                                onChanged: (value) => setState(() => _selectedGender = value!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Weight and Height Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _weightController,
                                hintText: 'Weight (kg)',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter weight';
                                  }
                                  final weight = double.tryParse(value);
                                  if (weight == null || weight < 30 || weight > 300) {
                                    return 'Invalid weight';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _heightController,
                                hintText: 'Height (cm)',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter height';
                                  }
                                  final height = double.tryParse(value);
                                  if (height == null || height < 100 || height > 250) {
                                    return 'Invalid height';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Fitness Preferences Section
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Fitness Preferences',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Fitness Goal
                        _buildDropdown(
                          value: _selectedFitnessGoal,
                          items: _fitnessGoals,
                          onChanged: (value) => setState(() => _selectedFitnessGoal = value!),
                          label: 'Fitness Goal',
                        ),
                        const SizedBox(height: 16),

                        // Activity Level
                        _buildDropdown(
                          value: _selectedActivityLevel,
                          items: _activityLevels,
                          onChanged: (value) => setState(() => _selectedActivityLevel = value!),
                          label: 'Activity Level',
                        ),
                        const SizedBox(height: 16),

                        // Diet Type
                        _buildDropdown(
                          value: _selectedDietType,
                          items: _dietTypes,
                          onChanged: (value) => setState(() => _selectedDietType = value!),
                          label: 'Diet Preference',
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Sign up button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
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
                      style: TextStyle(color: Color(0xFF1565C0), fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
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
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        
        // Create Firebase account
        await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        // Update user profile with all details
        await authService.updateUserProfile({
          'displayName': _nameController.text.trim(),
          'age': int.parse(_ageController.text),
          'weight': double.parse(_weightController.text),
          'height': double.parse(_heightController.text),
          'gender': _selectedGender,
          'fitnessGoal': _selectedFitnessGoal.toLowerCase().replaceAll(' ', '_'),
          'activityLevel': _selectedActivityLevel.toLowerCase(),
          'dietaryRestrictions': [_selectedDietType.toLowerCase()],
          'profileCompleted': true,
        });
        
        if (mounted) {
          // Navigate to personalization screen after successful registration
          Navigator.pushReplacementNamed(context, '/personalization');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}