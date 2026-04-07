import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppCardStyles {
  // Modern Glassmorphism Card Style
  static BoxDecoration modernCard = BoxDecoration(
    gradient: AppColors.cardGradient1,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 40,
        offset: const Offset(0, 16),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Elevated Modern Card Style
  static BoxDecoration elevatedModernCard = BoxDecoration(
    gradient: AppColors.cardGradient2,
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 30,
        offset: const Offset(0, 12),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: AppColors.shadowHeavy,
        blurRadius: 60,
        offset: const Offset(0, 24),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Gradient Card Style - Modern
  static BoxDecoration gradientCard = BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.glowBlue,
        blurRadius: 25,
        offset: const Offset(0, 10),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Orange Gradient Card Style - Modern
  static BoxDecoration orangeGradientCard = BoxDecoration(
    gradient: AppColors.orangeGradient,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.glowOrange,
        blurRadius: 25,
        offset: const Offset(0, 10),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Purple Gradient Card Style
  static BoxDecoration purpleGradientCard = BoxDecoration(
    gradient: AppColors.purpleGradient,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 25,
        offset: const Offset(0, 10),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Success Gradient Card Style
  static BoxDecoration successGradientCard = BoxDecoration(
    gradient: AppColors.successGradient,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 25,
        offset: const Offset(0, 10),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Glass Card Style - Modern
  static BoxDecoration glassCard = BoxDecoration(
    gradient: AppColors.glassGradient,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: AppColors.white.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 15,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Input Field Card Style - Modern
  static BoxDecoration modernInputCard = BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.textMuted.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Status Card Styles - Modern
  static BoxDecoration successCard = BoxDecoration(
    color: AppColors.success.withOpacity(0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.success.withOpacity(0.2),
      width: 1,
    ),
  );
  
  static BoxDecoration errorCard = BoxDecoration(
    color: AppColors.error.withOpacity(0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.error.withOpacity(0.2),
      width: 1,
    ),
  );
  
  static BoxDecoration warningCard = BoxDecoration(
    color: AppColors.warning.withOpacity(0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.warning.withOpacity(0.2),
      width: 1,
    ),
  );
  
  static BoxDecoration infoCard = BoxDecoration(
    color: AppColors.info.withOpacity(0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.info.withOpacity(0.2),
      width: 1,
    ),
  );
  
  // Poll Option Card Style
  static BoxDecoration pollOptionCard = BoxDecoration(
    color: AppColors.backgroundCard,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.primaryOrange.withOpacity(0.3),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Selected Poll Option Card Style
  static BoxDecoration selectedPollOptionCard = BoxDecoration(
    gradient: AppColors.orangeGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.glowOrange,
        blurRadius: 15,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Quick Action Button Style
  static BoxDecoration quickActionButton = BoxDecoration(
    gradient: AppColors.orangeGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.glowOrange,
        blurRadius: 15,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      ),
    ],
  );
  
  // Circular Progress Container
  static BoxDecoration circularProgressContainer = BoxDecoration(
    gradient: AppColors.cardGradient1,
    borderRadius: BorderRadius.circular(50),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 15,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      ),
    ],
  );
} 