import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top curved section with gradient
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE3F2FD), // Very light blue
                      Color(0xFFBBDEFB), // Light blue
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Curved design elements
                    Positioned(
                      top: -50,
                      left: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      right: -100,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Main content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Muscle/Flexing arm icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                ),
                                child: CustomPaint(
                                  painter: FlexingArmPainter(),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                ),
                                child: CustomPaint(
                                  painter: FlexingArmPainter(isRight: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // App name with custom styling
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person,
                                size: 24,
                                color: Colors.black87,
                              ),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'META',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'WELL',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black87,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                '+',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom section with light blue background
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD), // Light blue background
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Welcome text
                      const Text(
                        'Begin your wellness',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2), // Darker blue
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'journey with Meta-Well....',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1976D2), // Darker blue
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2), // Blue button
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF666666),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for flexing arm icons
class FlexingArmPainter extends CustomPainter {
  final bool isRight;
  
  FlexingArmPainter({this.isRight = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    if (isRight) {
      // Right flexing arm
      path.moveTo(size.width * 0.2, size.height * 0.7);
      path.quadraticBezierTo(
        size.width * 0.3, size.height * 0.5,
        size.width * 0.5, size.height * 0.4,
      );
      path.quadraticBezierTo(
        size.width * 0.7, size.height * 0.3,
        size.width * 0.8, size.height * 0.2,
      );
      
      // Bicep curve
      path.moveTo(size.width * 0.4, size.height * 0.35);
      path.quadraticBezierTo(
        size.width * 0.45, size.height * 0.25,
        size.width * 0.6, size.height * 0.3,
      );
    } else {
      // Left flexing arm (mirrored)
      path.moveTo(size.width * 0.8, size.height * 0.7);
      path.quadraticBezierTo(
        size.width * 0.7, size.height * 0.5,
        size.width * 0.5, size.height * 0.4,
      );
      path.quadraticBezierTo(
        size.width * 0.3, size.height * 0.3,
        size.width * 0.2, size.height * 0.2,
      );
      
      // Bicep curve
      path.moveTo(size.width * 0.6, size.height * 0.35);
      path.quadraticBezierTo(
        size.width * 0.55, size.height * 0.25,
        size.width * 0.4, size.height * 0.3,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
