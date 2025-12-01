import 'package:flutter/material.dart';
import 'dart:async';

class JumpingWorkoutScreen extends StatefulWidget {
  const JumpingWorkoutScreen({super.key});

  @override
  State<JumpingWorkoutScreen> createState() => _JumpingWorkoutScreenState();
}

class _JumpingWorkoutScreenState extends State<JumpingWorkoutScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 15;
  bool _isPaused = false;
  int _currentExercise = 1;
  final int _totalExercises = 4;
  
  final List<String> _exercises = [
    'Jumping Jacks',
    'Push-ups',
    'Squats',
    'Burpees'
  ];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _startTimer();
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0 && !_isPaused) {
        setState(() {
          _seconds--;
        });
      } else if (_seconds == 0) {
        _timer?.cancel();
        _showExerciseComplete();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _nextExercise() {
    if (_currentExercise < _totalExercises) {
      setState(() {
        _currentExercise++;
        _seconds = 15;
        _isPaused = false;
      });
      _timer?.cancel();
      _startTimer();
    } else {
      _showWorkoutComplete();
    }
  }

  void _previousExercise() {
    if (_currentExercise > 1) {
      setState(() {
        _currentExercise--;
        _seconds = 15;
        _isPaused = false;
      });
      _timer?.cancel();
      _startTimer();
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showExerciseComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exercise Complete!'),
          content: Text('Great job on exercise $_currentExercise!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _nextExercise();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
              ),
              child: const Text(
                'Next Exercise',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWorkoutComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Workout Complete!'),
          content: const Text('Congratulations! You completed all exercises.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to workout plan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
              ),
              child: const Text(
                'Finish',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
        ),
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         kToolbarHeight,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Timer Display
                Text(
                  _formatTime(_seconds),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Exercise Animation Circle
                Container(
                  width: 240,
                  height: 240,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Jumping Jacks Illustration
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // First figure (arms down)
                              Container(
                                width: 50,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB74D),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Head
                                    CircleAvatar(
                                      radius: 11,
                                      backgroundColor: Color(0xFFD7B084),
                                    ),
                                    SizedBox(height: 2),
                                    // Body
                                    Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Second figure (arms up)
                              Container(
                                width: 50,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB74D),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Head
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Color(0xFFD7B084),
                                    ),
                                    SizedBox(height: 2),
                                    // Body with raised arms
                                    Icon(
                                      Icons.accessibility_new,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Movement arrows
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.green[400],
                                size: 21,
                              ),
                              const SizedBox(width: 30),
                              Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.green[400],
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Exercise Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _exercises[_currentExercise - 1],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Exercise Progress
                Text(
                  'Exercise $_currentExercise of $_totalExercises',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Control Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Previous Button
                      Expanded(
                        child: Container(
                          height: 48,
                          margin: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: _currentExercise > 1 ? _previousExercise : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentExercise > 1 ? const Color(0xFF1565C0) : Colors.grey[300],
                              foregroundColor: _currentExercise > 1 ? Colors.white : Colors.grey[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      
                      // Pause Button
                      Expanded(
                        child: Container(
                          height: 48,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: ElevatedButton(
                            onPressed: _pauseTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isPaused ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _isPaused ? 'Resume' : 'Pause',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      
                      // Next Button
                      Expanded(
                        child: Container(
                          height: 48,
                          margin: const EdgeInsets.only(left: 8),
                          child: ElevatedButton(
                            onPressed: _nextExercise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}