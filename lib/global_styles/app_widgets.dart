import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_button_styles.dart';
import 'app_card_styles.dart';

class AppWidgets {
  // Modern Card Widget
  static Widget modernCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    BoxDecoration? decoration,
    VoidCallback? onTap,
    bool animate = true,
  }) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: decoration ?? AppCardStyles.modernCard,
      child: child,
    );

    if (animate) {
      card = AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: decoration ?? AppCardStyles.modernCard,
        child: child,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }

  // Custom Card Widget (Legacy)
  static Widget customCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    BoxDecoration? decoration,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: decoration ?? AppCardStyles.modernCard,
        child: child,
      ),
    );
  }
  
  // Gradient Card Widget
  static Widget gradientCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool isOrange = false,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: isOrange ? AppCardStyles.orangeGradientCard : AppCardStyles.gradientCard,
      child: child,
    );
  }
  
  // Custom Button Widget
  static Widget customButton({
    required String text,
    required VoidCallback onPressed,
    ButtonStyle? style,
    Widget? icon,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style ?? AppButtonStyles.primaryMedium,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon,
                  const SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
    );
  }
  
  // Secondary Button Widget
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    Widget? icon,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: AppButtonStyles.secondaryMedium,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon,
                  const SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
    );
  }
  
  // Outline Button Widget
  static Widget outlineButton({
    required String text,
    required VoidCallback onPressed,
    Widget? icon,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: AppButtonStyles.outlineMedium,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: 8),
          ],
          Text(text),
        ],
      ),
    );
  }
  
  // Custom Text Widget
  static Widget customText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      style: style ?? AppTextStyles.bodyMedium,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
  
  // Heading Widget
  static Widget heading(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
  }) {
    return Text(
      text,
      style: style ?? AppTextStyles.h3,
      textAlign: textAlign,
    );
  }
  
  // Custom Input Field Widget
  static Widget customInputField({
    required String label,
    String? hint,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    Widget? prefixIcon,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
  
  // Status Card Widget
  static Widget statusCard({
    required String title,
    required String message,
    required Color statusColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: statusColor),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h6.copyWith(color: statusColor),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(color: statusColor.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Loading Widget
  static Widget loadingWidget({
    String? message,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primaryBlue,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: color ?? AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
  
  // Empty State Widget
  static Widget emptyState({
    required String title,
    required String message,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style: AppTextStyles.h5.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 24),
            customButton(
              text: actionText,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
  
  // Divider Widget
  static Widget customDivider({
    double? height,
    double? thickness,
    Color? color,
  }) {
    return Divider(
      height: height ?? 1,
      thickness: thickness ?? 1,
      color: color ?? AppColors.textMuted,
    );
  }
  
  // Spacer Widget
  static Widget spacer({double? height}) {
    return SizedBox(height: height ?? 16);
  }
  
  // Horizontal Spacer Widget
  static Widget hSpacer({double? width}) {
    return SizedBox(width: width ?? 16);
  }
  
  // Modern Circular Progress Widget
  static Widget circularProgressWidget({
    required double percentage,
    required String label,
    Color? color,
    double size = 120,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: AppCardStyles.circularProgressContainer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 8,
              backgroundColor: AppColors.backgroundSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primaryBlue,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${percentage.toInt()}%',
                style: AppTextStyles.percentage.copyWith(
                  color: color ?? AppColors.primaryBlue,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Modern Quick Action Button
  static Widget modernQuickActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color? gradientColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: AppCardStyles.quickActionButton,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.white,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: AppTextStyles.buttonSmall.copyWith(
                fontSize: 12,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Modern Poll Option Button
  static Widget modernPollOptionButton({
    required String text,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: isSelected 
            ? AppCardStyles.selectedPollOptionCard 
            : AppCardStyles.pollOptionCard,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.primaryOrange,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Modern Input Field
  static Widget modernInputField({
    required String label,
    String? hint,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    Widget? prefixIcon,
    int? maxLines = 1,
  }) {
    return Container(
      decoration: AppCardStyles.modernInputCard,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
  
  // Motivational Message Widget
  static Widget motivationalMessage({
    required String message,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? AppColors.success).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? AppColors.success).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        message,
        style: AppTextStyles.motivational.copyWith(
          color: color ?? AppColors.success,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  // Modern Loading Widget
  static Widget modernLoadingWidget({
    String? message,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppCardStyles.circularProgressContainer,
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: color ?? AppColors.primaryBlue,
                strokeWidth: 3,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: color ?? AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
} 