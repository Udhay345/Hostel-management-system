import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Hostel Theme
  static const Color primaryBlue = Color(0xFF005B96); // RIT Blue
  static const Color primaryOrange = Color(0xFFFF7F32); // RIT Orange
  static const Color secondaryBlue = Color(0xFF87CEEB); // Sky blue
  static const Color accentPurple = Color(0xFF6366F1); // Modern purple accent
  
  // Secondary Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Modern Background Colors
  static const Color backgroundPrimary = Color(0xFFFAFBFF); // Soft blue-tinted white
  static const Color backgroundSecondary = Color(0xFFF8FAFC); // Very light gray
  static const Color backgroundCard = Color(0xFFFFFFFF); // Pure white cards
  static const Color backgroundGlass = Color(0x80FFFFFF); // Glass effect
  
  // Modern Text Colors
  static const Color textPrimary = Color(0xFF1E293B); // Dark slate
  static const Color textSecondary = Color(0xFF64748B); // Medium slate
  static const Color textMuted = Color(0xFF94A3B8); // Light slate
  static const Color textAccent = Color(0xFF3B82F6); // Blue accent text
  
  // Status Colors - Modern Palette
  static const Color success = Color(0xFF10B981); // Modern green
  static const Color error = Color(0xFFEF4444); // Modern red
  static const Color warning = Color(0xFFF59E0B); // Modern amber
  static const Color info = Color(0xFF3B82F6); // Modern blue
  
  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [primaryOrange, Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [accentPurple, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    colors: [backgroundGlass, Color(0x40FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Modern Shadows
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x15000000);
  static const Color shadowHeavy = Color(0x25000000);
  static const Color glowBlue = Color(0x20006FEE);
  static const Color glowOrange = Color(0x20FF6B35);
  
  // Login Gradient - Blue to White (60% blue, 40% white)
  static const LinearGradient loginGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF1E40AF), Color(0xFF93C5FD), Color(0xFFE5E7EB), white],
    stops: [0.0, 0.3, 0.6, 0.8, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Card Gradients
  static const LinearGradient cardGradient1 = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient2 = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
} 