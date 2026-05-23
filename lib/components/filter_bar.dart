import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../theme/index.dart';
import '../theme/app_helpers.dart';

class FilterBar extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChange;
  final List<String> availableColors;
  final List<String> availableTags;
  final List<Resolucao> availableResolutions;

  const FilterBar({
    super.key,
    required this.onFilterChange,
    this.availableColors = const [],
    this.availableTags = const [],
    this.availableResolutions = const [],
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  String? _selectedColor;
  Resolucao? _selectedResolution;
  String _selectedOrder = 'recente';
  List<String> _selectedTags = [];

  void _updateFilters() {
    widget.onFilterChange({
      'color': _selectedColor,
      'resolution': _selectedResolution,
      'order': _selectedOrder,
      'tags': _selectedTags,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _buildOrderButton('recente', 'Recentes'),
          const SizedBox(width: AppSpacing.md),
          _buildOrderButton('popular', 'Populares'),
          const SizedBox(width: AppSpacing.md),
          _buildOrderButton('curtidas', 'Mais Curtidos'),
          if (widget.availableColors.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.md),
            _buildColorFilter(),
          ],
          if (widget.availableResolutions.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.md),
            _buildResolutionFilter(),
          ],
          if (widget.availableTags.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.md),
            _buildTagFilter(),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderButton(String value, String label) {
    final isSelected = _selectedOrder == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedOrder = value);
        _updateFilters();
      },
      child: AppHelpers.filterChip(
        label: label,
        isSelected: isSelected,
        onTap: () {},
      ),
    );
  }

  Widget _buildColorFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.availableColors
            .take(6)
            .map((color) {
              final isSelected = _selectedColor == color;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = isSelected ? null : color;
                    });
                    _updateFilters();
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${color.replaceFirst('#', '')}')),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderDefault,
                        width: isSelected ? 2.0 : 0.8,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(),
      ),
    );
  }

  Widget _buildResolutionFilter() {
    return DropdownButton<Resolucao>(
      value: _selectedResolution,
      hint: Text(
        'Resolução',
        style: AppFonts.body(size: 12, color: AppColors.textSecondary),
      ),
      dropdownColor: AppColors.fieldBackground,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
      underline: Container(
        height: 1,
        color: AppColors.borderDefault,
      ),
      items: widget.availableResolutions.map((res) {
        return DropdownMenuItem<Resolucao>(
          value: res,
          child: Text(
            res.label,
            style: AppFonts.body(size: 12, color: AppColors.textPrimary),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedResolution = value);
        _updateFilters();
      },
    );
  }

  Widget _buildTagFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.availableTags
            .take(4)
            .map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                    _updateFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderDefault,
                        width: 1.0,
                      ),
                      color: AppColors.background,
                    ),
                    child: Text(
                      tag,
                      style: AppFonts.body(
                        size: 10,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(),
      ),
    );
  }
}
