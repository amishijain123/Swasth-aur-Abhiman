import 'package:flutter/material.dart';
import 'design_system.dart';

/// Global App Theme implementing the Blue & Grey GOV design system.
/// All colors and global components must follow the palette described in
/// `DesignSystem` (DO NOT CHANGE the hex codes).
class AppTheme {
  static const Color primaryColor = DesignSystem.primary;
  static const Color secondaryColor = DesignSystem.secondary;
  static const Color accentColor = DesignSystem.accent;
  static const Color backgroundColor = DesignSystem.background;
  static const Color borderColor = DesignSystem.border;
  static const Color textDark = DesignSystem.textDark;

  static ThemeData get lightTheme {
    final base = ThemeData.light();

    return base.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: DesignSystem.white,
        onPrimary: DesignSystem.white,
        onSurface: textDark,
      ),

      // Scaffold / Background
      scaffoldBackgroundColor: backgroundColor,

      // App Bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: DesignSystem.white,
        titleTextStyle: TextStyle(
          color: DesignSystem.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Typography (ensure high contrast for body text)
      textTheme: base.textTheme.copyWith(
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: textDark,
          fontSize: 16,
          height: 1.4,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: textDark,
          fontSize: 14,
          height: 1.4,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: textDark,
          fontSize: 12,
          height: 1.4,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: textDark,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // CTA fill
          foregroundColor: DesignSystem.white, // CTA text
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          side: BorderSide(color: secondaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor, // links and secondary actions
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Cards and containers
      cardTheme: CardThemeData(
        color: DesignSystem.white,
        elevation: DesignSystem.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignSystem.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),

      // Lists / Selected states
      listTileTheme: ListTileThemeData(
        selectedColor: textDark,
        selectedTileColor: accentColor,
        iconColor: primaryColor,
      ),

      // Dividers
      dividerColor: borderColor,

      // Tabs: selected highlight
      tabBarTheme: TabBarThemeData(
        indicator: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: textDark,
        unselectedLabelColor: textDark.withOpacity(0.7),
      ),

      // Focus & highlight colors for accessibility
      focusColor: accentColor.withOpacity(0.4),
      highlightColor: accentColor.withOpacity(0.2),

      // Visual density for mobile
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    // Keep a simple dark theme for completeness — still follows palette when possible
    final base = ThemeData.dark();

    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0F1720),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: DesignSystem.white,
      ),
    );
  }
}
