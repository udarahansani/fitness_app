import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SleepService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // Save sleep data
  static Future<bool> saveSleepData({
    required DateTime date,
    required DateTime bedTime,
    required DateTime wakeUpTime,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final sleepDuration = _calculateSleepDuration(bedTime, wakeUpTime);
      
      debugPrint('Saving sleep data for $dateString: ${sleepDuration.inHours}h ${sleepDuration.inMinutes % 60}m');

      // Save to user document like nutrition data
      await _firestore.collection('users').doc(userId).set({
        'sleep_data': {
          dateString: {
            'bedTime': Timestamp.fromDate(bedTime),
            'wakeUpTime': Timestamp.fromDate(wakeUpTime),
            'duration': sleepDuration.inMinutes,
            'quality': _calculateSleepQuality(sleepDuration),
            'timestamp': Timestamp.fromDate(DateTime.now()),
          },
        },
        'updatedAt': DateTime.now(),
      }, SetOptions(merge: true));

      debugPrint('Successfully saved sleep data');
      return true;
    } catch (e) {
      debugPrint('Error saving sleep data: $e');
      return false;
    }
  }

  // Get sleep data for a specific date
  static Future<Map<String, dynamic>?> getSleepData(DateTime date) async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data();
        final sleepData = data?['sleep_data'];
        
        if (sleepData != null && sleepData[dateString] != null) {
          final dayData = sleepData[dateString];
          return {
            'bedTime': (dayData['bedTime'] as Timestamp).toDate(),
            'wakeUpTime': (dayData['wakeUpTime'] as Timestamp).toDate(),
            'duration': dayData['duration'],
            'quality': dayData['quality'],
          };
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error getting sleep data: $e');
      return null;
    }
  }

  // Get sleep data for last 7 days
  static Future<List<Map<String, dynamic>>> getWeeklySleepData() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      final doc = await _firestore.collection('users').doc(userId).get();
      final List<Map<String, dynamic>> weeklyData = [];

      if (doc.exists) {
        final data = doc.data();
        final sleepData = data?['sleep_data'] ?? {};
        
        // Get last 7 days
        for (int i = 6; i >= 0; i--) {
          final date = DateTime.now().subtract(Duration(days: i));
          final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          
          if (sleepData[dateString] != null) {
            final dayData = sleepData[dateString];
            weeklyData.add({
              'date': date,
              'dateString': dateString,
              'bedTime': (dayData['bedTime'] as Timestamp).toDate(),
              'wakeUpTime': (dayData['wakeUpTime'] as Timestamp).toDate(),
              'duration': dayData['duration'],
              'quality': dayData['quality'],
            });
          } else {
            weeklyData.add({
              'date': date,
              'dateString': dateString,
              'bedTime': null,
              'wakeUpTime': null,
              'duration': 0,
              'quality': 0,
            });
          }
        }
      }

      return weeklyData;
    } catch (e) {
      debugPrint('Error getting weekly sleep data: $e');
      return [];
    }
  }

  // Get today's sleep data
  static Future<Map<String, dynamic>?> getTodaySleepData() async {
    return await getSleepData(DateTime.now());
  }

  // Calculate sleep duration
  static Duration _calculateSleepDuration(DateTime bedTime, DateTime wakeUpTime) {
    // Handle case where wake up time is next day
    if (wakeUpTime.isBefore(bedTime)) {
      wakeUpTime = wakeUpTime.add(const Duration(days: 1));
    }
    
    return wakeUpTime.difference(bedTime);
  }

  // Calculate sleep quality score (0-100)
  static int _calculateSleepQuality(Duration sleepDuration) {
    final hours = sleepDuration.inMinutes / 60.0;
    
    // Optimal sleep is 7-9 hours
    if (hours >= 7 && hours <= 9) {
      return 100;
    } else if (hours >= 6 && hours < 7) {
      return 85;
    } else if (hours >= 5 && hours < 6) {
      return 70;
    } else if (hours >= 9 && hours <= 10) {
      return 90;
    } else if (hours > 10) {
      return 60;
    } else {
      return 40; // Less than 5 hours
    }
  }

  // Get sleep quality text
  static String getSleepQualityText(int quality) {
    if (quality >= 90) return 'Excellent sleep!';
    if (quality >= 75) return 'Good sleep';
    if (quality >= 60) return 'Fair sleep';
    return 'Poor sleep';
  }

  // Format duration to string
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  // Format time to string
  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  // Get average sleep duration for the week
  static double getAverageSleepDuration(List<Map<String, dynamic>> weeklyData) {
    final validData = weeklyData.where((day) => day['duration'] > 0).toList();
    if (validData.isEmpty) return 0.0;
    
    final totalMinutes = validData.fold<int>(0, (sum, day) => sum + (day['duration'] as int));
    return totalMinutes / validData.length / 60.0; // Return in hours
  }
}