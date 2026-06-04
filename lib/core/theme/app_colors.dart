import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFFB71C1C);
  static const primaryLight = Color(0xFFE53935);
  static const primaryDark = Color(0xFF7F0000);
  static const accent = Color(0xFFFFD54F);

  static const background = Color(0xFF0F0A0A);
  static const surface = Color(0xFF1C0F0F);
  static const surfaceVariant = Color(0xFF2A1515);

  static const textPrimary = Color(0xFFFFF8F8);
  static const textSecondary = Color(0xFFFFAB91);
  static const textDisabled = Color(0xFF6D4C4C);

  static const playerBackground = Color(0xFF120808);
  static const progressBar = Color(0xFFB71C1C);
  static const progressBarInactive = Color(0xFF3D1515);

  static const gradientStart = Color(0xFFB71C1C);
  static const gradientEnd = Color(0xFFFFD54F);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, background],
  );
}