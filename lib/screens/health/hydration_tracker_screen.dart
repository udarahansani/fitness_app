import 'package:flutter/material.dart';
import '../progress/progress_dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_model.dart';

class HydrationTrackerScreen extends StatefulWidget {
  const HydrationTrackerScreen({super.key});

  @override
  State<HydrationTrackerScreen> createState() => _HydrationTrackerScreenState();
}

class _HydrationTrackerScreenState extends State<HydrationTrackerScreen> {
  double _currentIntake = 0.0;
  double _dailyGoal = 2.5;
  bool _reminderEnabled = false;
  int _selectedIndex = 0;
  UserModel? _userProfile;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final profile = await UserProfileService.getUserProfile();
      if (profile != null) {
        final today = DateTime.now();
        final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final progress = await UserProfileService.getUserProgress(dateString);
        
        setState(() {
          _userProfile = profile;
          _dailyGoal = UserProfileService.calculateWaterIntakeGoal(profile);
          _currentIntake = (progress?['hydration']?['current'] ?? 0.0).toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error gracefully - set loading to false and log for debugging
      debugPrint('Error loading hydration data: $e');
      setState(() => _isLoading = false);
      // UI will show default values and allow user to continue tracking
    }
  }

  void _addWater(double amount) {
    setState(() {
      _currentIntake += amount;
      if (_currentIntake > _dailyGoal * 1.2) { // Allow 20% over goal
        _currentIntake = _dailyGoal * 1.2;
      }
    });
    
    // Save progress to Firebase
    UserProfileService.saveUserProgress(
      type: 'hydration',
      data: {
        'current': _currentIntake,
        'goal': _dailyGoal,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
    );
    
    // Show congratulations if goal is reached for the first time
    if (_currentIntake >= _dailyGoal && (_currentIntake - amount) < _dailyGoal) {
      _showGoalReached();
    }
  }

  void _showGoalReached() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎉 Goal Reached!'),
          content: const Text('Congratulations! You\'ve reached your daily hydration goal!'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
              ),
              child: const Text(
                'Great!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  double get _progressPercentage => _currentIntake / _dailyGoal;

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
          'Hydration Tracker',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Main content area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Water Bottle Illustration
                  SizedBox(
                    width: 180,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Bottle outline
                        Container(
                          width: 140,
                          height: 280,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                        ),
                        
                        // Bottle cap
                        Positioned(
                          top: 0,
                          child: Container(
                            width: 50,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                        ),
                        
                        // Water fill
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 134,
                            height: 274 * _progressPercentage,
                            decoration: const BoxDecoration(
                              color: Color(0xFF42A5F5),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(37),
                                bottomRight: Radius.circular(37),
                              ),
                            ),
                          ),
                        ),
                        
                        // Water level text
                        Positioned(
                          bottom: 80,
                          child: Column(
                            children: [
                              Text(
                                '${_currentIntake.toStringAsFixed(1)}L',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'of',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${_dailyGoal.toStringAsFixed(1)} L goal',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (_userProfile != null)
                                Text(
                                  'Based on ${_userProfile!.weight?.toStringAsFixed(0) ?? '70'}kg weight',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Add Water Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWaterButton('+100ml', 0.1),
                      _buildWaterButton('+250ml', 0.25),
                      _buildWaterButton('+500ml', 0.5),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Reminder Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Remainder',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Switch(
                          value: _reminderEnabled,
                          onChanged: (value) {
                            setState(() {
                              _reminderEnabled = value;
                            });
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value 
                                    ? 'Hydration reminders enabled!' 
                                    : 'Hydration reminders disabled',
                                ),
                                backgroundColor: value ? Colors.green : Colors.grey,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.grey[600],
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
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

  Widget _buildWaterButton(String label, double amount) {
    return SizedBox(
      width: 80,
      height: 40,
      child: ElevatedButton(
        onPressed: () => _addWater(amount),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF42A5F5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}