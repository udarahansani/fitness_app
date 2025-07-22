# MetaWell+ Backend Implementation Plan

## Phase 1: Firebase Setup & Authentication (Week 1)

### 1.1 Firebase Project Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure --project=metawell-fitness
```

### 1.2 Add Firebase Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  # Firebase Core
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  
  # Google Sign In
  google_sign_in: ^6.1.6
  
  # State Management
  provider: ^6.1.1
  
  # HTTP & API calls
  http: ^1.1.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # UI & Charts
  fl_chart: ^0.65.0
  
  # Date handling
  intl: ^0.18.1
```

### 1.3 Firebase Services Configuration
Enable in Firebase Console:
- ✅ Authentication (Email/Password, Google, Facebook, Apple)
- ✅ Firestore Database
- ✅ Storage
- ✅ Analytics (optional)

## Phase 2: Data Models & Architecture (Week 1-2)

### 2.1 User Data Model
```dart
// lib/models/user_model.dart
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
  
  UserModel({...});
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {...}
  Map<String, dynamic> toFirestore() {...}
}
```

### 2.2 Health Data Models
```dart
// lib/models/health_data_model.dart
class HealthDataModel {
  final String userId;
  final DateTime date;
  final int steps;
  final double calories;
  final double waterIntake; // liters
  final double sleepHours;
  final double weight; // kg
  
  HealthDataModel({...});
}

// lib/models/workout_model.dart
class WorkoutModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final int duration; // minutes
  final String difficulty; // beginner, intermediate, advanced
  final List<ExerciseModel> exercises;
  final DateTime createdAt;
  
  WorkoutModel({...});
}

class ExerciseModel {
  final String name;
  final String description;
  final int sets;
  final int reps;
  final double? weight; // kg
  final int? duration; // seconds
  final String? imageUrl;
  
  ExerciseModel({...});
}

// lib/models/nutrition_model.dart
class NutritionModel {
  final String userId;
  final DateTime date;
  final List<FoodEntryModel> meals;
  final double totalCalories;
  final double protein;
  final double carbs;
  final double fat;
  
  NutritionModel({...});
}

class FoodEntryModel {
  final String name;
  final double quantity;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType; // breakfast, lunch, dinner, snack
  
  FoodEntryModel({...});
}
```

## Phase 3: Authentication Implementation (Week 2)

### 3.1 Authentication Service
```dart
// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  
  // Email & Password Authentication
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      // Create user document in Firestore
      await _createUserDocument(result.user!);
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      await _updateLastLogin(result.user!.uid);
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      UserCredential result = await _auth.signInWithCredential(credential);
      await _createUserDocument(result.user!);
      
      return result;
    } catch (e) {
      throw 'Google Sign In Error: $e';
    }
  }
  
  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }
  
  // Helper Methods
  Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      final userData = UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoURL: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await userDoc.set(userData.toFirestore());
    }
  }
  
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
```

### 3.2 Update Login Screen
```dart
// Update lib/screens/auth/login_screen.dart _signIn method
void _signIn() async {
  if (_formKey.currentState!.validate()) {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

// Add Google Sign In method
void _signInWithGoogle() async {
  try {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signInWithGoogle();
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
```

## Phase 4: Health Data Tracking (Week 3)

### 4.1 Health Data Service
```dart
// lib/services/health_data_service.dart
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
  Future<List<HealthDataModel>> getHealthDataRange(DateTime start, DateTime end) async {
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
        .set({'steps': steps, 'date': DateTime.now()}, SetOptions(merge: true));
  }
  
  Future<void> updateWaterIntake(double liters) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc(today)
        .set({'waterIntake': liters, 'date': DateTime.now()}, SetOptions(merge: true));
  }
  
  Future<void> updateSleep(double hours) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .doc(today)
        .set({'sleepHours': hours, 'date': DateTime.now()}, SetOptions(merge: true));
  }
}
```

