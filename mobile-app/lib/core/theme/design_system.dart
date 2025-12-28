import 'package:flutter/material.dart';

/// Blue & Grey Design System for Swastha Aur Abhiman
///
/// Palette (DO NOT CHANGE):
/// - Primary:   #395A7F (Deep Slate Blue)
/// - Secondary: #6E9FC1 (Steel Blue)
/// - Accent:    #A3CAE9 (Light Sky Blue)
/// - Background:#E9ECEE (Off-White Grey)
/// - Border:    #ACACAC (Medium Grey)
///
/// This file exposes color constants and small helpers for consistent UI.
class DesignSystem {
  // Palette
  static const Color primary = Color(0xFF395A7F);
  static const Color secondary = Color(0xFF6E9FC1);
  static const Color accent = Color(0xFFA3CAE9);
  static const Color background = Color(0xFFE9ECEE);
  static const Color border = Color(0xFFACACAC);

  // Text and semantic colors
  static const Color textDark = Color(0xFF2C3E50); // For body and headings (high contrast)
  static const Color white = Colors.white;

  // Accessibility helpers
  static const double elevationLow = 2.0;
  static const double borderRadius = 8.0;
}
