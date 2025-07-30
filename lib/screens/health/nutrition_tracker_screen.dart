import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../progress/progress_dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/nutrition_service.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_model.dart';

class NutritionTrackerScreen extends StatefulWidget {
  const NutritionTrackerScreen({super.key});

  @override
  State<NutritionTrackerScreen> createState() => _NutritionTrackerScreenState();
}

class _NutritionTrackerScreenState extends State<NutritionTrackerScreen> {
  int _selectedIndex = 0;
  UserModel? _userProfile;
  Map<String, double> _macroTargets = {};
  Map<String, double> _currentIntake = {};
  List<Map<String, dynamic>> _foodLog = [];
  Map<String, int> _macroPercentages = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load user profile
      final userProfile = await UserProfileService.getUserProfile();
      
      // Load macro data using the service
      final macroData = await NutritionService.getMacroData(userProfile);
      
      // Calculate percentages using the same service as home screen
      final percentages = await NutritionService.calculateMacroPercentages(userProfile);
      
      // Debug logging
      debugPrint('Nutrition Tracker - Loading data:');
      debugPrint('Current intake: ${macroData['current']}');
      debugPrint('Targets: ${macroData['targets']}');
      debugPrint('Food log count: ${macroData['food_log'].length}');
      
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _macroTargets = Map<String, double>.from(macroData['targets']);
          _currentIntake = Map<String, double>.from(macroData['current']);
          _foodLog = List<Map<String, dynamic>>.from(macroData['food_log']);
          _macroPercentages = percentages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  void _showLogFoodDialog() {
    final TextEditingController foodNameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    String selectedMacro = 'protein';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Log Food'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: foodNameController,
                    decoration: const InputDecoration(
                      labelText: 'Food Name',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Chicken Breast',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedMacro,
                    decoration: const InputDecoration(
                      labelText: 'Macro Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'protein', child: Text('Protein')),
                      DropdownMenuItem(value: 'fat', child: Text('Fat')),
                      DropdownMenuItem(value: 'carbs', child: Text('Carbs')),
                    ],
                    onChanged: (value) => setState(() => selectedMacro = value!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (g)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 25',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final foodName = foodNameController.text.trim();
                    final amountText = amountController.text.trim();
                    final amount = double.tryParse(amountText);
                    
                    if (foodName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a food name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid amount greater than 0'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    Navigator.of(context).pop();
                    await _addFoodEntry(foodName, selectedMacro, amount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                  ),
                  child: const Text(
                    'Add Food',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addFoodEntry(String foodName, String macroType, double amount) async {
    // Add to nutrition service
    final success = await NutritionService.addFoodEntry(foodName, macroType, amount);
    
    if (success) {
      // Reload nutrition data to get updated values
      await _loadNutritionData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $foodName to your food log!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add $foodName. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Clear all nutrition data
  Future<void> _clearAllNutritionData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      debugPrint('Clearing all nutrition data from Nutrition Tracker');

      // Remove ALL nutrition data completely
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'nutrition_data': FieldValue.delete(),
        'updatedAt': DateTime.now(),
      });

      debugPrint('Successfully cleared all nutrition data');

      // Reload nutrition data
      await _loadNutritionData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All nutrition data cleared! Start fresh by logging real food.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      debugPrint('Error clearing nutrition data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to clear data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          'Nutrition Tracker',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [],
      ),
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
              ),
              child: _isLoading 
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading nutrition data...'),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Macro Targets Section
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Macro Targets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Macro Progress Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildMacroCard('Protein', 'protein', '${_macroTargets['protein']?.toInt() ?? 0}g', const Color(0xFF4CAF50)),
                            const SizedBox(height: 12),
                            _buildMacroCard('Fat', 'fat', '${_macroTargets['fat']?.toInt() ?? 0}g', const Color(0xFFFF9800)),
                            const SizedBox(height: 12),
                            _buildMacroCard('Carbs', 'carbs', '${_macroTargets['carbs']?.toInt() ?? 0}g', const Color(0xFF2196F3)),
                          ],
                        ),
                      ),
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Log Food Button
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _showLogFoodDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Log Food',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Clear Data Button
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Show confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Clear All Data'),
                                      content: const Text('This will remove all logged food data and reset your nutrition tracking. Continue?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _clearAllNutritionData();
                                          },
                                          child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.clear_all, color: Colors.white, size: 18),
                              label: const Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Food Log
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Food log entries
                          Expanded(
                            child: ListView.builder(
                              itemCount: _foodLog.length,
                              itemBuilder: (context, index) {
                                final food = _foodLog[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        food['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        food['value'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            // Navigate back to home
            Navigator.pop(context);
          } else if (index == 1) {
            // Navigate to progress dashboard
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProgressDashboardScreen(),
              ),
            );
          } else if (index == 2) {
            // Navigate to AI chat
            Navigator.pushNamed(context, '/ai_chat');
          } else if (index == 3) {
            // Navigate to profile
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          }
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String macroName, String macroKey, String target, Color color) {
    // Use the same percentage calculation as home screen
    int percentage = _macroPercentages[macroKey] ?? 0;
    double progress = percentage / 100.0;
    double currentValue = _currentIntake[macroKey] ?? 0.0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        macroName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        currentValue > 0 || double.tryParse(target.replaceAll('g', '')) != 0
                            ? '${currentValue.toStringAsFixed(1)}g of $target'
                            : 'No data logged yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: currentValue > 0 ? Colors.grey : Colors.orange[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 100 ? Colors.red : color,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}