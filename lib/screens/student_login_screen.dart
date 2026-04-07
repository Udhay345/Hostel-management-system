import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';
import '../global_styles/app_card_styles.dart';
import 'student_dashboard_screen.dart';
import 'signup_screen.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  final FirebaseService _firebaseService = FirebaseService();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userCredential = await _firebaseService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCredential != null && mounted) {
          // Check if user is a student
          final isStudent = await _firebaseService.isStudent(userCredential.user!.uid);
          
          if (isStudent) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentDashboardScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This account is not registered as a student.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

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
                
                // Login Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: AppCardStyles.orangeGradientCard,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Login Title
                        Text(
                          'LOG IN',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppWidgets.spacer(height: 32),
                        
                        // Email Field
                        AppWidgets.customInputField(
                          label: 'EMAIL',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        AppWidgets.spacer(height: 16),
                        
                        // Password Field
                        AppWidgets.customInputField(
                          label: 'PASSWORD',
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            child: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        AppWidgets.spacer(height: 32),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: AppWidgets.customButton(
                            text: 'login',
                            onPressed: _isLoading ? () {} : _login,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppWidgets.spacer(height: 24),
                
                // Signup Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'new user? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'signup',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}