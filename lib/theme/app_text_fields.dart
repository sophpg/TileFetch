import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_borders.dart';
import 'app_fonts.dart';
import 'app_spacing.dart';

class AppTextFields {
  // Decoração padrão para TextField
  static InputDecoration standardInputDecoration({
    required String labelText,
    double fontSize = 18,
    Color labelColor = AppColors.textSecondary,
    Color textColor = AppColors.textPrimary,
    Color fillColor = AppColors.fieldBackground,
    Widget? suffixIcon,
    double errorFontSize = 15,
  }) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: fillColor,
      labelStyle: AppFonts.body(
        color: labelColor,
        size: fontSize,
      ),
      errorStyle: AppFonts.body(
        size: errorFontSize,
        color: AppColors.error,
      ),
      border: AppBorders.defaultInputBorder,
      enabledBorder: AppBorders.defaultInputBorder,
      focusedBorder: AppBorders.focusedInputBorder,
      errorBorder: AppBorders.errorInputBorder,
      focusedErrorBorder: AppBorders.errorInputBorder,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.inputPadding,
        vertical: AppSpacing.inputPadding,
      ),
    );
  }

  // Estilo de texto padrão para input
  static TextStyle inputTextStyle({
    double size = 18,
    Color color = AppColors.textPrimary,
  }) {
    return AppFonts.body(
      size: size,
      color: color,
    );
  }

  // Configuração de email
  static InputDecoration emailInputDecoration() {
    return standardInputDecoration(labelText: "Email");
  }

  // Configuração de senha
  static InputDecoration passwordInputDecoration({Widget? suffixIcon}) {
    return standardInputDecoration(
      labelText: "Senha",
      suffixIcon: suffixIcon,
    );
  }

  // Configuração de nome
  static InputDecoration nameInputDecoration() {
    return standardInputDecoration(labelText: "Nome");
  }

  // Configuração de telefone
  static InputDecoration phoneInputDecoration() {
    return standardInputDecoration(labelText: "Telefone");
  }

  // Configuração de campo obrigatório (com asterisco)
  static InputDecoration requiredInputDecoration({required String label}) {
    return standardInputDecoration(labelText: "$label *");
  }
}
