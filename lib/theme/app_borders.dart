import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppBorders {
  static const double defaultBorderWidth = 0.8;
  static const double thickBorderWidth = 1.5;

  // Estilos de borda padrão
  static final OutlineInputBorder defaultInputBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(
      color: AppColors.borderDefault,
      width: defaultBorderWidth,
    ),
  );

  static final OutlineInputBorder focusedInputBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(
      color: AppColors.primary,
      width: defaultBorderWidth,
    ),
  );

  static final OutlineInputBorder errorInputBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(
      color: AppColors.borderError,
      width: defaultBorderWidth,
    ),
  );

  // BorderSide padrão
  static const BorderSide defaultBorderSide = BorderSide(
    color: AppColors.borderDefault,
    width: defaultBorderWidth,
  );

  static const BorderSide successBorderSide = BorderSide(
    color: AppColors.primary,
    width: defaultBorderWidth,
  );

  static const BorderSide errorBorderSide = BorderSide(
    color: AppColors.borderError,
    width: defaultBorderWidth,
  );
}
