import 'package:flutter/material.dart';
import 'package:redstring/core/constants/app_colors.dart';

class AppTextStyles {
  static TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    color: AppColors.textSecondary,
  );

  static TextStyle link = TextStyle(
    fontSize: 16,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );
}
