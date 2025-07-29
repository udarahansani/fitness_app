import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Get user profile
  static Future<UserModel?> getUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // Error fetching user profile - return null for graceful degradation
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      await _firestore.collection('users').doc(userId).update(updates);
      return true;
    } catch (e) {
      // Error updating user profile - return false to indicate failure
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // Calculate BMI
  static double calculateBMI(double weight, double height) {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Calculate BMR (Basal Metabolic Rate)
  static double calculateBMR(UserModel user) {
    if (user.weight == null || user.height == null || user.age == null) {
      return 2000; // Default BMR
    }

    final weight = user.weight!;
    final height = user.height!;
    final age = user.age!;

    // Mifflin-St Jeor Equation
    if (user.gender?.toLowerCase() == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // Calculate daily calorie needs
  static double calculateDailyCalories(UserModel user) {
    final bmr = calculateBMR(user);
    
    // Activity multipliers
    double activityMultiplier;
    switch (user.activityLevel?.toLowerCase()) {
      case 'low':
        activityMultiplier = 1.2;
        break;
      case 'medium':
        activityMultiplier = 1.55;
        break;
      case 'high':
        activityMultiplier = 1.725;
        break;
      case 'very high':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.55;
    }

    double totalCalories = bmr * activityMultiplier;

    // Adjust based on fitness goal
    switch (user.fitnessGoal?.toLowerCase()) {
      case 'lose_fat':
        totalCalories *= 0.8; // 20% deficit
        break;
      case 'gain_muscle':
        totalCalories *= 1.15; // 15% surplus
        break;
      case 'maintain_weight':
        // No change
        break;
      default:
        // No change
        break;
    }

    return totalCalories;
  }

  // Calculate macro targets
  static Map<String, double> calculateMacroTargets(UserModel user) {
    final totalCalories = calculateDailyCalories(user);
    
    double proteinRatio, carbRatio, fatRatio;
    
    // Adjust macros based on fitness goal and diet type
    switch (user.fitnessGoal?.toLowerCase()) {
      case 'lose_fat':
        proteinRatio = 0.35; // High protein for fat loss
        fatRatio = 0.25;
        carbRatio = 0.40;
        break;
      case 'gain_muscle':
        proteinRatio = 0.30; // High protein for muscle gain
        fatRatio = 0.25;
        carbRatio = 0.45;
        break;
      default:
        proteinRatio = 0.25; // Balanced macros
        fatRatio = 0.30;
        carbRatio = 0.45;
        break;
    }

    // Adjust for diet type
    if (user.dietaryRestrictions?.contains('keto') == true) {
      fatRatio = 0.70;
      proteinRatio = 0.25;
      carbRatio = 0.05;
    } else if (user.dietaryRestrictions?.contains('vegan') == true) {
      carbRatio = 0.50; // Higher carbs for plant-based
      proteinRatio = 0.20;
      fatRatio = 0.30;
    }

    return {
      'protein': (totalCalories * proteinRatio) / 4, // 4 cal per gram
      'carbs': (totalCalories * carbRatio) / 4, // 4 cal per gram
      'fat': (totalCalories * fatRatio) / 9, // 9 cal per gram
      'calories': totalCalories,
    };
  }

  // Calculate water intake goal
  static double calculateWaterIntakeGoal(UserModel user) {
    if (user.weight == null) return 2.5; // Default 2.5L
    
    double baseWater = user.weight! * 0.035; // 35ml per kg
    
    // Adjust for activity level
    switch (user.activityLevel?.toLowerCase()) {
      case 'high':
        baseWater *= 1.2;
        break;
      case 'very high':
        baseWater *= 1.4;
        break;
      default:
        break;
    }

    return baseWater.clamp(1.5, 4.0); // Between 1.5L and 4L
  }

  // Generate personalized workout plan
  static List<Map<String, dynamic>> generateWorkoutPlan(UserModel user) {
    List<Map<String, dynamic>> exercises = [];
    
    // Base exercises for different goals
    Map<String, List<Map<String, dynamic>>> exerciseDatabase = {
      'lose_fat': [
        {'name': 'Jumping Jacks', 'duration': 15, 'calories': 80, 'type': 'cardio'},
        {'name': 'High Knees', 'duration': 12, 'calories': 60, 'type': 'cardio'},
        {'name': 'Burpees', 'duration': 10, 'calories': 100, 'type': 'cardio'},
        {'name': 'Mountain Climbers', 'duration': 15, 'calories': 90, 'type': 'cardio'},
        {'name': 'Plank', 'duration': 8, 'calories': 40, 'type': 'strength'},
      ],
      'gain_muscle': [
        {'name': 'Push-ups', 'duration': 12, 'calories': 50, 'type': 'strength'},
        {'name': 'Squats', 'duration': 15, 'calories': 70, 'type': 'strength'},
        {'name': 'Lunges', 'duration': 12, 'calories': 60, 'type': 'strength'},
        {'name': 'Plank', 'duration': 10, 'calories': 40, 'type': 'strength'},
        {'name': 'Tricep Dips', 'duration': 8, 'calories': 45, 'type': 'strength'},
      ],
      'maintain_weight': [
        {'name': 'Jumping Jacks', 'duration': 10, 'calories': 60, 'type': 'cardio'},
        {'name': 'Push-ups', 'duration': 8, 'calories': 40, 'type': 'strength'},
        {'name': 'Squats', 'duration': 10, 'calories': 50, 'type': 'strength'},
        {'name': 'Plank', 'duration': 8, 'calories': 35, 'type': 'core'},
      ],
    };

    // Get exercises based on fitness goal
    String goal = user.fitnessGoal ?? 'maintain_weight';
    List<Map<String, dynamic>> baseExercises = 
        exerciseDatabase[goal] ?? exerciseDatabase['maintain_weight']!;

    // Adjust duration based on activity level
    double durationMultiplier;
    switch (user.activityLevel?.toLowerCase()) {
      case 'low':
        durationMultiplier = 0.7;
        break;
      case 'medium':
        durationMultiplier = 1.0;
        break;
      case 'high':
        durationMultiplier = 1.3;
        break;
      case 'very high':
        durationMultiplier = 1.5;
        break;
      default:
        durationMultiplier = 1.0;
    }

    // Create personalized workout
    for (int i = 0; i < baseExercises.length && i < 4; i++) {
      var exercise = Map<String, dynamic>.from(baseExercises[i]);
      exercise['duration'] = (exercise['duration'] * durationMultiplier).round();
      exercise['calories'] = (exercise['calories'] * durationMultiplier).round();
      exercises.add(exercise);
    }

    return exercises;
  }

  // Save user's daily progress
  static Future<bool> saveUserProgress({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_progress')
          .doc(dateString)
          .set({
        type: data,
        'date': Timestamp.fromDate(today),
        'updated_at': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      // Error saving user progress - return false to indicate failure
      debugPrint('Error saving user progress: $e');
      return false;
    }
  }

  // Get user's daily progress
  static Future<Map<String, dynamic>?> getUserProgress(String date) async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_progress')
          .doc(date)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      // Error fetching user progress - return null for graceful degradation
      debugPrint('Error fetching user progress: $e');
      return null;
    }
  }

  // Get user's weekly progress
  static Future<List<Map<String, dynamic>>> getWeeklyProgress() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_progress')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      // Error fetching weekly progress - return empty list for graceful degradation
      debugPrint('Error fetching weekly progress: $e');
      return [];
    }
  }
}