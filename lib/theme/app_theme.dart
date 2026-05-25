import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      textTheme: AppFonts.appTextTheme(base.textTheme),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        error: AppColors.error,
      ),
    );
  }
}
