import 'package:flutter/material.dart';
import 'app_colors.dart';

/// @deprecated Use AppColors instead
class BeeColors {
  // Primary Colors - Mapped to AppColors
  static const Color beeYellow = AppColors.secondary;
  static const Color beeBlack = AppColors.textPrimary;
  static const Color beeWhite = Colors.white;
  
  // Background Colors - Mapped to AppColors
  static const Color background = AppColors.background;
  static const Color cardBackground = AppColors.surface;
  
  // Text Colors - Mapped to AppColors
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textHint = AppColors.disabled;
  
  // Accent Colors - Mapped to AppColors
  static const Color accentGreen = AppColors.success;
  static const Color accentRed = AppColors.error;
  static const Color accentBlue = Color(0xFF2196F3);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF2196F3);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC107), Color(0xFFFFA000)],
  );
  
  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
}
