import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_borders.dart';
import 'app_spacing.dart';
import 'app_fonts.dart';

class AppButtons {
  // Estilo de botão primário
  static ButtonStyle primaryButtonStyle() {
    return TextButton.styleFrom(
      backgroundColor: AppColors.fieldBackground,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.buttonHeight,
      ),
      side: AppBorders.defaultBorderSide,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  // Estilo de botão secundário (transparente)
  static ButtonStyle secondaryButtonStyle() {
    return TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.buttonHeight,
      ),
      side: AppBorders.defaultBorderSide,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  // Estilo de botão grande
  static ButtonStyle largeButtonStyle() {
    return TextButton.styleFrom(
      backgroundColor: AppColors.fieldBackground,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.largeButtonHeight,
      ),
      side: AppBorders.defaultBorderSide,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  // Estilo de botão pequeno
  static ButtonStyle smallButtonStyle() {
    return TextButton.styleFrom(
      backgroundColor: AppColors.fieldBackground,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.smallButtonHeight,
      ),
      side: AppBorders.defaultBorderSide,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  // Texto padrão para botão
  static TextStyle buttonTextStyle({Color color = AppColors.textPrimary}) {
    return AppFonts.body(
      color: color,
      weight: FontWeight.bold,
    );
  }
}
