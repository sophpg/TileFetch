import 'package:flutter/material.dart';
import '../theme/index.dart';

class AppHelpers {
  static Container borderedContainer({
    required Widget child,
    Color borderColor = AppColors.borderDefault,
    double borderWidth = 0.8,
    Color? backgroundColor,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        color: backgroundColor ?? AppColors.fieldBackground,
      ),
      child: child,
    );
  }

  static TextButton styledButton({
    required String label,
    required VoidCallback onPressed,
    Color borderColor = AppColors.borderDefault,
    Color textColor = AppColors.textPrimary,
    Color backgroundColor = AppColors.fieldBackground,
    bool isDisabled = false,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.buttonHeight,
          horizontal: AppSpacing.xs,
        ),
        side: BorderSide(
          color: borderColor,
          width: 1.0,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      onPressed: isDisabled ? null : onPressed,
      child: Text(
        label,
        style: AppFonts.body(
          color: textColor,
        ),
      ),
    );
  }

  static Container filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    double fontSize = 12,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderDefault,
          width: 1.0,
        ),
        color: AppColors.background,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: AppFonts.body(
            size: fontSize,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  static TextFormField styledTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTextFields.inputTextStyle(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.fieldBackground,
        labelStyle: AppFonts.body(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppFonts.body(
          size: 15,
          color: AppColors.error,
        ),
        border: AppBorders.defaultInputBorder,
        enabledBorder: AppBorders.defaultInputBorder,
        focusedBorder: AppBorders.focusedInputBorder,
        errorBorder: AppBorders.errorInputBorder,
        focusedErrorBorder: AppBorders.errorInputBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPadding,
          vertical: AppSpacing.inputPadding,
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  static Stack backgroundStack({
    required List<Widget> children,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            AppAssets.backgroundImage,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned.fill(
          child: Container(color: AppColors.overlayDark),
        ),
        ...children,
      ],
    );
  }

  static Center loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  static Center emptyMessage(String message) {
    return Center(
      child: Text(
        message,
        style: AppFonts.body(color: AppColors.textSecondary),
      ),
    );
  }

  static Color hexToColor(String hex) {
    try {
      return Color(int.parse('0xFF${hex.replaceFirst('#', '')}'));
    } catch (e) {
      return AppColors.borderDefault;
    }
  }
}
