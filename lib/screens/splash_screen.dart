import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'login_selector_screen.dart';
import 'student_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import '../global_styles/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation and navigation
    _startSplashSequence();
  }

  void _startSplashSequence() async {
    // Start fade in animation
    await _animationController.forward();
    
    // Wait for 2 seconds total (including animation time)
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Start fade out animation
    await _animationController.reverse();
    
    // Navigate based on authentication status
    if (mounted) {
      await _navigateBasedOnAuth();
    }
  }

  Future<void> _navigateBasedOnAuth() async {
    try {
      final user = _firebaseService.currentUser;
      
      if (user != null) {
        // User is logged in, check their role
        final userData = await _firebaseService.getUserData(user.uid, 'students');
        if (userData != null) {
          // Student user
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const StudentDashboardScreen(),
            ),
          );
          return;
        }
        
        final adminData = await _firebaseService.getUserData(user.uid, 'admins');
        if (adminData != null) {
          // Admin user
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
          return;
        }
      }
      
      // No user or unknown role, go to login selector
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginSelectorScreen(),
        ),
      );
    } catch (e) {
      // Error occurred, go to login selector
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginSelectorScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Semantics(
                label: 'RIT Hostel Management System Logo',
                child: Image.asset(
                  'assets/images/rit logo.png',
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.account_tree_rounded,
                      color: Colors.white,
                      size: 120,
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // App Title
              const Text(
                'RIT Hostel Management System',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}