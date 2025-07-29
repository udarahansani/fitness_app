import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Map<String, dynamic>? _userData;
  bool _isCollectingPersonalInfo = false;
  String? _currentQuestionField;
  bool _showStartScreen = true;

  // Replace with your OpenAI API key
  static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    _userData = await authService.getCurrentUserData();
    
    if (_userData != null) {
      _addPersonalizedWelcomeMessage();
    } else {
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text:
            "Hi! I'm your AI fitness coach! 💪\n\nI can help you with:\n• Workout plans and exercises\n• Nutrition advice\n• Fitness goals\n• Health tips\n• Motivation and support\n\nHow can I assist you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _addPersonalizedWelcomeMessage() {
    String userName = _userData?['displayName'] ?? 'there';
    bool hasPersonalInfo = _hasCompletePersonalInfo();
    
    String welcomeText;
    if (hasPersonalInfo) {
      String goal = _userData?['fitnessGoal']?.toString().replaceAll('_', ' ') ?? 'fitness';
      welcomeText = "Hi $userName! 💪\n\nGreat to see you back! I see your goal is $goal. I'm here to help you achieve it.\n\nWhat would you like to work on today?";
    } else {
      welcomeText = "Hi $userName! 💪\n\nTo give you the best personalized fitness advice, I'd love to know more about you. Let me ask a few quick questions to customize my recommendations.\n\nShall we start?";
      _isCollectingPersonalInfo = true;
    }
    
    _messages.add(
      ChatMessage(
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    
    if (_isCollectingPersonalInfo) {
      _askNextPersonalQuestion();
    }
  }

  bool _hasCompletePersonalInfo() {
    if (_userData == null) return false;
    
    return _userData!['age'] != null &&
           _userData!['gender'] != null &&
           _userData!['height'] != null &&
           _userData!['weight'] != null &&
           _userData!['fitnessGoal'] != null &&
           _userData!['activityLevel'] != null;
  }

  void _askNextPersonalQuestion() {
    if (_userData == null) return;
    
    String? questionText;
    String? fieldName;
    
    if (_userData!['age'] == null) {
      questionText = "What's your age? This helps me recommend age-appropriate exercises.";
      fieldName = 'age';
    } else if (_userData!['gender'] == null) {
      questionText = "What's your gender? (Male/Female/Other) This helps with calorie and exercise recommendations.";
      fieldName = 'gender';
    } else if (_userData!['height'] == null) {
      questionText = "What's your height in cm? This helps calculate your BMI and calorie needs.";
      fieldName = 'height';
    } else if (_userData!['weight'] == null) {
      questionText = "What's your current weight in kg? This helps track progress and set realistic goals.";
      fieldName = 'weight';
    } else if (_userData!['fitnessGoal'] == null) {
      questionText = "What's your main fitness goal?\n• Lose weight\n• Gain muscle\n• Maintain current weight\n• General fitness";
      fieldName = 'fitnessGoal';
    } else if (_userData!['activityLevel'] == null) {
      questionText = "How active are you currently?\n• Low (little to no exercise)\n• Medium (1-3 days/week)\n• High (3-5 days/week)\n• Very High (6-7 days/week)";
      fieldName = 'activityLevel';
    }
    
    if (questionText != null && fieldName != null) {
      _currentQuestionField = fieldName;
      _messages.add(
        ChatMessage(
          text: questionText,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      setState(() {});
      _scrollToBottom();
    } else {
      _finishPersonalInfoCollection();
    }
  }

  void _finishPersonalInfoCollection() {
    _isCollectingPersonalInfo = false;
    _currentQuestionField = null;
    
    String goal = _userData?['fitnessGoal']?.toString().replaceAll('_', ' ') ?? 'fitness';
    String completionText = "Perfect! 🎉\n\nNow I have all the information I need to give you personalized advice for your $goal goal. I can help with customized workout plans, nutrition advice, and track your progress.\n\nWhat would you like to start with?";
    
    _messages.add(
      ChatMessage(
        text: completionText,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    setState(() {});
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'AI Fitness Coach',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: _showStartScreen ? [] : [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: _showStartScreen ? _buildStartScreen() : _buildChatInterface(),
    );
  }

  Widget _buildStartScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AI Coach Icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF1565C0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'AI Fitness Coach',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              const Text(
                'Your personal AI trainer ready to help you achieve your fitness goals!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              
              // Features
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Text(
                      'I can help you with:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.fitness_center, color: Color(0xFF1565C0), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Personalized workout plans',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.restaurant, color: Color(0xFF1565C0), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nutrition advice & meal planning',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.track_changes, color: Color(0xFF1565C0), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Progress tracking & motivation',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Color(0xFF1565C0), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Health tips & wellness guidance',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              
              // Start Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _startChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Start Chatting',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5F5F5), Color(0xFFE3F2FD)],
              ),
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
        ),

        // Loading indicator
        if (_isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'AI is thinking...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

        // Message input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(26),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF1565C0).withAlpha(77),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything about fitness...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1565C0),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF1565C0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF1565C0) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Handle personal information collection
      if (_isCollectingPersonalInfo && _currentQuestionField != null) {
        await _processPersonalInfoResponse(text);
      } else {
        // Regular AI response
        final aiResponse = await _getAIResponse(text);
        setState(() {
          _messages.add(
            ChatMessage(
              text: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "Sorry, I'm having trouble connecting right now. Please check your internet connection and try again. 🤖",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<void> _processPersonalInfoResponse(String userResponse) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    String confirmationText = "";
    
    try {
      switch (_currentQuestionField) {
        case 'age':
          int? age = int.tryParse(userResponse);
          if (age != null && age >= 13 && age <= 100) {
            await authService.updateUserProfile({'age': age});
            _userData!['age'] = age;
            confirmationText = "Great! I've recorded your age as $age.";
          } else {
            confirmationText = "Please enter a valid age between 13 and 100.";
            setState(() { _isLoading = false; });
            _messages.add(ChatMessage(text: confirmationText, isUser: false, timestamp: DateTime.now()));
            setState(() {});
            return;
          }
          break;
          
        case 'gender':
          String gender = userResponse.toLowerCase();
          if (gender.contains('male') && !gender.contains('female')) {
            gender = 'Male';
          } else if (gender.contains('female')) {
            gender = 'Female';
          } else if (gender.contains('other') || gender.contains('non-binary')) {
            gender = 'Other';
          } else {
            confirmationText = "Please specify Male, Female, or Other.";
            setState(() { _isLoading = false; });
            _messages.add(ChatMessage(text: confirmationText, isUser: false, timestamp: DateTime.now()));
            setState(() {});
            return;
          }
          await authService.updateUserProfile({'gender': gender});
          _userData!['gender'] = gender;
          confirmationText = "Perfect! I've recorded your gender as $gender.";
          break;
          
        case 'height':
          double? height = double.tryParse(userResponse);
          if (height != null && height >= 100 && height <= 250) {
            await authService.updateUserProfile({'height': height});
            _userData!['height'] = height;
            confirmationText = "Excellent! I've recorded your height as ${height.toStringAsFixed(0)} cm.";
          } else {
            confirmationText = "Please enter a valid height between 100 and 250 cm.";
            setState(() { _isLoading = false; });
            _messages.add(ChatMessage(text: confirmationText, isUser: false, timestamp: DateTime.now()));
            setState(() {});
            return;
          }
          break;
          
        case 'weight':
          double? weight = double.tryParse(userResponse);
          if (weight != null && weight >= 30 && weight <= 300) {
            await authService.updateUserProfile({'weight': weight});
            _userData!['weight'] = weight;
            confirmationText = "Got it! I've recorded your weight as ${weight.toStringAsFixed(1)} kg.";
          } else {
            confirmationText = "Please enter a valid weight between 30 and 300 kg.";
            setState(() { _isLoading = false; });
            _messages.add(ChatMessage(text: confirmationText, isUser: false, timestamp: DateTime.now()));
            setState(() {});
            return;
          }
          break;
          
        case 'fitnessGoal':
          String goal = userResponse.toLowerCase();
          String goalValue;
          if (goal.contains('lose') || goal.contains('weight loss')) {
            goalValue = 'weight_loss';
          } else if (goal.contains('gain') || goal.contains('muscle')) {
            goalValue = 'muscle_gain';
          } else if (goal.contains('maintain')) {
            goalValue = 'maintenance';
          } else if (goal.contains('general') || goal.contains('fitness')) {
            goalValue = 'general_fitness';
          } else {
            confirmationText = "Please choose from: Lose weight, Gain muscle, Maintain current weight, or General fitness.";
            setState(() { _isLoading = false; });
            _messages.add(ChatMessage(text: confirmationText, isUser: false, timestamp: DateTime.now()));
            setState(() {});
            return;
          }
          await authService.updateUserProfile({'fitnessGoal': goalValue});
          _userData!['fitnessGoal'] = goalValue;
          confirmationText = "Awesome! Your fitness goal is ${goalValue.replaceAll('_', ' ')}.";
          break;
          
        case 'activityLevel':
          String activity = userResponse.toLowerCase();
          String activityValue;
          if (activity.contains('low') || activity.contains('sedentary')) {
            activityValue = 'low';
          } else if (activity.contains('medium') || activity.contains('moderate')) {
            activityValue = 'medium';  
          } else if (activity.contains('high') && !activity.contains('very')) {
            activityValue = 'high';
          } else if (activity.contains('very') || activity.contains('very high')) {
            activityValue = 'very_high';
          } else {
            confirmationText = "Please choose from: Low, Medium, High, or Very High.";
            setState(() { _isLoading = false; });
            _messages.add(ChatMessage(text: confirmationText, isUser: false, timestamp: DateTime.now()));
            setState(() {});
            return;
          }
          await authService.updateUserProfile({'activityLevel': activityValue});
          _userData!['activityLevel'] = activityValue;
          confirmationText = "Perfect! Your activity level is $activityValue.";
          break;
      }
      
      setState(() {
        _messages.add(ChatMessage(text: confirmationText, isUser: false, timestamp: DateTime.now()));
        _isLoading = false;
      });
      
      // Ask next question or finish
      await Future.delayed(const Duration(milliseconds: 500));
      _askNextPersonalQuestion();
      
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Sorry, there was an error saving your information. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }
  }

  Future<String> _getAIResponse(String userMessage) async {
    // If no API key is set, return a demo response
    if (_apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API delay
      return _getDemoResponse(userMessage);
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful and motivating AI fitness coach. Provide personalized fitness advice, workout plans, nutrition tips, and motivation. Keep responses friendly, encouraging, and practical. Always prioritize safety and suggest consulting professionals for serious health concerns.',
            },
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Error calling OpenAI API: $e');
      return _getDemoResponse(userMessage);
    }
  }

  String _getDemoResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    String personalizedPrefix = "";
    
    // Add personalized context if available
    if (_userData != null && _hasCompletePersonalInfo()) {
      String name = _userData!['displayName'] ?? '';
      if (name.isNotEmpty) {
        personalizedPrefix = "$name, ";
      }
    }

    if (message.contains('workout') || message.contains('exercise')) {
      String response = "${personalizedPrefix}great question about workouts! 💪\n\n";
      
      if (_userData != null && _userData!['activityLevel'] != null) {
        String activityLevel = _userData!['activityLevel'];
        switch (activityLevel) {
          case 'low':
            response += "Since you're currently at a low activity level, I recommend starting slowly:\n• 2-3 days per week\n• 20-30 minutes per session\n• Focus on walking and light bodyweight exercises\n• Gradually increase intensity";
            break;
          case 'medium':
            response += "With your medium activity level, you can handle:\n• 3-4 days per week\n• 30-45 minutes per session\n• Mix of cardio and strength training\n• Progressive overload";
            break;
          case 'high':
            response += "Given your high activity level:\n• 4-5 days per week\n• 45-60 minutes per session\n• Advanced exercises and variations\n• Focus on specific goals";
            break;
          case 'very_high':
            response += "With your very high activity level:\n• 5-6 days per week\n• Structured training programs\n• Athletic performance focus\n• Recovery optimization";
            break;
          default:
            response += "For beginners, I recommend starting with:\n• 3 days per week\n• 30-45 minutes per session\n• Mix of cardio and strength training\n• Always warm up and cool down";
        }
      } else {
        response += "For beginners, I recommend starting with:\n• 3 days per week\n• 30-45 minutes per session\n• Mix of cardio and strength training\n• Always warm up and cool down";
      }
      
      response += "\n\nWould you like a specific workout plan?";
      return response;
      
    } else if (message.contains('diet') ||
        message.contains('nutrition') ||
        message.contains('food')) {
      String response = "${personalizedPrefix}nutrition is key to reaching your fitness goals! 🥗\n\n";
      
      if (_userData != null && _userData!['fitnessGoal'] != null) {
        String goal = _userData!['fitnessGoal'];
        switch (goal) {
          case 'weight_loss':
            response += "For weight loss:\n• Create a moderate calorie deficit\n• High protein (0.8-1g per kg body weight)\n• Plenty of vegetables and fiber\n• Avoid liquid calories\n• Meal prep for consistency";
            break;
          case 'muscle_gain':
            response += "For muscle gain:\n• Eat in a slight calorie surplus\n• High protein (1.2-1.6g per kg body weight)\n• Complex carbs around workouts\n• Healthy fats for hormones\n• Frequent meals";
            break;
          case 'maintenance':
            response += "For maintenance:\n• Balanced macronutrients\n• Focus on whole foods\n• Listen to hunger cues\n• Stay hydrated\n• Flexible approach";
            break;
          default:
            response += "General tips:\n• Eat protein with every meal\n• Include plenty of vegetables\n• Stay hydrated (8+ glasses water/day)\n• Avoid processed foods\n• Plan your meals ahead";
        }
      } else {
        response += "General tips:\n• Eat protein with every meal\n• Include plenty of vegetables\n• Stay hydrated (8+ glasses water/day)\n• Avoid processed foods\n• Plan your meals ahead";
      }
      
      return response;
      
    } else if (message.contains('weight') ||
        message.contains('lose') ||
        message.contains('gain')) {
      String response = "${personalizedPrefix}weight management is about consistency! ⚖️\n\n";
      
      if (_userData != null && _userData!['weight'] != null && _userData!['height'] != null) {
        double weight = _userData!['weight'].toDouble();
        double height = _userData!['height'].toDouble() / 100; // convert cm to m
        double bmi = weight / (height * height);
        
        response += "Based on your stats (BMI: ${bmi.toStringAsFixed(1)}):\n";
        if (bmi < 18.5) {
          response += "• Consider gradual weight gain\n• Focus on nutrient-dense foods\n• Strength training for muscle";
        } else if (bmi >= 18.5 && bmi < 25) {
          response += "• You're in a healthy weight range\n• Focus on body composition\n• Maintain with balanced nutrition";
        } else {
          response += "• Gradual weight loss recommended\n• Create sustainable calorie deficit\n• Combine cardio and strength training";
        }
      } else {
        response += "Key principles:\n• Create a sustainable calorie deficit/surplus\n• Focus on whole foods\n• Strength training preserves muscle\n• Be patient - 1-2 lbs per week is healthy\n• Track your progress";
      }
      
      return response;
      
    } else if (message.contains('motivation') ||
        message.contains('tired') ||
        message.contains('give up')) {
      return "${personalizedPrefix}I believe in you! 🌟\n\nRemember:\n• Every workout counts\n• Progress isn't always linear\n• Small steps lead to big changes\n• You're stronger than you think\n• Rest is part of the process\n\nWhat's challenging you right now?";
    } else {
      return "${personalizedPrefix}thanks for your question! 🤖\n\nI'm here to help with your fitness journey. I can assist with:\n• Workout routines\n• Nutrition advice\n• Goal setting\n• Motivation\n• Health tips\n\nNote: For a more personalized experience, add your OpenAI API key in the app settings.\n\nWhat specific fitness topic would you like to explore?";
    }
  }

  void _startChat() async {
    setState(() {
      _showStartScreen = false;
    });
    await _loadUserData();
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _isCollectingPersonalInfo = false;
      _currentQuestionField = null;
      _showStartScreen = true;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
