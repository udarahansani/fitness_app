import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  String _selectedFitnessGoal = 'Lose Fat';
  String _selectedActivityLevel = 'Medium';
  String _selectedDietType = 'Vegan';
  String _selectedGender = 'Male';

  final List<String> _fitnessGoals = ['Lose Fat', 'Gain Muscle', 'Maintain Weight', 'General Fitness'];
  final List<String> _activityLevels = ['Low', 'Medium', 'High', 'Very High'];
  final List<String> _dietTypes = ['Vegan', 'Vegetarian', 'Non-Vegetarian', 'Keto', 'Paleo'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Title
                  const Text(
                    "Let's Personalize\nYour Fitness\nJourney",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
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
                              if (height == null || height < 100 || height > 250) {
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
                            (value) => setState(() => _selectedFitnessGoal = value!),
                          ),
                          const SizedBox(height: 16),
                          
                          // Activity Level Selection
                          _buildDropdownRow(
                            'Activity Level :',
                            _selectedActivityLevel,
                            _activityLevels,
                            (value) => setState(() => _selectedActivityLevel = value!),
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
                        ],
                      ),
                    ),
                  ),
                  
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continue to Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
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
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
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
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
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

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        
        // Update user profile with personalization data
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
          // Navigate to home screen after successful profile update
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}