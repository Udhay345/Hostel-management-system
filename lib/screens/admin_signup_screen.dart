import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';
import '../global_styles/app_card_styles.dart';

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firebaseService.signUpAdmin(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  
                  // RIT logo above signup
                  Image.asset(
                    'assets/images/rit logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.account_tree_rounded,
                        color: AppColors.white,
                        size: 72,
                      );
                    },
                  ),
                  AppWidgets.spacer(height: 32),
                  
                  // Signup Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: AppCardStyles.orangeGradientCard,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Signup Title
                        Text(
                          'ADMIN SIGNUP',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppWidgets.spacer(height: 32),
                        
                        // Name Field
                        AppWidgets.customInputField(
                          label: 'FULL NAME',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        AppWidgets.spacer(height: 16),
                        
                        // Mobile Field
                        AppWidgets.customInputField(
                          label: 'MOBILE NUMBER',
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter mobile number';
                            }
                            if (value.length != 10) {
                              return 'Please enter a valid 10-digit mobile number';
                            }
                            return null;
                          },
                        ),
                        AppWidgets.spacer(height: 16),
                        
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
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
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
                        AppWidgets.spacer(height: 16),
                        
                        // Confirm Password Field
                        AppWidgets.customInputField(
                          label: 'CONFIRM PASSWORD',
                          controller: _confirmPasswordController,
                          obscureText: !_confirmPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _confirmPasswordVisible = !_confirmPasswordVisible;
                              });
                            },
                            child: Icon(
                              _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        AppWidgets.spacer(height: 32),
                        
                        // Signup Button
                        SizedBox(
                          width: double.infinity,
                          child: AppWidgets.customButton(
                            text: 'signup',
                            onPressed: _isLoading ? () {} : _signup,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppWidgets.spacer(height: 24),
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'already have an account? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'login',
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}