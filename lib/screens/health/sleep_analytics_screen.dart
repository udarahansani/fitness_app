import 'package:flutter/material.dart';

class SleepAnalyticsScreen extends StatefulWidget {
  const SleepAnalyticsScreen({super.key});

  @override
  State<SleepAnalyticsScreen> createState() => _SleepAnalyticsScreenState();
}

class _SleepAnalyticsScreenState extends State<SleepAnalyticsScreen> {
  int _selectedIndex = 0;
  bool _bedtimeEnabled = true;
  bool _alarmEnabled = true;
  int _selectedDay = 24; // Current selected day
  
  // Sleep calendar data
  final List<Map<String, dynamic>> _sleepCalendar = [
    {'day': 'Tue', 'date': 22},
    {'day': 'Wed', 'date': 23},
    {'day': 'Thu', 'date': 24},
    {'day': 'Fri', 'date': 25},
    {'day': 'Sat', 'date': 26},
    {'day': 'Sun', 'date': 27},
  ];

  // Sleep data
  final String _lastSleepDuration = '09:30';
  final String _bedTimeHours = '7H';
  final String _bedTimeMinutes = '28Min';
  final String _alarmHours = '16H';
  final String _alarmMinutes = '18Min';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sleep Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [],
      ),
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  
                  // Sleep recommendation card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(text: 'You have slept '),
                                TextSpan(
                                  text: _lastSleepDuration,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const TextSpan(text: ' that is\nabove your '),
                                const TextSpan(
                                  text: 'recommendation',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            // Handle close notification
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Sleep Calendar Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Sleep Calendar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Calendar days
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _sleepCalendar.map((dayData) {
                            bool isSelected = dayData['date'] == _selectedDay;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDay = dayData['date'];
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    dayData['day'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.black : Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${dayData['date']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Sleep Settings
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Bed time setting
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1BEE7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.bed,
                                color: Color(0xFF9C27B0),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bed time',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '$_bedTimeHours and $_bedTimeMinutes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _bedtimeEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _bedtimeEnabled = value;
                                });
                              },
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF9C27B0),
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey[400],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Alarm setting
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1BEE7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.alarm,
                                color: Color(0xFF9C27B0),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Alarm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '$_alarmHours and $_alarmMinutes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _alarmEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _alarmEnabled = value;
                                });
                              },
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF9C27B0),
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey[400],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            // Navigate back to home
            Navigator.pop(context);
          } else if (index == 2) {
            // Navigate to AI chat
            Navigator.pushNamed(context, '/ai_chat');
          }
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}