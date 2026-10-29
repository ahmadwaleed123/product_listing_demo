import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static const _primary = Color(0xFF1F4E79);
  static const _secondary = Color(0xFFF2994A);
  static const _background = Color(0xFFF7F8FA);
  static const _surface = Color(0xFFFFFFFF);
  static const _text = Color(0xFF1D1F23);
  static const _textLight = Color(0xFF6B7280);
  static const _border = Color(0xFFE2E5EA);

  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
      onSurface: _text,
      onSurfaceVariant: _textLight,
      outlineVariant: _border,
    );

    final fieldRadius = BorderRadius.circular(10.r);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _background,
      textTheme: _textTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _background,
        foregroundColor: _text,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: _border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: _primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
    );
  }

  static TextTheme _textTheme() {
    return Typography.englishLike2021
        .merge(Typography.material2021().black)
        .apply(fontSizeFactor: 1.sp, bodyColor: _text, displayColor: _text);
  }
}
