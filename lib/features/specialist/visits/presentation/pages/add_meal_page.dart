import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_text_field.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/selection_bottom_sheet.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/specialist/visits/data/datasources/specialist_visits_remote_datasource.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_plan_lookups_model.dart';
import 'package:fitness_day/features/specialist/visits/presentation/manager/visit_details_cubit.dart';

class AddMealPage extends StatefulWidget {
  final String assessmentId;
  final int dayNumber;

  const AddMealPage({
    super.key,
    required this.assessmentId,
    required this.dayNumber,
  });

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final _remoteDataSource = getIt<SpecialistVisitsRemoteDataSource>();

  List<SpecialistMealCategoryModel> _categories = [];
  List<SpecialistMealTemplateModel> _templates = [];

  SpecialistMealCategoryModel? _selectedCategory;
  SpecialistMealTemplateModel? _selectedTemplate;

  List<Map<String, dynamic>> _ingredients = [];
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    for (var ing in _ingredients) {
      final controller = ing['controller'] as TextEditingController?;
      controller?.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final cats = await _remoteDataSource.getMealCategories();
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTemplates(String categoryId) async {
    setState(() => _isLoading = true);
    try {
      final temps = await _remoteDataSource.getMealTemplates(categoryId: categoryId);
      setState(() {
        _templates = temps;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showMealTypeSheet() {
    if (_categories.isEmpty) return;
    final items = _categories.map((c) => c.name).toList();
    showSelectionBottomSheet(
      context: context,
      title: 'add_meal.food_type'.tr(),
      items: items,
      showSearch: false,
      initialSelectedIndex: _selectedCategory != null
          ? _categories.indexOf(_selectedCategory!)
          : 0,
      onConfirm: (index) {
        setState(() {
          _selectedCategory = _categories[index];
          _selectedTemplate = null;
          _templates = [];
          _ingredients = [];
        });
        _loadTemplates(_selectedCategory!.id);
      },
    );
  }

  void _showMealNameSheet() {
    if (_templates.isEmpty) return;
    final items = _templates.map((t) => t.name).toList();
    showSelectionBottomSheet(
      context: context,
      title: 'add_meal.meal_name'.tr(),
      items: items,
      showSearch: true,
      initialSelectedIndex: _selectedTemplate != null
          ? _templates.indexOf(_selectedTemplate!)
          : 0,
      onConfirm: (index) {
        final template = _templates[index];
        setState(() {
          _selectedTemplate = template;
          _ingredients = template.ingredients.map((i) => {
            'ingredientId': i.ingredientId,
            'name': i.name,
            'weight': i.defaultWeight,
            'unit': i.unit,
            'controller': TextEditingController(text: i.defaultWeight.toStringAsFixed(0)),
          }).toList();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoaderHud(
      isCall: _isLoading,
      child: Scaffold(
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
                        AppFieldLabel(text: 'add_meal.food_type'.tr()),
                        AppTextField(
                          hintText:
                              _selectedCategory?.name ?? 'add_meal.meal_type_hint'.tr(),
                          suffixIcon: Icon(
                            Directionality.of(context) == ui.TextDirection.rtl
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                            size: 24.sp,
                          ),
                          onTap: _showMealTypeSheet,
                          valueColor: _selectedCategory != null
                              ? AppColors.black
                              : AppColors.textSecondary.withValues(alpha: 0.5),
                          readOnly: true,
                        ),

                        SizedBox(height: 20.h),

                        // Meal Name
                        AppFieldLabel(text: 'add_meal.meal_name'.tr()),
                        AppTextField(
                          hintText:
                              _selectedTemplate?.name ?? 'add_meal.meal_name_hint'.tr(),
                          suffixIcon: Icon(
                            Directionality.of(context) == ui.TextDirection.rtl
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                            size: 24.sp,
                          ),
                          onTap: _showMealNameSheet,
                          valueColor: _selectedTemplate != null
                              ? AppColors.black
                              : AppColors.textSecondary.withValues(alpha: 0.5),
                          readOnly: true,
                        ),

                        SizedBox(height: 20.h),

                        // Meal Time
                        AppFieldLabel(text: 'add_meal.meal_time'.tr()),
                        _buildTimeField(),

                        if (_selectedTemplate != null && _ingredients.isNotEmpty) ...[
                          SizedBox(height: 24.h),
                          AppFieldLabel(text: 'المكونات'),
                          SizedBox(height: 10.h),
                          ..._ingredients.map((ing) {
                            final controller = ing['controller'] as TextEditingController;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      ing['name'],
                                      style: TextStyleManager.style11Medium.copyWith(color: AppColors.black),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    flex: 2,
                                    child: AppTextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      hintText: '0',
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                                        child: Text(
                                          ing['unit'] == 'gram' ? 'جرام' : ing['unit'],
                                          style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

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
                    onPressed: _onSave,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    final formatTime = DateFormat('hh:mm a', context.locale.languageCode);
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);

    return AppTextField(
      hintText: formatTime.format(dt),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      readOnly: true,
      suffixIcon: Icon(
        Icons.access_time_rounded,
        color: AppColors.primary,
        size: 20.sp,
      ),
    );
  }

  Future<void> _onSave() async {
    if (_selectedCategory == null || _selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار نوع ومسمى الوجبة أولاً'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final ingredientWeights = _ingredients.map((i) {
      final controller = i['controller'] as TextEditingController;
      final weight = double.tryParse(controller.text) ?? i['weight'];
      return {
        'ingredientId': i['ingredientId'] as String,
        'weight': weight,
      };
    }).toList();

    final now = DateTime.now();
    final timeStr = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute).toUtc().toIso8601String();

    setState(() => _isLoading = true);
    final cubit = context.read<VisitDetailsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final (success, message) = await cubit.addMeal(
      assessmentId: widget.assessmentId,
      dayNumber: widget.dayNumber,
      mealCategoryId: _selectedCategory!.id,
      mealTemplateId: _selectedTemplate!.id,
      time: timeStr,
      ingredientWeights: ingredientWeights,
    );

    setState(() => _isLoading = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.primary : AppColors.error,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }
}
