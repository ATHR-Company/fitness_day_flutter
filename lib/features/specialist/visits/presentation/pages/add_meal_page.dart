import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/selection_bottom_sheet.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final List<Map<String, String>> _addedElements = [
    {'name': 'shared_mock_oats'.tr(), 'quantity': '45g'},
    {'name': 'shared_mock_milk'.tr(), 'quantity': '250ml'},
    {'name': 'shared_mock_nuts'.tr(), 'quantity': '10g'},
  ];

  String? _selectedMealType;
  String? _selectedMealName;

  void _showMealTypeSheet() {
    final items = [
      'add_meal.breakfast'.tr(),
      'add_meal.lunch'.tr(),
      'add_meal.dinner'.tr(),
      'add_meal.snacks'.tr(),
    ];
    showSelectionBottomSheet(
      context: context,
      title: 'add_meal.food_type'.tr(),
      items: items,
      showSearch: false,
      initialSelectedIndex: _selectedMealType != null
          ? items.indexOf(_selectedMealType!)
          : 0,
      onConfirm: (index) {
        setState(() {
          _selectedMealType = items[index];
        });
      },
    );
  }

  void _showMealNameSheet() {
    final items = [
      'add_meal.meal_1'.tr(),
      'add_meal.meal_2'.tr(),
      'add_meal.meal_3'.tr(),
      'add_meal.meal_4'.tr(),
    ];
    showSelectionBottomSheet(
      context: context,
      title: 'add_meal.meal_name'.tr(),
      items: items,
      showSearch: true,
      initialSelectedIndex: _selectedMealName != null
          ? items.indexOf(_selectedMealName!)
          : 0,
      onConfirm: (index) {
        setState(() {
          _selectedMealName = items[index];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.visitsBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Back Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppBackHeader(title: 'add_meal.title'.tr()),
              ),

              SizedBox(height: 32.h),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meal Type
                      _buildLabel('add_meal.food_type'.tr()),
                      _buildTextField(
                        hint:
                            _selectedMealType ?? 'add_meal.meal_type_hint'.tr(),
                        icon: Icons.chevron_left,
                        onTap: _showMealTypeSheet,
                        valueColor: _selectedMealType != null
                            ? AppColors.black
                            : AppColors.textSecondary.withValues(alpha: 0.5),
                      ),

                      SizedBox(height: 20.h),

                      // Meal Name
                      _buildLabel('add_meal.meal_name'.tr()),
                      _buildTextField(
                        hint:
                            _selectedMealName ?? 'add_meal.meal_name_hint'.tr(),
                        icon: Icons.chevron_left,
                        onTap: _showMealNameSheet,
                        valueColor: _selectedMealName != null
                            ? AppColors.black
                            : AppColors.textSecondary.withValues(alpha: 0.5),
                      ),

                      SizedBox(height: 20.h),

                      // Meal Time
                      _buildLabel('add_meal.meal_time'.tr()),
                      _buildTimeField(),

                      SizedBox(height: 24.h),

                      // Quantity & Add Element
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('add_meal.quantity'.tr()),
                          GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text(
                                'add_meal.add_element'.tr(),
                                style: TextStyleManager.heading3.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildQuantityField(),

                      SizedBox(height: 24.h),

                      // Added Elements List
                      ..._addedElements.map(
                        (element) => _buildAddedElement(element),
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),

              // Add Button
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: CustomButton(
                  text: 'add_meal.add_button'.tr(),
                  color: AppColors.primary,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyleManager.heading3.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    VoidCallback? onTap,
    Color? valueColor,
  }) {
    return TextFormField(
      readOnly: onTap != null,
      onTap: onTap,
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleManager.heading3.copyWith(
          color: valueColor ?? AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        fillColor: AppColors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
        suffixIcon: Icon(
          icon,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          size: 24.sp,
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: 'add_meal.meal_time_hint'.tr(),
        hintStyle: TextStyleManager.heading3.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        fillColor: AppColors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
        suffixIcon: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTint,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.divider.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'add_meal.am'.tr(),
                        style: TextStyleManager.heading3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: 'add_meal.element_name_hint'.tr(),
        hintStyle: TextStyleManager.heading3.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        fillColor: AppColors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
        suffixIcon: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTint,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.divider.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Center(
                    child: Text(
                      'add_meal.quantity'.tr(),
                      style: TextStyleManager.heading3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddedElement(Map<String, String> element) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '${element['name']} : ',
                style: TextStyleManager.heading3.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                element['quantity']!,
                style: TextStyleManager.heading3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
