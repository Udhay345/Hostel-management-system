import 'package:flutter/material.dart';
import 'student_login_screen.dart';
import 'admin_login_screen.dart';
import 'signup_screen.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';
import '../global_styles/app_card_styles.dart';

class LoginSelectorScreen extends StatelessWidget {
  const LoginSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.loginGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Simple RIT logo above login
                Image.asset(
                  'assets/images/rit logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
                AppWidgets.spacer(height: 24),

                // App Title
                Text(
                  'Hostel Management System',
                  style: AppTextStyles.h2.copyWith(color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
                AppWidgets.spacer(height: 48),

                // Student Login Button
                SizedBox(
                  width: double.infinity,
                  child: AppWidgets.customButton(
                    text: 'Student Login',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentLoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person, color: AppColors.white),
                  ),
                ),
                AppWidgets.spacer(height: 16),

                // Admin Login Button
                SizedBox(
                  width: double.infinity,
                  child: AppWidgets.secondaryButton(
                    text: 'Admin Login',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminLoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings, color: AppColors.white),
                  ),
                ),
                AppWidgets.spacer(height: 16),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: AppWidgets.outlineButton(
                    text: 'Sign Up',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add, color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}