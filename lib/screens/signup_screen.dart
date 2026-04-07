import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../global_styles/app_colors.dart';
import '../global_styles/app_text_styles.dart';
import '../global_styles/app_widgets.dart';
import '../global_styles/app_card_styles.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final FirebaseService _firebaseService = FirebaseService();

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firebaseService.signUpStudent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          roomNumber: _roomController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
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
                      return const SizedBox.shrink();
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
                          'SIGN UP',
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
                        
                        // Room Number Field
                        AppWidgets.customInputField(
                          label: 'ROOM NUMBER',
                          controller: _roomController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter room number';
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
    _roomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}