### 4.2 Update Home Screen Dashboard
```dart
// Update lib/screens/home/home_screen.dart
class _HomeScreenState extends State<HomeScreen> {
  HealthDataService? _healthService;
  HealthDataModel? _todayData;
  
  @override
  void initState() {
    super.initState();
    _initializeHealthService();
    _loadTodayData();
  }
  
  void _initializeHealthService() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _healthService = HealthDataService(userId: user.uid);
    }
  }
  
  Future<void> _loadTodayData() async {
    if (_healthService != null) {
      final data = await _healthService!.getHealthData(DateTime.now());
      setState(() {
        _todayData = data ?? HealthDataModel.defaultForToday();
      });
    }
  }
  
  // Update stat cards with real data
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    String displayValue = value;
    
    if (_todayData != null) {
      switch (title.toLowerCase()) {
        case 'steps':
          displayValue = _todayData!.steps.toString();
          break;
        case 'calories':
          displayValue = _todayData!.calories.toInt().toString();
          break;
        case 'water':
          displayValue = '${_todayData!.waterIntake.toStringAsFixed(1)}L';
          break;
        case 'sleep':
          displayValue = '${_todayData!.sleepHours.toStringAsFixed(1)}h';
          break;
      }
    }
    
    return GestureDetector(
      onTap: () => _showUpdateDialog(title),
      child: Container(
        // ... existing container code ...
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              displayValue,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  // Dialog to update health metrics
  void _showUpdateDialog(String metric) {
    showDialog(
      context: context,
      builder: (context) => UpdateHealthDialog(
        metric: metric,
        onUpdate: (value) async {
          if (_healthService != null) {
            switch (metric.toLowerCase()) {
              case 'steps':
                await _healthService!.updateSteps(value.toInt());
                break;
              case 'water':
                await _healthService!.updateWaterIntake(value);
                break;
              case 'sleep':
                await _healthService!.updateSleep(value);
                break;
            }
            _loadTodayData();
          }
        },
      ),
    );
  }
}
```

## Phase 5: Workout System (Week 4)

### 5.1 Workout Service
```dart
// lib/services/workout_service.dart
class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get predefined workout templates
  Future<List<WorkoutModel>> getWorkoutTemplates() async {
    final query = await _firestore
        .collection('workout_templates')
        .orderBy('difficulty')
        .get();
        
    return query.docs.map((doc) => WorkoutModel.fromFirestore(doc)).toList();
  }
  
  // Save user's custom workout
  Future<void> saveUserWorkout(String userId, WorkoutModel workout) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .add(workout.toFirestore());
  }
  
  // Get user's workout history
  Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('createdAt', descending: true)
        .get();
        
    return query.docs.map((doc) => WorkoutModel.fromFirestore(doc)).toList();
  }
  
  // Record workout completion
  Future<void> recordWorkoutCompletion(String userId, String workoutId, int duration) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workout_history')
        .add({
      'workoutId': workoutId,
      'completedAt': DateTime.now(),
      'duration': duration,
      'caloriesBurned': _calculateCaloriesBurned(duration),
    });
  }
  
  double _calculateCaloriesBurned(int minutes) {
    // Simple calculation: 5 calories per minute (adjust based on user data)
    return minutes * 5.0;
  }
}
```

## Phase 6: Nutrition Tracking (Week 5)

### 6.1 Nutrition Service
```dart
// lib/services/nutrition_service.dart
class NutritionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Save daily nutrition data
  Future<void> saveNutritionData(String userId, NutritionModel nutrition) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(nutrition.date);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('nutrition')
        .doc(dateStr)
        .set(nutrition.toFirestore(), SetOptions(merge: true));
  }
  
  // Add food entry
  Future<void> addFoodEntry(String userId, DateTime date, FoodEntryModel food) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('nutrition')
        .doc(dateStr);
        
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      
      if (doc.exists) {
        final currentData = NutritionModel.fromFirestore(doc);
        final updatedMeals = [...currentData.meals, food];
        final updatedNutrition = currentData.copyWith(meals: updatedMeals);
        transaction.update(docRef, updatedNutrition.toFirestore());
      } else {
        final newNutrition = NutritionModel(
          userId: userId,
          date: date,
          meals: [food],
          totalCalories: food.calories,
          protein: food.protein,
          carbs: food.carbs,
          fat: food.fat,
        );
        transaction.set(docRef, newNutrition.toFirestore());
      }
    });
  }
  
  // Search food database (you can integrate with food API like Spoonacular)
  Future<List<FoodItem>> searchFood(String query) async {
    // This would integrate with a food database API
    // For now, return mock data
    return _getMockFoodItems(query);
  }
}
```

## Phase 7: AI Integration (Week 6)

