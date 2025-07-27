import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/health_data_model.dart';

class HealthDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  HealthDataService({required this.userId});

  // Save daily health data
  Future<void> saveHealthData(HealthDataModel data) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(data.date);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc(dateStr)
        .set(data.toFirestore(), SetOptions(merge: true));
  }

  // Get health data for specific date
  Future<HealthDataModel?> getHealthData(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc(dateStr)
        .get();

    if (doc.exists) {
      return HealthDataModel.fromFirestore(doc);
    }
    return null;
  }

  // Get health data for date range
  Future<List<HealthDataModel>> getHealthDataRange(
    DateTime start,
    DateTime end,
  ) async {
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date')
        .get();

    return query.docs.map((doc) => HealthDataModel.fromFirestore(doc)).toList();
  }

  // Update specific health metric
  Future<void> updateSteps(int steps) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc(today)
        .set({
          'steps': steps,
          'date': DateTime.now(),
          'userId': userId,
        }, SetOptions(merge: true));
  }

  Future<void> updateWaterIntake(double liters) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc(today)
        .set({
          'waterIntake': liters,
          'date': DateTime.now(),
          'userId': userId,
        }, SetOptions(merge: true));
  }

  Future<void> updateSleep(double hours) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc(today)
        .set({
          'sleepHours': hours,
          'date': DateTime.now(),
          'userId': userId,
        }, SetOptions(merge: true));
  }

  Future<void> updateCalories(double calories) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc(today)
        .set({
          'calories': calories,
          'date': DateTime.now(),
          'userId': userId,
        }, SetOptions(merge: true));
  }

  Future<void> updateWeight(double weight) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc(today)
        .set({
          'weight': weight,
          'date': DateTime.now(),
          'userId': userId,
        }, SetOptions(merge: true));
  }

  // Get weekly statistics
  Future<Map<String, double>> getWeeklyStats() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final data = await getHealthDataRange(weekAgo, now);

    if (data.isEmpty) {
      return {
        'avgSteps': 0.0,
        'avgCalories': 0.0,
        'avgWater': 0.0,
        'avgSleep': 0.0,
      };
    }

    final totalSteps = data.fold(0, (total, item) => total + item.steps);
    final totalCalories = data.fold(
      0.0,
      (total, item) => total + item.calories,
    );
    final totalWater = data.fold(
      0.0,
      (total, item) => total + item.waterIntake,
    );
    final totalSleep = data.fold(0.0, (total, item) => total + item.sleepHours);

    return {
      'avgSteps': totalSteps / data.length,
      'avgCalories': totalCalories / data.length,
      'avgWater': totalWater / data.length,
      'avgSleep': totalSleep / data.length,
    };
  }
}
