import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_edit_screen.dart';
import '../progress/progress_dashboard_screen.dart';
import '../../services/auth_service.dart';
import '../../services/profile_picture_service.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3; // Profile tab is selected
  bool _darkTheme = false;
  bool _notifications = true;
  bool _isUploadingImage = false;
  
  // User profile data
  UserModel? _userProfile;
  Map<String, dynamic>? _userData; // Keep this for backward compatibility
  final ProfilePictureService _profilePictureService = ProfilePictureService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      print('Starting to load user data...');
      
      // Get Firebase Auth user first
      final firebaseUser = FirebaseAuth.instance.currentUser;
      print('Firebase user: ${firebaseUser?.email}, UID: ${firebaseUser?.uid}');
      
      // Force fresh data by adding a small delay to ensure Firebase has processed updates
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Load user profile from UserProfileService (primary source)
      final userProfile = await UserProfileService.getUserProfile();
      print('UserProfile loaded: ${userProfile != null}');
      
      // Load fresh data directly from Firestore as backup
      Map<String, dynamic>? userData;
      if (firebaseUser != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();
          if (doc.exists) {
            userData = doc.data();
            print('Fresh Firestore data loaded: ${userData != null}');
          }
        } catch (e) {
          print('Error loading fresh Firestore data: $e');
        }
      }
      
      // If no profile exists, create one with available data
      if (userProfile == null) {
        print('No UserProfile found. Creating basic profile...');
        
        // Use Firebase Auth user data as fallback
        final basicData = userData ?? {
          'email': firebaseUser?.email ?? '',
          'displayName': firebaseUser?.displayName ?? firebaseUser?.email?.split('@')[0] ?? 'User',
          'photoURL': firebaseUser?.photoURL,
        };
        
        await _createBasicProfile(basicData);
        
        // Reload after creating basic profile
        final newUserProfile = await UserProfileService.getUserProfile();
        print('New profile created: ${newUserProfile != null}');
        
        setState(() {
          _userProfile = newUserProfile;
          _userData = basicData;
        });
      } else {
        setState(() {
          _userProfile = userProfile;
          _userData = userData;
        });
      }
      
      // Debug: Print loaded data
      print('=== Profile Screen Loaded Data ===');
      print('UserProfile is null: ${userProfile == null}');
      print('UserData is null: ${userData == null}');
      
      if (userProfile != null) {
        print('Profile - Name: "${userProfile.displayName}"');
        print('Profile - Age: ${userProfile.age}');
        print('Profile - Gender: "${userProfile.gender}"');
        print('Profile - Weight: ${userProfile.weight}');
        print('Profile - Height: ${userProfile.height}');
        print('Profile - Fitness Goal: "${userProfile.fitnessGoal}"');
        print('Profile - Activity Level: "${userProfile.activityLevel}"');
        print('Profile - Profile Picture: "${userProfile.profilePictureUrl}"');
      } else {
        print('UserProfile is NULL!');
      }
      
      if (userData != null) {
        print('Fresh Firestore Data:');
        print('  Name: "${userData['displayName']}"');
        print('  Age: ${userData['age']}');
        print('  Gender: "${userData['gender']}"');
        print('  Weight: ${userData['weight']}');
        print('  Height: ${userData['height']}');
        print('  Fitness Goal: "${userData['fitnessGoal']}"');
        print('  Activity Level: "${userData['activityLevel']}"');
      } else {
        print('UserData is NULL!');
      }
      print('==================================');
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _createBasicProfile(Map<String, dynamic> userData) async {
    try {
      print('Creating basic profile with data: $userData');
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // Create basic profile data with defaults
      final basicProfileData = {
        'displayName': userData['displayName'] ?? currentUser?.displayName ?? userData['email']?.split('@')[0] ?? 'User',
        'email': userData['email'] ?? currentUser?.email ?? '',
        'age': userData['age'],
        'gender': userData['gender'],
        'height': userData['height'],
        'weight': userData['weight'],
        'fitnessGoal': userData['fitnessGoal'],
        'activityLevel': userData['activityLevel'],
        'profilePictureUrl': userData['profilePictureUrl'],
        'photoURL': userData['photoURL'] ?? currentUser?.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      };
      
      print('Saving profile data: $basicProfileData');
      
      // Use AuthService for initial profile creation (handles document creation)
      await authService.updateUserProfile(basicProfileData);
      print('Basic profile created successfully');
      
      // Small delay to ensure Firebase processes the data
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error creating basic profile: $e');
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
          'Profile & Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFE3F2FD),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Profile Image
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: (_userProfile?.profilePictureUrl ?? _userData?['profilePictureUrl']) != null
                          ? DecorationImage(
                              image: NetworkImage(_userProfile?.profilePictureUrl ?? _userData!['profilePictureUrl']),
                              fit: BoxFit.cover,
                            )
                          : (_userProfile?.photoURL ?? _userData?['photoURL']) != null
                              ? DecorationImage(
                                  image: NetworkImage(_userProfile?.photoURL ?? _userData!['photoURL']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (_userProfile?.profilePictureUrl ?? _userData?['profilePictureUrl']) == null && 
                           (_userProfile?.photoURL ?? _userData?['photoURL']) == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  if (_isUploadingImage)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withAlpha(128),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _showImagePickerDialog,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1565C0),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // User Info
              Column(
                children: [
                  Text(
                    _userProfile?.displayName ?? _userData?['displayName'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if ((_userProfile?.age ?? _userData?['age']) != null) ...[
                        Text(
                          '${_userProfile?.age ?? _userData!['age']} years old',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                      if ((_userProfile?.gender ?? _userData?['gender']) != null)
                        Text(
                          (_userProfile?.gender ?? _userData!['gender']).toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Edit Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Debug: Print what we're passing to edit screen
                      print('=== Navigating to Edit Screen ===');
                      
                      // Get current Firebase user as fallback
                      final currentUser = FirebaseAuth.instance.currentUser;
                      
                      final name = _userProfile?.displayName ?? _userData?['displayName'] ?? currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'User';
                      final age = (_userProfile?.age ?? _userData?['age'])?.toString() ?? '25';
                      final gender = _userProfile?.gender ?? _userData?['gender'] ?? 'Male';
                      
                      // Handle weight and height properly - only convert to string if not null
                      String? weight;
                      if (_userProfile?.weight != null) {
                        weight = _userProfile!.weight.toString();
                      } else if (_userData?['weight'] != null) {
                        weight = _userData!['weight'].toString();
                      }
                      
                      String? height;
                      if (_userProfile?.height != null) {
                        height = _userProfile!.height.toString();
                      } else if (_userData?['height'] != null) {
                        height = _userData!['height'].toString();
                      }
                      
                      final fitnessGoal = _userProfile?.fitnessGoal ?? _userData?['fitnessGoal'];
                      final activityLevel = _userProfile?.activityLevel ?? _userData?['activityLevel'];
                      
                      String? profilePictureUrl;
                      if (_userProfile?.profilePictureUrl != null) {
                        profilePictureUrl = _userProfile!.profilePictureUrl;
                      } else if (_userData?['profilePictureUrl'] != null) {
                        profilePictureUrl = _userData!['profilePictureUrl'];
                      } else if (currentUser?.photoURL != null) {
                        profilePictureUrl = currentUser!.photoURL;
                      }
                      
                      print('Passing to edit screen:');
                      print('  Name: "$name"');
                      print('  Age: "$age"');
                      print('  Gender: "$gender"');
                      print('  Weight: ${weight ?? "null"}');
                      print('  Height: ${height ?? "null"}');
                      print('  Fitness Goal: ${fitnessGoal ?? "null"}');
                      print('  Activity Level: ${activityLevel ?? "null"}');
                      print('  Profile Picture: ${profilePictureUrl ?? "null"}');
                      print('================================');
                      
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProfileEditScreen(
                              name: name,
                              age: age,
                              gender: gender,
                              weight: weight,
                              height: height,
                              fitnessGoal: fitnessGoal,
                              activityLevel: activityLevel,
                              profilePictureUrl: profilePictureUrl,
                            );
                          },
                        ),
                      );
                      
                      if (result != null) {
                        print('Profile was updated, reloading user data...');
                        
                        // Clear current data to force refresh
                        setState(() {
                          _userProfile = null;
                          _userData = null;
                        });
                        
                        // Wait longer for Firebase to propagate changes
                        print('Waiting for Firebase to propagate changes...');
                        await Future.delayed(const Duration(milliseconds: 500));
                        
                        if (!mounted) return;
                        
                        // Reload user data
                        print('Fetching fresh data from Firebase...');
                        await _loadUserData();
                        
                        if (!mounted) return;
                        
                        print('Profile data reloaded after update');
                        
                        // Show success notification
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile refreshed with latest data!'),
                              backgroundColor: Colors.blue,
                              duration: Duration(seconds: 2),
                            ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.black26,
              ),
              
              const SizedBox(height: 30),
              
              // Preferences Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Units Setting
                    _buildPreferenceItem(
                      icon: Icons.straighten,
                      title: 'Units',
                      hasSwitch: false,
                      onTap: () {
                        _showUnitsDialog();
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Theme Setting
                    _buildPreferenceItem(
                      icon: Icons.palette,
                      title: 'Theme',
                      hasSwitch: true,
                      switchValue: _darkTheme,
                      onSwitchChanged: (value) {
                        setState(() {
                          _darkTheme = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Notifications Setting
                    _buildPreferenceItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      hasSwitch: true,
                      switchValue: _notifications,
                      onSwitchChanged: (value) {
                        setState(() {
                          _notifications = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            // Navigate to home
            Navigator.pop(context);
          } else if (index == 1) {
            // Navigate to progress dashboard
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProgressDashboardScreen(),
              ),
            );
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

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required bool hasSwitch,
    bool switchValue = false,
    VoidCallback? onTap,
    Function(bool)? onSwitchChanged,
  }) {
    return GestureDetector(
      onTap: hasSwitch ? null : onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.black87,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (hasSwitch)
            Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
              activeColor: Colors.white,
              activeTrackColor: Colors.black87,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[400],
            )
          else
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black87,
              size: 16,
            ),
        ],
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Units'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Metric (kg, cm)'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Units set to Metric'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Imperial (lbs, ft)'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Units set to Imperial'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _uploadProfilePicture(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _uploadProfilePicture(ImageSource.gallery);
                },
              ),
              if ((_userProfile?.profilePictureUrl ?? _userData?['profilePictureUrl']) != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Picture', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeProfilePicture();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadProfilePicture(ImageSource source) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final String? imageUrl = await _profilePictureService.uploadProfilePicture(
        source: source,
      );

      if (imageUrl != null && mounted) {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.updateProfilePicture(imageUrl);
        await _loadUserData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _removeProfilePicture() async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Delete from storage if exists
      final profilePictureUrl = _userProfile?.profilePictureUrl ?? _userData?['profilePictureUrl'];
      if (profilePictureUrl != null) {
        await _profilePictureService.deleteProfilePicture(profilePictureUrl);
      }
      
      // Update Firestore to remove URL
      await authService.updateUserProfile({'profilePictureUrl': null});
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }
}