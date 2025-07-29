import 'package:flutter/material.dart';
import '../../services/user_profile_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final String name;
  final String age;
  final String gender;
  final String? weight;
  final String? height;
  final String? fitnessGoal;
  final String? activityLevel;
  final String? profilePictureUrl;

  const ProfileEditScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    this.weight,
    this.height,
    this.fitnessGoal,
    this.activityLevel,
    this.profilePictureUrl,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  String _selectedGender = 'Male';
  String _selectedFitnessGoal = 'weight_loss';
  String _selectedActivityLevel = 'moderate';
  
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _fitnessGoals = ['weight_loss', 'muscle_gain', 'maintenance'];
  final List<String> _activityLevels = ['sedentary', 'light', 'moderate', 'active', 'very_active'];

  @override
  void initState() {
    super.initState();
    
    // Debug: Print received data
    print('=== Profile Edit Screen Data ===');
    print('Name: "${widget.name}"');
    print('Age: "${widget.age}"');
    print('Gender: "${widget.gender}"');
    print('Weight: "${widget.weight}"');
    print('Height: "${widget.height}"');
    print('Fitness Goal: "${widget.fitnessGoal}"');
    print('Activity Level: "${widget.activityLevel}"');
    print('Profile Picture URL: "${widget.profilePictureUrl}"');
    print('================================');
    
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController(text: widget.age);
    _weightController = TextEditingController(text: widget.weight ?? '');
    _heightController = TextEditingController(text: widget.height ?? '');
    
    // Initialize dropdowns with current values or defaults
    _selectedGender = _genders.contains(widget.gender) ? widget.gender : 'Male';
    _selectedFitnessGoal = (widget.fitnessGoal != null && _fitnessGoals.contains(widget.fitnessGoal)) 
        ? widget.fitnessGoal! 
        : 'weight_loss';
    _selectedActivityLevel = (widget.activityLevel != null && _activityLevels.contains(widget.activityLevel)) 
        ? widget.activityLevel! 
        : 'moderate';
  }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFE3F2FD),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Profile Image
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  image: widget.profilePictureUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.profilePictureUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.profilePictureUrl == null 
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      )
                    : Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              
              const SizedBox(height: 50),
              
              // Form Fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Name Field
                    _buildTextField(
                      label: 'Name',
                      controller: _nameController,
                      icon: Icons.person_outline,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Age Field
                    _buildTextField(
                      label: 'Age',
                      controller: _ageController,
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Gender Dropdown
                    _buildGenderDropdown(),
                    
                    const SizedBox(height: 20),
                    
                    // Weight Field
                    _buildTextField(
                      label: 'Weight (kg)',
                      controller: _weightController,
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Height Field
                    _buildTextField(
                      label: 'Height (cm)',
                      controller: _heightController,
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Fitness Goal Dropdown
                    _buildFitnessGoalDropdown(),
                    
                    const SizedBox(height: 20),
                    
                    // Activity Level Dropdown
                    _buildActivityLevelDropdown(),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1565C0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: _genders.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Row(
                    children: [
                      Icon(
                        gender == 'Male' 
                          ? Icons.male 
                          : gender == 'Female' 
                            ? Icons.female 
                            : Icons.person,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        gender,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFitnessGoalDropdown() {
    final Map<String, String> goalLabels = {
      'weight_loss': 'Weight Loss',
      'muscle_gain': 'Muscle Gain', 
      'maintenance': 'Maintenance',
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitness Goal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFitnessGoal,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: _fitnessGoals.map((String goal) {
                return DropdownMenuItem<String>(
                  value: goal,
                  child: Row(
                    children: [
                      Icon(
                        goal == 'weight_loss' 
                          ? Icons.trending_down 
                          : goal == 'muscle_gain'
                            ? Icons.fitness_center
                            : Icons.balance,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        goalLabels[goal]!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFitnessGoal = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLevelDropdown() {
    final Map<String, String> activityLabels = {
      'sedentary': 'Sedentary (Little/no exercise)',
      'light': 'Light (Light exercise 1-3 days/week)',
      'moderate': 'Moderate (Moderate exercise 3-5 days/week)',
      'active': 'Active (Hard exercise 6-7 days/week)',
      'very_active': 'Very Active (Physical job + exercise)',
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedActivityLevel,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: _activityLevels.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_run,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          activityLabels[level]!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedActivityLevel = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your name');
      return;
    }
    
    if (_ageController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your age');
      return;
    }
    
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 1 || age > 120) {
      _showErrorSnackBar('Please enter a valid age (1-120)');
      return;
    }

    // Validate weight and height if provided
    double? weight;
    double? height;
    
    if (_weightController.text.trim().isNotEmpty) {
      weight = double.tryParse(_weightController.text.trim());
      if (weight == null || weight <= 0 || weight > 500) {
        _showErrorSnackBar('Please enter a valid weight (1-500 kg)');
        return;
      }
    }
    
    if (_heightController.text.trim().isNotEmpty) {
      height = double.tryParse(_heightController.text.trim());
      if (height == null || height <= 0 || height > 300) {
        _showErrorSnackBar('Please enter a valid height (1-300 cm)');
        return;
      }
    }

    try {
      // Update Firebase with the new profile data
      final updateData = {
        'displayName': _nameController.text.trim(),
        'age': age,
        'gender': _selectedGender,
        'fitnessGoal': _selectedFitnessGoal,
        'activityLevel': _selectedActivityLevel,
      };
      
      if (weight != null) updateData['weight'] = weight;
      if (height != null) updateData['height'] = height;
      
      print('Updating profile with data: $updateData');
      
      // Use UserProfileService for profile updates
      final success = await UserProfileService.updateUserProfile(updateData);
      
      if (success) {
        print('Profile updated successfully');
        
        // Return success to parent screen
        if (mounted) {
          Navigator.pop(context, true);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _showErrorSnackBar('Failed to update profile. Please try again.');
      }
    } catch (e) {
      print('Error updating profile: $e');
      _showErrorSnackBar('Error updating profile: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}