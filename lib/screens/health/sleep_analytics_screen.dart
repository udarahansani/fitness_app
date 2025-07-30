import 'package:flutter/material.dart';
import '../../services/sleep_service.dart';
import '../progress/progress_dashboard_screen.dart';
import '../profile/profile_screen.dart';

class SleepAnalyticsScreen extends StatefulWidget {
  const SleepAnalyticsScreen({super.key});

  @override
  State<SleepAnalyticsScreen> createState() => _SleepAnalyticsScreenState();
}

class _SleepAnalyticsScreenState extends State<SleepAnalyticsScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _weeklyData = [];
  Map<String, dynamic>? _todayData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    setState(() => _isLoading = true);
    
    try {
      final weeklyData = await SleepService.getWeeklySleepData();
      final todayData = await SleepService.getTodaySleepData();
      
      if (mounted) {
        setState(() {
          _weeklyData = weeklyData;
          _todayData = todayData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showTimePickerDialog({
    required String title,
    required bool isBedTime,
  }) async {
    final currentTime = DateTime.now();
    final initialTime = isBedTime 
        ? TimeOfDay(hour: 22, minute: 30) // 10:30 PM default
        : TimeOfDay(hour: 7, minute: 0);  // 7:00 AM default

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C27B0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      await _showDatePickerDialog(selectedTime, isBedTime);
    }
  }

  Future<void> _showDatePickerDialog(TimeOfDay time, bool isBedTime) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C27B0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        time.hour,
        time.minute,
      );

      if (isBedTime) {
        _showWakeUpTimePicker(selectedDate, dateTime);
      }
    }
  }

  Future<void> _showWakeUpTimePicker(DateTime sleepDate, DateTime bedTime) async {
    final wakeUpTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C27B0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (wakeUpTime != null) {
      final wakeUpDateTime = DateTime(
        sleepDate.year,
        sleepDate.month,
        sleepDate.day + (wakeUpTime.hour < bedTime.hour ? 1 : 0), // Next day if wake up is before bed time
        wakeUpTime.hour,
        wakeUpTime.minute,
      );

      await _saveSleepData(sleepDate, bedTime, wakeUpDateTime);
    }
  }

  Future<void> _saveSleepData(DateTime date, DateTime bedTime, DateTime wakeUpTime) async {
    final success = await SleepService.saveSleepData(
      date: date,
      bedTime: bedTime,
      wakeUpTime: wakeUpTime,
    );

    if (success) {
      await _loadSleepData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sleep data saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save sleep data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF9C27B0)),
                          SizedBox(height: 16),
                          Text('Loading sleep data...'),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 30),
                        
                        // Sleep summary card
                        _buildSleepSummaryCard(),
                        
                        const SizedBox(height: 30),
                        
                        // Sleep Calendar Section
                        _buildSleepCalendar(),
                        
                        const SizedBox(height: 30),
                        
                        // Sleep Action Buttons
                        _buildSleepActions(),
                        
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
          } else if (index == 1) {
            // Navigate to Progress Dashboard
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProgressDashboardScreen(),
              ),
            );
          } else if (index == 2) {
            // Navigate to AI chat
            Navigator.pushNamed(context, '/ai_chat');
          } else if (index == 3) {
            // Navigate to Profile
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
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

  Widget _buildSleepSummaryCard() {
    final avgDuration = SleepService.getAverageSleepDuration(_weeklyData);
    final todayDuration = _todayData?['duration'] ?? 0;
    final todayQuality = _todayData?['quality'] ?? 0;
    
    String summaryText;
    if (todayDuration > 0) {
      final durationText = SleepService.formatDuration(todayDuration);
      summaryText = 'You slept $durationText last night';
    } else if (avgDuration > 0) {
      summaryText = 'Your average sleep is ${avgDuration.toStringAsFixed(1)}h per night';
    } else {
      summaryText = 'Start tracking your sleep for better insights';
    }

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summaryText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          if (todayDuration > 0) ...[
            const SizedBox(height: 8),
            Text(
              SleepService.getSleepQualityText(todayQuality),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepCalendar() {
    return Container(
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
          
          // Calendar days from weekly data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _weeklyData.take(6).map((dayData) {
              final date = dayData['date'] as DateTime;
              final isSelected = date.day == _selectedDate.day &&
                                date.month == _selectedDate.month;
              final hasSleepData = dayData['duration'] > 0;
              final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      dayName,
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
                        color: isSelected 
                            ? const Color(0xFF9C27B0)
                            : hasSleepData 
                                ? Colors.green[100]
                                : Colors.grey[200],
                        shape: BoxShape.circle,
                        border: hasSleepData && !isSelected
                            ? Border.all(color: Colors.green, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? Colors.white 
                                : hasSleepData 
                                    ? Colors.green[700]
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          
          // Show selected day details
          if (_weeklyData.any((day) => 
              (day['date'] as DateTime).day == _selectedDate.day &&
              (day['date'] as DateTime).month == _selectedDate.month)) ...[
            const SizedBox(height: 20),
            _buildSelectedDayDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetails() {
    final selectedDayData = _weeklyData.firstWhere(
      (day) => (day['date'] as DateTime).day == _selectedDate.day &&
               (day['date'] as DateTime).month == _selectedDate.month,
      orElse: () => {},
    );

    if (selectedDayData.isEmpty || selectedDayData['duration'] == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'No sleep data for this day',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    final bedTime = selectedDayData['bedTime'] as DateTime;
    final wakeUpTime = selectedDayData['wakeUpTime'] as DateTime;
    final duration = selectedDayData['duration'] as int;
    final quality = selectedDayData['quality'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE1BEE7).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bedtime', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    SleepService.formatTime(bedTime),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Wake up', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    SleepService.formatTime(wakeUpTime),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Duration', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    SleepService.formatDuration(duration),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Quality', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    '$quality%',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      color: quality >= 80 ? Colors.green : quality >= 60 ? Colors.orange : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _showTimePickerDialog(
                title: 'Set Bedtime',
                isBedTime: true,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.bed),
              label: const Text(
                'Log Sleep Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to set your bedtime and wake up time',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}