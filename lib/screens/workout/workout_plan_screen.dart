import 'package:flutter/material.dart';
import 'jumping_workout_screen.dart';
import '../progress/progress_dashboard_screen.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_model.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int _selectedIndex = 0;
  UserModel? _userProfile;
  List<Map<String, dynamic>> _exercises = [];
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
        final workoutPlan = UserProfileService.generateWorkoutPlan(profile);
        
        setState(() {
          _userProfile = profile;
          _exercises = workoutPlan;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error gracefully - log for debugging and stop loading
      debugPrint('Error loading workout plan data: $e');
      setState(() => _isLoading = false);
      // Screen will show empty state, allowing user to try again or navigate away
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Workout Plan',
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
          // Goal Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal: ${_userProfile?.fitnessGoal?.replaceAll('_', ' ').toUpperCase() ?? 'FITNESS'} - ${_userProfile?.activityLevel?.toUpperCase() ?? 'MEDIUM'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_getTotalDuration()} min workout • ${_getTotalCalories()} cal burn',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Exercise List
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
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
                        child: Row(
                          children: [
                            // Exercise Image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _getExerciseColor(exercise['type']),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_getExerciseColor(exercise['type']), _getExerciseColor(exercise['type']).withValues(alpha: 0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Icon(
                                    _getExerciseIcon(exercise['type']),
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Exercise Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${exercise['calories']} cal • ${exercise['type']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Duration
                            Text(
                              '${exercise['duration']} min',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Start Session Button (moved up)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save workout start to progress
                        UserProfileService.saveUserProgress(
                          type: 'workout',
                          data: {
                            'started': DateTime.now().toIso8601String(),
                            'exercises': _exercises,
                            'completed': false,
                          },
                        );
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JumpingWorkoutScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
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

  int _getTotalDuration() {
    return _exercises.fold(0, (sum, exercise) => sum + (exercise['duration'] as int));
  }
  
  int _getTotalCalories() {
    return _exercises.fold(0, (sum, exercise) => sum + (exercise['calories'] as int));
  }
  
  Color _getExerciseColor(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return const Color(0xFFFF5722);
      case 'strength':
        return const Color(0xFF3F51B5);
      case 'core':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFFFFB74D);
    }
  }
  
  IconData _getExerciseIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'strength':
        return Icons.fitness_center;
      case 'core':
        return Icons.self_improvement;
      default:
        return Icons.sports_gymnastics;
    }
  }
}