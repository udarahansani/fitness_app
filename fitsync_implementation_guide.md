# FitSync AI - Complete Implementation Guide

## Phase 1: Environment Setup (Week 1)

### 1.1 Install Flutter
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install
# Add Flutter to your PATH
# Verify installation
flutter doctor
```

### 1.2 Install Required Tools
- **Android Studio** (for Android development)
- **VS Code** with Flutter extension
- **Git** for version control
- **Figma** account for UI design

### 1.3 Create Flutter Project
```bash
flutter create fitsync_ai
cd fitsync_ai
flutter pub get
```

### 1.4 Add Dependencies to pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  http: ^1.1.0
  fl_chart: ^0.65.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  intl: ^0.18.1
```

## Phase 2: Firebase Setup (Week 1-2)

### 2.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Name it "FitSync-AI"
4. Enable Google Analytics (optional)

### 2.2 Configure Firebase for Flutter
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure
```

### 2.3 Initialize Firebase in Flutter
Create `lib/services/firebase_service.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
```

## Phase 3: Project Structure Setup (Week 2)

### 3.1 Create Folder Structure
```
lib/
├── main.dart
├── models/
│   ├── user_model.dart
│   ├── workout_model.dart
│   └── nutrition_model.dart
├── screens/
│   ├── auth/
│   ├── onboarding/
│   ├── dashboard/
│   └── profile/
├── services/
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   └── openai_service.dart
├── widgets/
│   └── custom_widgets.dart
└── utils/
    └── constants.dart
