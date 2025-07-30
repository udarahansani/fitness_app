import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/profile_screen.dart';
import '../../services/sleep_service.dart';
import '../../services/nutrition_service.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_model.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  int _selectedIndex = 1; // Progress tab is selected
  
  // Real data from services
  List<Map<String, dynamic>> _sleepWeeklyData = [];
  List<Map<String, dynamic>> _nutritionWeeklyData = [];
  UserModel? _userProfile;
  bool _isLoading = true;

  // Workout consistency data (7 days) - keeping this as sample for now
  final List<String> _weekDays = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
  final List<bool> _workoutCompleted = [true, false, true, true, false, true, false];

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load user profile
      final userProfile = await UserProfileService.getUserProfile();
      
      // Load sleep data
      final sleepData = await SleepService.getWeeklySleepData();
      
      // Load nutrition data for the past 7 days
      final nutritionData = await _loadWeeklyNutritionData();
      
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _sleepWeeklyData = sleepData;
          _nutritionWeeklyData = nutritionData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadWeeklyNutritionData() async {
    List<Map<String, dynamic>> weeklyData = [];
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('Weekly nutrition: No user ID');
        return weeklyData;
      }
      
      debugPrint('Loading weekly nutrition data for user: $userId');
      
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) {
        debugPrint('Weekly nutrition: User document does not exist');
        return weeklyData;
      }
      
      final nutritionData = doc.data()?['nutrition_data'] ?? {};
      debugPrint('Weekly nutrition: Found nutrition_data keys: ${nutritionData.keys.toList()}');
      
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        final dayData = nutritionData[dateString];
        debugPrint('Weekly nutrition: Checking date $dateString - found data: ${dayData != null}');
        
        if (dayData != null && dayData['current_intake'] != null) {
          final currentIntake = dayData['current_intake'];
          final protein = (currentIntake['protein'] ?? 0.0).toDouble();
          final fat = (currentIntake['fat'] ?? 0.0).toDouble();
          final carbs = (currentIntake['carbs'] ?? 0.0).toDouble();
          
          debugPrint('Weekly nutrition: $dateString - P:$protein, F:$fat, C:$carbs');
          
          weeklyData.add({
            'date': date,
            'protein': protein,
            'fat': fat,
            'carbs': carbs,
          });
        } else {
          // No data for this day
          debugPrint('Weekly nutrition: $dateString - No data found');
          weeklyData.add({
            'date': date,
            'protein': 0.0,
            'fat': 0.0,
            'carbs': 0.0,
          });
        }
      }
      
      final totalEntries = weeklyData.length;
      final entriesWithData = weeklyData.where((day) => 
        (day['protein'] as double) > 0 || 
        (day['fat'] as double) > 0 || 
        (day['carbs'] as double) > 0
      ).length;
      
      debugPrint('Weekly nutrition: Loaded $totalEntries days, $entriesWithData with data');
      
    } catch (e) {
      debugPrint('Error loading weekly nutrition data: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      
      // Return structure for 7 days even if error occurs
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        weeklyData.add({
          'date': date,
          'protein': 0.0,
          'fat': 0.0,
          'carbs': 0.0,
        });
      }
    }
    
    return weeklyData;
  }

  // Clear ALL nutrition data to reset fake values
  Future<void> _clearTodayData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      debugPrint('Clearing all nutrition data for user: $userId');

      // Remove ALL nutrition data completely
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'nutrition_data': FieldValue.delete(),
        'updatedAt': DateTime.now(),
      });

      debugPrint('Successfully cleared all nutrition data');

      // Refresh the dashboard
      await _loadProgressData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All nutrition data cleared! Start fresh by logging real food.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      debugPrint('Error clearing nutrition data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to clear data. Please try again.'),
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
          'Progress Dashboard',
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
                          CircularProgressIndicator(color: Color(0xFF1565C0)),
                          SizedBox(height: 16),
                          Text('Loading progress data...'),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Workout Consistency Section
                          _buildWorkoutConsistencyCard(),
                          const SizedBox(height: 20),
                          
                          // Sleep Section
                          _buildSleepCard(),
                          const SizedBox(height: 20),
                          
                          // Nutrient Intake Progress Section
                          _buildNutrientIntakeCard(),
                          const SizedBox(height: 30),
                          
                          // Export Weekly Report Button
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _exportWeeklyReport,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF42A5F5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Export Weekly Report',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            // Navigate to home
            Navigator.pop(context);
          } else if (index == 2) {
            // Navigate to AI chat
            Navigator.pushNamed(context, '/ai_chat');
          } else if (index == 3) {
            // Navigate to profile
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

  Widget _buildWorkoutConsistencyCard() {
    return Container(
      width: double.infinity,
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
            'Workout Consistency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Text(
                    _weekDays[index].substring(0, 3).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _workoutCompleted[index] 
                          ? const Color(0xFF42A5F5) 
                          : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard() {
    // Convert sleep data to chart format
    final sleepDataPoints = _sleepWeeklyData.map((day) {
      final duration = day['duration'] ?? 0;
      return duration / 60.0; // Convert minutes to hours
    }).toList();
    
    final sleepLabels = _sleepWeeklyData.map((day) {
      final date = day['date'] as DateTime;
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
    }).toList();
    
    // Calculate average sleep
    final avgSleep = _sleepWeeklyData.isNotEmpty 
        ? SleepService.getAverageSleepDuration(_sleepWeeklyData)
        : 0.0;
    
    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sleep',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (avgSleep > 0)
                Text(
                  'Avg: ${avgSleep.toStringAsFixed(1)}h',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _sleepWeeklyData.isEmpty 
                ? 'No sleep data yet'
                : 'Weekly sleep pattern',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          
          // Sleep chart
          if (_sleepWeeklyData.isNotEmpty && sleepDataPoints.any((hours) => hours > 0))
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sleepLabels.length) {
                            return const Text('');
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              sleepLabels[index],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (sleepDataPoints.length - 1).toDouble(),
                  minY: 0,
                  maxY: 12,
                  lineBarsData: [
                    LineChartBarData(
                      spots: sleepDataPoints.asMap().entries.where((e) => e.value > 0).map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFF9C27B0),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF9C27B0).withValues(alpha: 0.3),
                            const Color(0xFF9C27B0).withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bedtime, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No sleep data to display',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start logging your sleep in Sleep Analytics',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNutrientIntakeCard() {
    return Container(
      width: double.infinity,
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
            'Nutrient Intake Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          
          // Get today's nutrition data for charts
          FutureBuilder<Map<String, dynamic>>(
            future: _userProfile != null 
                ? NutritionService.getMacroData(_userProfile)
                : Future.value({'targets': {}, 'current': {}, 'food_log': []}),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final macroData = snapshot.data!;
              final targets = macroData['targets'] ?? {};
              final current = macroData['current'] ?? {};
              
              final proteinCurrent = (current['protein'] ?? 0.0).toDouble();
              final fatCurrent = (current['fat'] ?? 0.0).toDouble();
              final carbsCurrent = (current['carbs'] ?? 0.0).toDouble();
              
              final proteinTarget = (targets['protein'] ?? 0.0).toDouble();
              final fatTarget = (targets['fat'] ?? 0.0).toDouble();
              final carbsTarget = (targets['carbs'] ?? 0.0).toDouble();
              
              final totalCurrent = proteinCurrent + fatCurrent + carbsCurrent;
              final totalTarget = proteinTarget + fatTarget + carbsTarget;
              final hasCurrentData = totalCurrent > 0;
              final hasTargets = totalTarget > 0;
              
              // Debug info
              debugPrint('Progress Dashboard - Real Data:');
              debugPrint('Protein: ${proteinCurrent}g / ${proteinTarget}g');
              debugPrint('Fat: ${fatCurrent}g / ${fatTarget}g'); 
              debugPrint('Carbs: ${carbsCurrent}g / ${carbsTarget}g');
              debugPrint('Total current: ${totalCurrent}g, Total target: ${totalTarget}g');
              
              if (!hasCurrentData) {
                return _buildEmptyNutritionState();
              }
              
              if (!hasTargets) {
                debugPrint('Progress Dashboard - No targets calculated! User profile might be incomplete.');
              }
              
              return Column(
                children: [
                  // Today's Macro Distribution Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today\'s Macro Distribution',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Text(
                          'REAL DATA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Macro distribution pie chart and progress
                  Row(
                    children: [
                      // Pie chart with center label
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 160,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: const Color(0xFF4CAF50),
                                      value: proteinCurrent,
                                      title: '${((proteinCurrent / totalCurrent * 100).clamp(0, 100)).toInt()}%',
                                      radius: 55,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(color: Colors.black26, blurRadius: 2),
                                        ],
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: const Color(0xFFFF9800),
                                      value: carbsCurrent,
                                      title: '${((carbsCurrent / totalCurrent * 100).clamp(0, 100)).toInt()}%',
                                      radius: 55,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(color: Colors.black26, blurRadius: 2),
                                        ],
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: const Color(0xFF2196F3),
                                      value: fatCurrent,
                                      title: '${((fatCurrent / totalCurrent * 100).clamp(0, 100)).toInt()}%',
                                      radius: 55,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(color: Colors.black26, blurRadius: 2),
                                        ],
                                      ),
                                    ),
                                  ],
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 30,
                                ),
                              ),
                              // Center label showing total intake
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${totalCurrent.toInt()}g',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Progress bars with real data
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Goals Progress',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMacroProgressBar(
                              'Protein',
                              proteinCurrent,
                              proteinTarget,
                              const Color(0xFF4CAF50),
                            ),
                            const SizedBox(height: 12),
                            _buildMacroProgressBar(
                              'Carbs',
                              carbsCurrent,
                              carbsTarget,
                              const Color(0xFFFF9800),
                            ),
                            const SizedBox(height: 12),
                            _buildMacroProgressBar(
                              'Fat',
                              fatCurrent,
                              fatTarget,
                              const Color(0xFF2196F3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Weekly trend chart
                  _buildWeeklyNutritionChart(),
                    
                  const SizedBox(height: 16),
                  
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Protein', const Color(0xFF4CAF50)),
                      const SizedBox(width: 20),
                      _buildLegendItem('Carbs', const Color(0xFFFF9800)),
                      const SizedBox(width: 20),
                      _buildLegendItem('Fat', const Color(0xFF2196F3)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildMacroProgressBar(String label, double current, double target, Color color) {
    final percentage = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentageInt = (percentage * 100).clamp(0, 100).toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              target > 0 ? '${current.toInt()}g / ${target.toInt()}g' : '${current.toInt()}g / No target',
              style: TextStyle(
                fontSize: 12,
                color: target > 0 ? Colors.grey[600] : Colors.orange[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$percentageInt%',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeeklyNutritionChart() {
    // Use loaded weekly data or create default 7-day structure
    final chartData = _nutritionWeeklyData.isNotEmpty 
        ? _nutritionWeeklyData.take(7).toList()
        : List.generate(7, (index) {
            final date = DateTime.now().subtract(Duration(days: 6 - index));
            return {
              'date': date,
              'protein': 0.0,
              'fat': 0.0,
              'carbs': 0.0,
            };
          });
    
    // Check if we have any actual data to display
    final hasAnyData = chartData.any((day) => 
        (day['protein'] as double) > 0 || 
        (day['fat'] as double) > 0 || 
        (day['carbs'] as double) > 0);
    
    // Check if only today has data
    final todayIndex = chartData.length - 1;
    final todayData = chartData.isNotEmpty ? chartData[todayIndex] : null;
    final hasTodayData = todayData != null && (
        (todayData['protein'] as double) > 0 || 
        (todayData['fat'] as double) > 0 || 
        (todayData['carbs'] as double) > 0);
    
    final onlyTodayHasData = hasTodayData && chartData.take(6).every((day) => 
        (day['protein'] as double) == 0 && 
        (day['fat'] as double) == 0 && 
        (day['carbs'] as double) == 0);
        
    debugPrint('Weekly chart: hasAnyData=$hasAnyData, hasTodayData=$hasTodayData, onlyTodayHasData=$onlyTodayHasData');
    
    // Find maximum value for proper scaling
    double maxValue = 50.0; // Minimum scale
    for (final day in chartData) {
      final protein = (day['protein'] as double?) ?? 0.0;
      final carbs = (day['carbs'] as double?) ?? 0.0;
      final fat = (day['fat'] as double?) ?? 0.0;
      final dayMax = [protein, carbs, fat].reduce((a, b) => a > b ? a : b);
      if (dayMax > maxValue) maxValue = dayMax;
    }
    maxValue = (maxValue * 1.1).ceilToDouble(); // Add 10% padding
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weekly Intake Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (hasAnyData)
              Text(
                onlyTodayHasData ? 'Today\'s data only' : 'Last 7 days',
                style: TextStyle(
                  fontSize: 12,
                  color: onlyTodayHasData ? Colors.orange[600] : Colors.grey[600],
                  fontWeight: onlyTodayHasData ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (!hasAnyData)
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_up, size: 32, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No weekly data available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Start logging meals to see trends',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Refresh the progress data
                          _loadProgressData();
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _clearTodayData,
                        icon: const Icon(Icons.delete_forever, size: 16),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= chartData.length) {
                          return const Text('');
                        }
                        final date = chartData[index]['date'] as DateTime;
                        final today = DateTime.now();
                        final isToday = date.year == today.year && 
                                       date.month == today.month && 
                                       date.day == today.day;
                        
                        final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            isToday ? 'Today' : dayName,
                            style: TextStyle(
                              color: isToday ? const Color(0xFF1565C0) : Colors.grey[600],
                              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                              fontSize: isToday ? 12 : 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxValue / 4,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}g',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (chartData.length - 1).toDouble(),
                minY: 0,
                maxY: maxValue,
                lineBarsData: [
                  // Protein line
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) {
                      final protein = (e.value['protein'] as double?) ?? 0.0;
                      return FlSpot(e.key.toDouble(), protein);
                    }).where((spot) => spot.y >= 0).toList(),
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF4CAF50),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                  // Carbs line
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) {
                      final carbs = (e.value['carbs'] as double?) ?? 0.0;
                      return FlSpot(e.key.toDouble(), carbs);
                    }).where((spot) => spot.y >= 0).toList(),
                    isCurved: true,
                    color: const Color(0xFFFF9800),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFFFF9800),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                  // Fat line
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) {
                      final fat = (e.value['fat'] as double?) ?? 0.0;
                      return FlSpot(e.key.toDouble(), fat);
                    }).where((spot) => spot.y >= 0).toList(),
                    isCurved: true,
                    color: const Color(0xFF2196F3),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF2196F3),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildEmptyNutritionState() {
    return SizedBox(
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No nutrition data logged today',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log your meals to see real nutrition progress\n(Start with 0% and build up with actual food)',
                style: TextStyle(
                  color: Colors.grey[500], 
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/nutrition_tracker');
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Log Food'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _exportWeeklyReport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Report'),
          content: const Text('Your weekly progress report has been generated successfully!'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}