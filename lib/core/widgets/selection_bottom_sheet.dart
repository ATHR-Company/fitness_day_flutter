import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';

class SelectionBottomSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final int initialSelectedIndex;
  final bool showSearch;
  final ValueChanged<int> onConfirm;

  const SelectionBottomSheet({
    super.key,
    required this.title,
    required this.items,
    this.initialSelectedIndex = 0,
    this.showSearch = false,
    required this.onConfirm,
  });

  @override
  State<SelectionBottomSheet> createState() => _SelectionBottomSheetState();
}

class _SelectionBottomSheetState extends State<SelectionBottomSheet> {
  late int _selectedIndex;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Filter items if search is enabled
    final filteredItems = widget.items.where((item) {
      return item.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.visitsBackgroundGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        20.w,
        32.h,
      ), // Extra padding at bottom for safe area
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyleManager.button,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.black, size: 24.sp),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Optional Search Bar
          if (widget.showSearch) ...[
            TextFormField(
              textAlign: TextAlign.start,
              style: TextStyleManager.style11Medium.copyWith(color: AppColors.black),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'add_meal.search_meal_name'.tr(),
                hintStyle: TextStyleManager.heading3.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: AppColors.divider,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: AppColors.divider,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.0,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // List of items
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filteredItems.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final originalIndex = widget.items.indexOf(item);
                final isSelected = _selectedIndex == originalIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = originalIndex;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.backgroundTint
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyleManager.style13Medium.copyWith(
                              color: isSelected
                                  ? AppColors.black
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.circle,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 32.h),

          // Confirm Button
          CustomButton(
            text: 'add_meal.confirm'.tr(),
            color: AppColors.primary,
            onPressed: () {
              widget.onConfirm(_selectedIndex);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

void showSelectionBottomSheet({
  required BuildContext context,
  required String title,
  required List<String> items,
  int initialSelectedIndex = 0,
  bool showSearch = false,
  required ValueChanged<int> onConfirm,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        // Handles keyboard pushing up the bottom sheet
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.6, // take up to 60% of screen height
          child: SelectionBottomSheet(
            title: title,
            items: items,
            initialSelectedIndex: initialSelectedIndex,
            showSearch: showSearch,
            onConfirm: onConfirm,
          ),
        ),
      );
    },
  );
}
