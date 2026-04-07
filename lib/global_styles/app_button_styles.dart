import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppButtonStyles {
  // Primary Button Styles
  static ButtonStyle primaryLarge = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    shadowColor: AppColors.shadowMedium,
    textStyle: AppTextStyles.buttonLarge,
  );
  
  static ButtonStyle primaryMedium = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 3,
    shadowColor: AppColors.shadowMedium,
    textStyle: AppTextStyles.buttonMedium,
  );
  
  static ButtonStyle primarySmall = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
    shadowColor: AppColors.shadowLight,
    textStyle: AppTextStyles.buttonSmall,
  );
  
  // Secondary Button Styles
  static ButtonStyle secondaryLarge = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryOrange,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    shadowColor: AppColors.shadowMedium,
    textStyle: AppTextStyles.buttonLarge,
  );
  
  static ButtonStyle secondaryMedium = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryOrange,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 3,
    shadowColor: AppColors.shadowMedium,
    textStyle: AppTextStyles.buttonMedium,
  );
  
  static ButtonStyle secondarySmall = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryOrange,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
    shadowColor: AppColors.shadowLight,
    textStyle: AppTextStyles.buttonSmall,
  );
  
  // Outline Button Styles
  static ButtonStyle outlineLarge = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryBlue,
    side: const BorderSide(color: AppColors.primaryBlue, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: AppTextStyles.buttonLarge.copyWith(color: AppColors.primaryBlue),
  );
  
  static ButtonStyle outlineMedium = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryBlue,
    side: const BorderSide(color: AppColors.primaryBlue, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: AppTextStyles.buttonMedium.copyWith(color: AppColors.primaryBlue),
  );
  
  static ButtonStyle outlineSmall = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryBlue,
    side: const BorderSide(color: AppColors.primaryBlue, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: AppTextStyles.buttonSmall.copyWith(color: AppColors.primaryBlue),
  );
  
  // Text Button Styles
  static ButtonStyle textLarge = TextButton.styleFrom(
    foregroundColor: AppColors.primaryBlue,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: AppTextStyles.buttonLarge.copyWith(color: AppColors.primaryBlue),
  );
  
  static ButtonStyle textMedium = TextButton.styleFrom(
    foregroundColor: AppColors.primaryBlue,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: AppTextStyles.buttonMedium.copyWith(color: AppColors.primaryBlue),
  );
  
  static ButtonStyle textSmall = TextButton.styleFrom(
    foregroundColor: AppColors.primaryBlue,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: AppTextStyles.buttonSmall.copyWith(color: AppColors.primaryBlue),
  );
  
  // Icon Button Styles
  static ButtonStyle iconButton = IconButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 3,
    shadowColor: AppColors.shadowMedium,
  );
  
  static ButtonStyle iconButtonSecondary = IconButton.styleFrom(
    backgroundColor: AppColors.primaryOrange,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 3,
    shadowColor: AppColors.shadowMedium,
  );
} 