import 'package:flutter/material.dart';

class AppStyles {
  // Colors - 색상
  static const Color primary = Color(0xFF5B7FFF);      // 부드러운 블루
  static const Color secondary = Color(0xFF8E9FFF);    // 연한 블루
  static const Color background = Color(0xFFFAFBFF);   // 매우 연한 블루 배경
  static const Color surface = Colors.white;           // 흰색 카드 배경
  static const Color textPrimary = Color(0xFF2B2F3F);  // 진한 회색
  static const Color textSecondary = Color(0xFF9BA1B7);// 연한 회색
  static const Color divider = Color(0xFFF0F2F9);      // 구분선
  static const Color error = Color(0xFFFF6B6B);        // 에러/삭제

  // Gradients - 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spacing
  static const double spacing = 16.0;
  static const double radius = 14.0;  // 모서리
  static const double elevation = 0.0;

  // Text Styles
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textSecondary,
    fontWeight: FontWeight.w500,
  );

  // Decorations - 그림자
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 12,
        offset: Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration searchDecoration = BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(radius),
  );

  // Input Decoration - 입력 필드
  static InputDecoration inputDecoration(String hint, {IconData? prefixIcon}) => 
    InputDecoration(
      hintText: hint,
      hintStyle: caption,
      prefixIcon: prefixIcon != null 
          ? Icon(prefixIcon, color: textSecondary, size: 20)
          : null,
      filled: true,
      fillColor: background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: primary.withOpacity(0.5), width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

  // Button Styles - 버튼
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: elevation,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    ),
  );

  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: primary,
    elevation: elevation,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    ),
    side: BorderSide(color: primary),
  );
} 