import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'user_profile_service.dart';

class NutritionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // Get current nutrition data for today from user document
  static Future<Map<String, dynamic>> getTodayNutrition() async {
    try {
      final userId = currentUserId;
      if (userId == null) return _getDefaultNutrition();

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Read from user document where nutrition data is now stored
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data();
        final nutritionData = data?['nutrition_data'];
        
        if (nutritionData != null && nutritionData[dateString] != null) {
          return Map<String, dynamic>.from(nutritionData[dateString]);
        }
      }

      return _getDefaultNutrition();
    } catch (e) {
      debugPrint('Error fetching today nutrition: $e');
      return _getDefaultNutrition();
    }
  }

  // Save nutrition data directly to user document (like authService does)
  static Future<bool> saveNutritionData(Map<String, dynamic> nutritionData) async {
    try {
      final userId = currentUserId;
      debugPrint('Current user ID: $userId');
      
      if (userId == null) {
        debugPrint('User is not authenticated');
        return false;
      }

      debugPrint('Nutrition data to save: $nutritionData');

      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Save directly to user document like authService does (which works)
      await _firestore.collection('users').doc(userId).set({
        'nutrition_data': {
          dateString: nutritionData,
        },
        'updatedAt': DateTime.now(),
      }, SetOptions(merge: true));

      debugPrint('Successfully saved nutrition data to user document');
      return true;
    } catch (e) {
      debugPrint('Error saving nutrition data: $e');
      debugPrint('Error type: ${e.runtimeType}');
      
      return false;
    }
  }

  // Add food entry
  static Future<bool> addFoodEntry(String foodName, String macroType, double amount) async {
    try {
      debugPrint('Adding food entry: $foodName, $macroType, $amount');
      
      final currentNutrition = await getTodayNutrition();
      debugPrint('Current nutrition data: $currentNutrition');
      
      // Ensure proper data structure initialization
      currentNutrition['current_intake'] ??= {
        'protein': 0.0,
        'fat': 0.0,
        'carbs': 0.0,
      };
      
      currentNutrition['food_log'] ??= <Map<String, dynamic>>[];
      
      // Update the current intake
      final currentValue = (currentNutrition['current_intake'][macroType] ?? 0.0).toDouble();
      currentNutrition['current_intake'][macroType] = currentValue + amount;
      
      debugPrint('Updated current intake: ${currentNutrition['current_intake']}');

      // Add to food log
      String unit = macroType == 'carbs' ? 'g carbs' : 'g $macroType';
      final foodEntry = {
        'name': foodName,
        'value': '${amount.toInt()} $unit',
        'type': macroType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      (currentNutrition['food_log'] as List).add(foodEntry);
      debugPrint('Added food log entry: $foodEntry');
      debugPrint('Total food log entries: ${currentNutrition['food_log'].length}');

      final result = await saveNutritionData(currentNutrition);
      debugPrint('Save result: $result');
      
      return result;
    } catch (e) {
      debugPrint('Error adding food entry: $e');
      debugPrint('Stack trace: ${e.toString()}');
      return false;
    }
  }

  // Calculate macro percentages using UserProfileService
  static Future<Map<String, int>> calculateMacroPercentages(UserModel? userProfile) async {
    try {
      if (userProfile == null) {
        return {'protein': 0, 'fat': 0, 'carbs': 0};
      }

      final macroTargets = UserProfileService.calculateMacroTargets(userProfile);
      final currentNutrition = await getTodayNutrition();
      final currentIntake = currentNutrition['current_intake'] ?? {};

      final proteinCurrent = (currentIntake['protein'] ?? 0.0).toDouble();
      final fatCurrent = (currentIntake['fat'] ?? 0.0).toDouble();
      final carbsCurrent = (currentIntake['carbs'] ?? 0.0).toDouble();

      final proteinProgress = macroTargets['protein'] != null && macroTargets['protein']! > 0 
          ? ((proteinCurrent / macroTargets['protein']!) * 100).round()
          : 0;
      final fatProgress = macroTargets['fat'] != null && macroTargets['fat']! > 0 
          ? ((fatCurrent / macroTargets['fat']!) * 100).round()
          : 0;
      final carbsProgress = macroTargets['carbs'] != null && macroTargets['carbs']! > 0 
          ? ((carbsCurrent / macroTargets['carbs']!) * 100).round()
          : 0;

      return {
        'protein': proteinProgress,
        'fat': fatProgress,
        'carbs': carbsProgress,
      };
    } catch (e) {
      debugPrint('Error calculating macro percentages: $e');
      return {'protein': 0, 'fat': 0, 'carbs': 0};
    }
  }

  // Get macro targets and current values
  static Future<Map<String, dynamic>> getMacroData(UserModel? userProfile) async {
    try {
      if (userProfile == null) {
        return _getDefaultMacroData();
      }

      final macroTargets = UserProfileService.calculateMacroTargets(userProfile);
      final currentNutrition = await getTodayNutrition();
      final currentIntake = currentNutrition['current_intake'] ?? {};

      return {
        'targets': macroTargets,
        'current': {
          'protein': (currentIntake['protein'] ?? 0.0).toDouble(),
          'fat': (currentIntake['fat'] ?? 0.0).toDouble(),
          'carbs': (currentIntake['carbs'] ?? 0.0).toDouble(),
        },
        'food_log': currentNutrition['food_log'] ?? [],
      };
    } catch (e) {
      debugPrint('Error getting macro data: $e');
      return _getDefaultMacroData();
    }
  }

  // Default nutrition data - start with empty values
  static Map<String, dynamic> _getDefaultNutrition() {
    return {
      'current_intake': {
        'protein': 0.0,
        'fat': 0.0,
        'carbs': 0.0,
      },
      'food_log': [],
    };
  }

  // Default macro data - start with empty values  
  static Map<String, dynamic> _getDefaultMacroData() {
    return {
      'targets': {
        'protein': 0.0,
        'fat': 0.0,
        'carbs': 0.0,
      },
      'current': {
        'protein': 0.0,
        'fat': 0.0,
        'carbs': 0.0,
      },
      'food_log': [],
    };
  }
}