```

### 3.2 Create User Model
```dart
// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final int age;
  final String gender;
  final double weight;
  final String goal;
  final String dietaryType;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.age,
    required this.gender,
    required this.weight,
    required this.goal,
    required this.dietaryType,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'age': age,
      'gender': gender,
      'weight': weight,
      'goal': goal,
      'dietaryType': dietaryType,
    };
  }
  
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      weight: map['weight']?.toDouble() ?? 0.0,
      goal: map['goal'] ?? '',
      dietaryType: map['dietaryType'] ?? '',
    );
  }
}
```

## Phase 4: Authentication System (Week 3)

### 4.1 Create Authentication Service
```dart
// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get currentUser => _auth.currentUser;
  
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }
  
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  Future<void> saveUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }
}
```

### 4.2 Create Login Screen
```dart
// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FitSync AI Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
            TextButton(
              onPressed: _signUp,
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _signIn() async {
    final result = await _authService.signIn(
      _emailController.text,
      _passwordController.text,
    );
    if (result != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }
  
  void _signUp() async {
    final result = await _authService.signUp(
      _emailController.text,
      _passwordController.text,
    );
    if (result != null) {
      Navigator.pushNamed(context, '/onboarding');
    }
  }
}
```

## Phase 5: Onboarding System (Week 3)

### 5.1 Create Onboarding Screen
```dart
// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  int _age = 25;
  String _gender = 'Male';
  double _weight = 70.0;
  String _goal = 'Weight Loss';
  String _dietaryType = 'Regular';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Setup Your Profile')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Age input
              TextFormField(
                initialValue: _age.toString(),
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _age = int.tryParse(value) ?? 25,
              ),
              
              // Gender dropdown
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value!),
              ),
              
              // Weight slider
              Text('Weight: ${_weight.toInt()} kg'),
              Slider(
                value: _weight,
                min: 30,
                max: 150,
                divisions: 120,
                onChanged: (value) => setState(() => _weight = value),
              ),
              
              // Goal dropdown
              DropdownButtonFormField<String>(
                value: _goal,
                decoration: InputDecoration(labelText: 'Fitness Goal'),
                items: ['Weight Loss', 'Muscle Gain', 'Maintenance', 'Endurance']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _goal = value!),
              ),
              
              // Dietary type
              DropdownButtonFormField<String>(
                value: _dietaryType,
                decoration: InputDecoration(labelText: 'Dietary Preference'),
                items: ['Regular', 'Vegetarian', 'Vegan', 'Keto', 'Paleo']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _dietaryType = value!),
              ),
              
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Complete Setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        uid: _authService.currentUser!.uid,
        email: _authService.currentUser!.email!,
        age: _age,
        gender: _gender,
        weight: _weight,
        goal: _goal,
        dietaryType: _dietaryType,
      );
      
      await _authService.saveUserData(user);
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }
}
```

## Phase 6: OpenAI Integration (Week 4-5)

### 6.1 Create OpenAI Service
```dart
// lib/services/openai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _apiKey = 'YOUR_OPENAI_API_KEY';
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  Future<String> generateWorkoutPlan(Map<String, dynamic> userProfile) async {
    final prompt = """
    Create a personalized workout plan for:
    - Age: ${userProfile['age']}
    - Gender: ${userProfile['gender']}
    - Weight: ${userProfile['weight']}kg
    - Goal: ${userProfile['goal']}
    
    Provide a 7-day workout plan with exercises, sets, and reps.
    """;
    
    return await _makeRequest(prompt);
  }
  
  Future<String> generateMealPlan(Map<String, dynamic> userProfile) async {
    final prompt = """
    Create a meal plan for:
    - Goal: ${userProfile['goal']}
    - Dietary Type: ${userProfile['dietaryType']}
    - Weight: ${userProfile['weight']}kg
    
    Provide daily meal suggestions with macronutrient breakdown.
    """;
    
    return await _makeRequest(prompt);
  }
  
  Future<String> chatResponse(String question) async {
    final prompt = "Answer this fitness question: $question";
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
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 500,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      
      return 'Sorry, I could not generate a response.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
```

## Phase 7: Core Features Implementation (Week 5-6)

### 7.1 Water Tracker Widget
```dart
// lib/widgets/water_tracker.dart
import 'package:flutter/material.dart';

class WaterTracker extends StatefulWidget {
  @override
  _WaterTrackerState createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  int _currentIntake = 0;
  int _dailyGoal = 2000; // ml
  
  @override
  Widget build(BuildContext context) {
    double progress = _currentIntake / _dailyGoal;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Water Intake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            SizedBox(height: 10),
            Text('${_currentIntake}ml / ${_dailyGoal}ml'),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _addWater(250),
                  child: Text('+250ml'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addWater(500),
                  child: Text('+500ml'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _addWater(int amount) {
    setState(() {
      _currentIntake += amount;
    });
    // Save to Firebase
  }
}
```

### 7.2 Progress Chart Widget
```dart
// lib/widgets/progress_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressChart extends StatelessWidget {
  final List<double> weeklyData;
  
  ProgressChart({required this.weeklyData});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Phase 8: Dashboard Screen (Week 6)

### 8.1 Main Dashboard
```dart
// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/water_tracker.dart';
import '../../widgets/progress_chart.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FitSync AI'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI Chat'),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildWorkoutTab();
      case 2:
        return _buildNutritionTab();
      case 3:
        return _buildChatTab();
      default:
        return _buildDashboard();
    }
  }
  
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          WaterTracker(),
          SizedBox(height: 16),
          ProgressChart(weeklyData: [1, 3, 2, 5, 4, 6, 5]),
          // Add more widgets
        ],
      ),
    );
  }
  
  Widget _buildWorkoutTab() {
    return Center(child: Text('Workout Plans Coming Soon!'));
  }
  
  Widget _buildNutritionTab() {
    return Center(child: Text('Nutrition Tracker Coming Soon!'));
  }
  
  Widget _buildChatTab() {
    return Center(child: Text('AI Chat Coming Soon!'));
  }
}
```

## Phase 9: Testing & Polish (Week 7-8)

### 9.1 Testing Checklist
- [ ] User registration and login
- [ ] Onboarding flow
- [ ] Water tracking functionality
- [ ] Data persistence in Firebase
- [ ] UI responsiveness
- [ ] OpenAI API integration
- [ ] Navigation between screens

### 9.2 Performance Optimization
- Implement lazy loading for charts
- Add loading indicators
- Optimize Firebase queries
- Add error handling

### 9.3 UI Polish
- Add animations and transitions
- Improve color scheme
- Add icons and illustrations
- Implement dark mode (optional)

## Additional Resources

### Learning Materials
1. **Flutter Documentation**: https://flutter.dev/docs
2. **Firebase for Flutter**: https://firebase.flutter.dev/docs/overview
3. **Dart Language Tour**: https://dart.dev/guides/language/language-tour
4. **Flutter Widget Catalog**: https://flutter.dev/docs/development/ui/widgets

### Useful VS Code Extensions
- Flutter
- Dart
- Firebase
- GitLens

### Testing the App
```bash
# Run on Android emulator
flutter run

# Build APK for testing
flutter build apk

# Run tests
flutter test
```

### Deployment
```bash
# Build for release
flutter build apk --release

# Build for iOS (requires macOS)
flutter build ios --release
```

## Next Steps After Implementation
1. Add more AI features (personalized recommendations)
2. Implement push notifications
3. Add social features (share progress)
4. Integrate with fitness wearables
5. Add premium features
6. Publish to app stores

Remember to replace 'YOUR_OPENAI_API_KEY' with your actual OpenAI API key and configure Firebase properly for your project.