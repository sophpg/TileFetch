import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import '../theme/index.dart';
import '../services/search_history_service.dart';

class HomeSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(String) onSearch;
  final Function()? onClearSearch;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;

  const HomeSearchBar({
    super.key,
    required this.onSearch,
    this.onClearSearch,
    this.onSubmitted,
    this.onTap,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late TextEditingController _controller;
  final SearchHistoryService _historyService = SearchHistoryService();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      widget.onSearch(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      _historyService.addSearch(value);
      widget.onSubmitted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.borderDefault,
            width: AppBorders.defaultBorderWidth,
          ),
          color: AppColors.fieldBackground,
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Icon(
                Pixel.search,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.left,
                style: AppFonts.body(),
                decoration: InputDecoration(
                  hintText: 'Buscar pixel arts...',
                  hintStyle: AppFonts.body(
                    size: 16,
                    color: AppColors.textDisabled,
                  ),
                  border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 2),
                    isCollapsed: true,
                ),
                onSubmitted: _handleSubmitted,
                onTap: widget.onTap,
              ),
            ),
            if (_controller.text.isNotEmpty)
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Pixel.close,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onClearSearch?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}
