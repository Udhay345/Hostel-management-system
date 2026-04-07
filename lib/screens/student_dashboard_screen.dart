import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'apply_leave_screen.dart';
import 'apply_outpass_screen.dart';
import 'raise_complaint_screen.dart';
import 'mess_poll_screen.dart';
import 'notifications_screen.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        final userData = await _firebaseService.getUserData(user.uid, 'students');
        if (mounted) {
          setState(() {
            _userData = userData;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String get _userName {
    if (_userData != null) {
      final name = _userData!['name'] as String?;
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }
    return 'student';
  }

  String get _roomNumber {
    if (_userData != null) {
      final room = _userData!['roomNumber'] as String?;
      if (room != null && room.isNotEmpty) {
        return room;
      }
    }
    return 'N/A';
  }

  List<Widget> get _screens => [
    DashboardContent(
      userName: _userName,
      onNavigate: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    ),
    const ApplyLeaveScreen(),
    const ApplyOutpassScreen(),
    const RaiseComplaintScreen(),
    const MessPollScreen(),
    NotificationsScreen(userId: _firebaseService.currentUser?.uid ?? ''),
  ];

  void _logout() async {
    try {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Disable automatic back button
        leading: _selectedIndex == 0 
            ? null 
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0; // Go back to main dashboard
                  });
                },
              ),
        actions: [
          // Notification badge
          StreamBuilder(
            stream: _firebaseService.currentUser != null 
                ? _firebaseService.getUserNotifications(_firebaseService.currentUser!.uid)
                : null,
            builder: (context, snapshot) {
              // Handle errors gracefully
              if (snapshot.hasError) {
                return IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 5; // Notifications screen
                    });
                  },
                );
              }
              
              final unreadCount = snapshot.data?.docs
                      .where((doc) => doc.data()['read'] == false)
                      .length ?? 0;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 5; // Notifications screen
                      });
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header with Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Room: $_roomNumber',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Navigation Items
            ListTile(
              leading: const Icon(Icons.dashboard, color: AppColors.primaryBlue),
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
              title: const Text('Apply Leave'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: AppColors.primaryBlue),
              title: const Text('Apply Out Pass'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem, color: AppColors.primaryBlue),
              title: const Text('Raise Complaint'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.poll, color: AppColors.primaryBlue),
              title: const Text('Poll & Feedback'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: AppColors.primaryBlue),
              title: const Text('Notifications'),
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _screens[_selectedIndex],
    );
  }
}

class DashboardContent extends StatelessWidget {
  final String userName;
  final Function(int) onNavigate;
  
  const DashboardContent({
    super.key, 
    required this.userName,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppWidgets.heading('student $userName'),
          AppWidgets.spacer(height: 24),
          
          // Attendance Overview Card
          AppWidgets.customCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Overview',
                  style: AppTextStyles.h5,
                ),
                AppWidgets.spacer(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttendanceCard('Present', '85%', AppColors.success),
                    _buildAttendanceCard('Absent', '15%', AppColors.error),
                  ],
                ),
              ],
            ),
          ),
          
          AppWidgets.spacer(height: 16),
          
          // Quick Actions Card
          AppWidgets.customCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: AppTextStyles.h5,
                ),
                AppWidgets.spacer(height: 16),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppWidgets.customButton(
                            text: 'Apply Leave',
                            onPressed: () => onNavigate(1), // Navigate to Apply Leave screen
                            icon: const Icon(Icons.calendar_today, color: AppColors.white),
                          ),
                        ),
                        AppWidgets.hSpacer(),
                        Expanded(
                          child: AppWidgets.customButton(
                            text: 'Out Pass',
                            onPressed: () => onNavigate(2), // Navigate to Out Pass screen
                            icon: const Icon(Icons.exit_to_app, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    AppWidgets.spacer(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppWidgets.secondaryButton(
                            text: 'Complaint',
                            onPressed: () => onNavigate(3), // Navigate to Complaint screen
                            icon: const Icon(Icons.report_problem, color: AppColors.white),
                          ),
                        ),
                        AppWidgets.hSpacer(),
                        Expanded(
                          child: AppWidgets.secondaryButton(
                            text: 'Poll',
                            onPressed: () => onNavigate(4), // Navigate to Poll screen
                            icon: const Icon(Icons.poll, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(String title, String percentage, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.bodySmall,
        ),
        AppWidgets.spacer(height: 8),
        Text(
          percentage,
          style: AppTextStyles.h2.copyWith(color: color),
        ),
      ],
    );
  }
} 