### 7.1 OpenAI Service
```dart
// lib/services/openai_service.dart
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  final String _apiKey = 'YOUR_OPENAI_API_KEY'; // Store securely
  
  // Generate personalized workout
  Future<WorkoutModel> generateWorkout(UserModel user, String preferences) async {
    final prompt = '''
    Create a workout plan for:
    - Age: ${user.age}
    - Gender: ${user.gender}
    - Fitness Goal: ${user.fitnessGoal}
    - Activity Level: ${user.activityLevel}
    - Preferences: $preferences
    
    Return a JSON workout with exercises, sets, reps, and duration.
    ''';
    
    final response = await _makeRequest(prompt);
    return WorkoutModel.fromAIResponse(response);
  }
  
  // Generate meal plan
  Future<NutritionModel> generateMealPlan(UserModel user, String dietaryRestrictions) async {
    final prompt = '''
    Create a daily meal plan for:
    - Goal: ${user.fitnessGoal}
    - Dietary restrictions: ${user.dietaryRestrictions}
    - Additional preferences: $dietaryRestrictions
    
    Include breakfast, lunch, dinner with macros.
    ''';
    
    final response = await _makeRequest(prompt);
    return NutritionModel.fromAIResponse(response);
  }
  
  // AI Chat for fitness advice
  Future<String> chatWithAI(String userMessage, UserModel user) async {
    final prompt = '''
    You are a personal fitness coach. User profile:
    - Goal: ${user.fitnessGoal}
    - Activity Level: ${user.activityLevel}
    
    User question: $userMessage
    
    Provide helpful, personalized fitness advice.
    ''';
    
    return await _makeRequest(prompt);
  }
  
  Future<String> _makeRequest(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [{'role': 'user', 'content': prompt}],
          'max_tokens': 1000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      
      throw 'API Error: ${response.statusCode}';
    } catch (e) {
      throw 'Failed to get AI response: $e';
    }
  }
}
```

## Phase 8: User Profile & Settings (Week 7)

### 8.1 Profile Service
```dart
// lib/services/profile_service.dart
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update(data);
  }
  
  // Upload profile photo
  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_photos')
        .child('$userId.jpg');
        
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
  
  // Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    
    // Get workout count
    final workouts = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workout_history')
        .where('completedAt', isGreaterThan: thirtyDaysAgo)
        .get();
        
    // Get average daily data
    final healthData = await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .where('date', isGreaterThan: thirtyDaysAgo)
        .get();
        
    return {
      'workoutsCompleted': workouts.docs.length,
      'averageSteps': _calculateAverage(healthData.docs, 'steps'),
      'averageWater': _calculateAverage(healthData.docs, 'waterIntake'),
      'averageSleep': _calculateAverage(healthData.docs, 'sleepHours'),
    };
  }
}
```

## Phase 9: Implementation Timeline

### Week 1: Firebase Setup & Authentication
- ✅ Set up Firebase project
- ✅ Implement email/password auth
- ✅ Add Google Sign In
- ✅ Create user profiles

### Week 2: Data Models & Health Tracking
- ✅ Create all data models
- ✅ Implement health data service
- ✅ Update dashboard with real data
- ✅ Add data input dialogs

### Week 3: Workout System
- ✅ Create workout templates in Firestore
- ✅ Implement workout service
- ✅ Build workout screens
- ✅ Add workout tracking

### Week 4: Nutrition Tracking
- ✅ Implement nutrition service
- ✅ Build food entry screens
- ✅ Add nutrition dashboard
- ✅ Integrate food database

### Week 5: AI Integration
- ✅ Set up OpenAI service
- ✅ Implement AI workout generation
- ✅ Add AI meal planning
- ✅ Create AI chat interface

### Week 6: User Profile & Analytics
- ✅ Build profile screens
- ✅ Add settings and preferences
- ✅ Implement progress tracking
- ✅ Add data visualization

### Week 7: Testing & Polish
- ✅ Comprehensive testing
- ✅ UI/UX improvements
- ✅ Performance optimization
- ✅ Bug fixes

## Getting Started Commands

```bash
# 1. Add Firebase to your project
flutterfire configure

# 2. Add dependencies
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage google_sign_in provider http fl_chart shared_preferences intl

# 3. Get dependencies
flutter pub get

# 4. Run the app
flutter run
```

This plan provides a complete backend implementation for your MetaWell+ fitness app with all the features shown in your UI plus additional functionality like AI integration and comprehensive health tracking.