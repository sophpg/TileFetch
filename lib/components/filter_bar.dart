import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../theme/index.dart';

const Map<String, Color> _commonColorOptions = {
  'Vermelho': Color(0xFFFF4D4D),
  'Laranja': Color(0xFFFFA93F),
  'Amarelo': Color(0xFFFFE066),
  'Verde': Color(0xFF4DFF7A),
  'Azul': Color(0xFF4DA4FF),
  'Roxo': Color(0xFFB35CFF),
  'Rosa': Color(0xFFFF6EC7),
};
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
  String? _selectedTag;

  void _updateFilters() {
    widget.onFilterChange({
      'color': _selectedColor,
      'resolution': _selectedResolution,
      'order': _selectedOrder,
      'tags': _selectedTag != null ? <String>[_selectedTag!] : <String>[],
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
          _buildOrderDropdown(),
          const SizedBox(width: AppSpacing.md),
          if (widget.availableColors.isNotEmpty) _buildColorFilter(),
          const SizedBox(width: AppSpacing.md),
          if (widget.availableResolutions.isNotEmpty) _buildResolutionFilter(),
          const SizedBox(width: AppSpacing.md),
          if (widget.availableTags.isNotEmpty) _buildTagFilter(),
        ],
      ),
    );
  }

  Widget _buildOrderDropdown() {
    return DropdownButton<String>(
      value: _selectedOrder,
      dropdownColor: AppColors.fieldBackground,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
      underline: Container(
        height: 1,
        color: AppColors.borderDefault,
      ),
      items: const [
        DropdownMenuItem(value: 'recente', child: Text('Recentes')),
        DropdownMenuItem(value: 'popular', child: Text('Populares')),
        DropdownMenuItem(value: 'curtidas', child: Text('Mais Curtidos')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedOrder = value);
        _updateFilters();
      },
    );
  }

  Widget _buildColorFilter() {
    return DropdownButton<String?>(
      value: _selectedColor,
      hint: Text(
        'Cor',
        style: AppFonts.body(size: 12, color: AppColors.textSecondary),
      ),
      dropdownColor: AppColors.fieldBackground,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
      underline: Container(
        height: 1,
        color: AppColors.borderDefault,
      ),
      items: <DropdownMenuItem<String?>>[
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            'Cores',
            style: AppFonts.body(size: 12, color: AppColors.textPrimary),
          ),
        ),
        ..._commonColorOptions.entries.map((entry) {
          return DropdownMenuItem<String?>(
            value: entry.key,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: entry.value,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  entry.key,
                  style: AppFonts.body(size: 12, color: AppColors.textPrimary),
                ),
              ],
            ),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _selectedColor = value);
        _updateFilters();
      },
    );
  }

  Widget _buildResolutionFilter() {
    return DropdownButton<Resolucao?>(
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
      items: <DropdownMenuItem<Resolucao?>>[
        DropdownMenuItem<Resolucao?>(
          value: null,
          child: Text(
            'Resolução',
            style: AppFonts.body(size: 12, color: AppColors.textPrimary),
          ),
        ),
        ...widget.availableResolutions.map((res) {
          return DropdownMenuItem<Resolucao?>(
            value: res,
            child: Text(
              res.label,
              style: AppFonts.body(size: 12, color: AppColors.textPrimary),
            ),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _selectedResolution = value);
        _updateFilters();
      },
    );
  }

  Widget _buildTagFilter() {
    return DropdownButton<String?>(
      value: _selectedTag,
      hint: Text(
        'Tag',
        style: AppFonts.body(size: 12, color: AppColors.textSecondary),
      ),
      dropdownColor: AppColors.fieldBackground,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
      underline: Container(
        height: 1,
        color: AppColors.borderDefault,
      ),
      items: <DropdownMenuItem<String?>>[
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            'Tag',
            style: AppFonts.body(size: 12, color: AppColors.textPrimary),
          ),
        ),
        ...widget.availableTags.map((tag) {
          return DropdownMenuItem<String?>(
            value: tag,
            child: Text(
              tag,
              style: AppFonts.body(size: 12, color: AppColors.textPrimary),
            ),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _selectedTag = value);
        _updateFilters();
      },
    );
  }
}
