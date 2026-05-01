import 'package:flutter/material.dart';

class JolusColors {
  // Brand Colors (Exact Hex from prompt)
  static const primaryDarkBlue = Color(0xFF0D3B66);
  static const primaryBlue = Color(0xFF1F6FE5);
  static const accentBlue = Color(0xFF2FA4FF);
  static const lightBlue = Color(0xFFE7F1FF);

  // UI Colors
  static const background = Color(0xFFFFFFFF);
  static const sectionBackground = Color(0xFFF5F8FC);
  static const primaryText = Color(0xFF1A2A3A);
  static const secondaryText = Color(0xFF6B85A6);
  static const borders = Color(0xFFE3EAF3);

  // Gradients
  static const mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryDarkBlue,
      primaryBlue,
      accentBlue,
    ],
  );

  // Compatibility / Legacy Colors
  static const primary = Color(0xFF00236F);
  static const primaryContainer = Color(0xFF1E3A8A);
  static const tertiary = Color(0xFF4B1C00);
  static const onBackground = Color(0xFF1A1C1E);
  static const surfaceLow = Color(0xFFF4F3FA);
  static const outlineVariant = Color(0xFFC5C5D3);
  static const onSurfaceVariant = Color(0xFF444651);
}
