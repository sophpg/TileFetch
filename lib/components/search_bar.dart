import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import '../theme/index.dart';

class HomeSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function()? onClearSearch;

  const HomeSearchBar({super.key, required this.onSearch, this.onClearSearch});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late TextEditingController _controller;

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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderDefault, width: AppBorders.defaultBorderWidth),
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
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onClearSearch?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Icon(
                    Pixel.close,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
