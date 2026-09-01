import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';

/// Horizontally scrollable pill selector for product categories.
///
/// Keeps the selected pill on screen: the row scrolls back to offset 0 every
/// time it is rebuilt (switching market tabs disposes and rebuilds it), so a
/// category picked far to the right would otherwise scroll out of view and
/// leave "All" sitting at the start — reading as if the filter had reset.
class MarketCategoriesRow extends StatefulWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const MarketCategoriesRow({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  State<MarketCategoriesRow> createState() => _MarketCategoriesRowState();
}

class _MarketCategoriesRowState extends State<MarketCategoriesRow> {
  final ScrollController _controller = ScrollController();
  final Map<int, GlobalKey> _pillKeys = {};

  @override
  void initState() {
    super.initState();
    // First frame: a rebuilt row starts at offset 0, so reveal the pill the
    // cubit still has selected.
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected(false));
  }

  @override
  void didUpdateWidget(covariant MarketCategoriesRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected(true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _revealSelected(bool animate) {
    if (!mounted || !_controller.hasClients) return;
    final pillContext = _pillKeys[widget.selectedIndex]?.currentContext;
    if (pillContext == null) return;
    Scrollable.ensureVisible(
      pillContext,
      // Centres the pill rather than just nudging it past the edge, so the
      // neighbouring categories stay visible as scroll affordances.
      alignment: 0.5,
      duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(widget.categories.length, (index) {
              final isSelected = widget.selectedIndex == index;
              return Padding(
                key: _pillKeys.putIfAbsent(index, GlobalKey.new),
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: GestureDetector(
                  onTap: () => widget.onSelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: AppColors.backgroundTint,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: AppShadows.primaryShadow,
                          )
                        : BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                    child: Text(
                      widget.categories[index],
                      style: TextStyleManager.style11Medium.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
