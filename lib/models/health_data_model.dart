import 'package:cloud_firestore/cloud_firestore.dart';

class HealthDataModel {
  final String userId;
  final DateTime date;
  final int steps;
  final double calories;
  final double waterIntake; // liters
  final double sleepHours;
  final double? weight; // kg
  
  HealthDataModel({
    required this.userId,
    required this.date,
    this.steps = 0,
    this.calories = 0.0,
    this.waterIntake = 0.0,
    this.sleepHours = 0.0,
    this.weight,
  });
  
  factory HealthDataModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return HealthDataModel(
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      steps: data['steps'] ?? 0,
      calories: (data['calories'] ?? 0.0).toDouble(),
      waterIntake: (data['waterIntake'] ?? 0.0).toDouble(),
      sleepHours: (data['sleepHours'] ?? 0.0).toDouble(),
      weight: data['weight']?.toDouble(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'steps': steps,
      'calories': calories,
      'waterIntake': waterIntake,
      'sleepHours': sleepHours,
      'weight': weight,
    };
  }
  
  factory HealthDataModel.defaultForToday({String? userId}) {
    return HealthDataModel(
      userId: userId ?? '',
      date: DateTime.now(),
      steps: 0,
      calories: 0.0,
      waterIntake: 0.0,
      sleepHours: 0.0,
    );
  }
  
  HealthDataModel copyWith({
    String? userId,
    DateTime? date,
    int? steps,
    double? calories,
    double? waterIntake,
    double? sleepHours,
    double? weight,
  }) {
    return HealthDataModel(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      waterIntake: waterIntake ?? this.waterIntake,
      sleepHours: sleepHours ?? this.sleepHours,
      weight: weight ?? this.weight,
    );
  }
  
  @override
  String toString() {
    return 'HealthDataModel(userId: $userId, date: $date, steps: $steps, calories: $calories, waterIntake: $waterIntake, sleepHours: $sleepHours)';
  }
}