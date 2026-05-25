import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import '../theme/index.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {
        'icon': Pixel.home,
        'label': 'Home',
      },
      {
        'icon': Pixel.search,
        'label': 'Buscar',
      },
      {
        'icon': Pixel.plus,
        'label': 'Upload',
      },
      {
        'icon': Pixel.heart,
        'label': 'Favoritos',
      },
      {
        'icon': Pixel.user,
        'label': 'Perfil',
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.borderDefault,
            width: 1.0,
          ),
        ),
        color: AppColors.background,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          navItems.length,
          (index) {
            final item = navItems[index];
            final isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  border: isSelected
                      ? const Border(
                          bottom: BorderSide(
                            color: AppColors.primary,
                            width: 2.0,
                          ),
                        )
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: AppFonts.body(
                        size: 10,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
