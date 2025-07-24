import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  
  // Profile info
  final int? age;
  final String? gender;
  final double? height; // cm
  final double? weight; // kg
  final String? fitnessGoal; // weight_loss, muscle_gain, maintenance
  final String? activityLevel; // sedentary, light, moderate, active, very_active
  final List<String>? dietaryRestrictions;
  
  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.fitnessGoal,
    this.activityLevel,
    this.dietaryRestrictions,
  });
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      age: data['age'],
      gender: data['gender'],
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      fitnessGoal: data['fitnessGoal'],
      activityLevel: data['activityLevel'],
      dietaryRestrictions: data['dietaryRestrictions'] != null
          ? List<String>.from(data['dietaryRestrictions'])
          : null,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'fitnessGoal': fitnessGoal,
      'activityLevel': activityLevel,
      'dietaryRestrictions': dietaryRestrictions,
    };
  }
  
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? activityLevel,
    List<String>? dietaryRestrictions,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
    );
  }
  
  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
  }
}