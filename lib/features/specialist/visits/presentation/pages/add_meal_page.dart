import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
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
import 'package:fitness_day/core/widgets/time_picker_bottom_sheet.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/utils/date_time_utils.dart';
import 'package:fitness_day/core/utils/plan_day_time.dart';
import 'package:fitness_day/features/specialist/visits/data/datasources/specialist_visits_remote_datasource.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_plan_lookups_model.dart';
import 'package:fitness_day/features/specialist/visits/presentation/manager/visit_details_cubit.dart';

class AddMealPage extends StatefulWidget {
  final String assessmentId;
  final int dayNumber;
  final String weekStart; // Assessment week start — base date for the day

  /// The meal being edited, or null in add mode.
  ///
  /// The whole model is passed rather than a handful of display strings: it
  /// carries the category and template **ids** and the ingredient weights that
  /// were actually saved, which is everything this screen needs to open showing
  /// the plan as it stands.
  final SpecialistMealModel? meal;

  const AddMealPage({
    super.key,
    required this.assessmentId,
    required this.dayNumber,
    required this.weekStart,
    this.meal,
  });

  bool get isEditMode => meal != null;

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
    _initData();
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
    try {
      final cats = await _remoteDataSource.getMealCategories();
      _categories = cats;
    } catch (_) {}
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    await _loadCategories();

    final SpecialistMealModel? meal = widget.meal;
    if (meal != null && _categories.isNotEmpty) {
      // Edit mode: everything comes off the plan item itself — no GET, and no
      // matching by display name. `firstWhereOrNull` on the id means a lookup
      // the backend has since removed leaves the field empty and asking to be
      // filled, instead of quietly selecting the first entry in the list.
      _selectedCategory = _categories
          .firstWhereOrNull((c) => c.id == meal.mealCategoryId);

      if (_selectedCategory != null) {
        try {
          _templates = await _remoteDataSource.getMealTemplates(
            categoryId: _selectedCategory!.id,
          );
          _selectedTemplate = _templates
              .firstWhereOrNull((t) => t.id == meal.mealTemplateId);
        } catch (_) {}
      }

      if (_selectedTemplate != null) {
        _ingredients = _ingredientsFor(_selectedTemplate!, saved: meal.ingredients);
      }

      final parsed = DateTime.tryParse(meal.time);
      if (parsed != null) {
        final localDate = parsed.isUtc ? parsed.toLocal() : parsed;
        _selectedTime = TimeOfDay.fromDateTime(localDate);
      }
    }

    setState(() => _isLoading = false);
  }

  /// Rows for the ingredient editor.
  ///
  /// The template defines *which* ingredients a meal has; [saved] — present
  /// only when editing — defines the weights this client was actually
  /// prescribed. Reading the template's defaults instead meant opening an
  /// edited meal reset every weight, and saving without noticing wrote those
  /// defaults back over the specialist's own numbers.
  List<Map<String, dynamic>> _ingredientsFor(
    SpecialistMealTemplateModel template, {
    List<SpecialistMealIngredientModel> saved = const [],
  }) {
    return template.ingredients.map((i) {
      final SpecialistMealIngredientModel? stored =
          saved.firstWhereOrNull((s) => s.ingredientId == i.ingredientId);
      final double weight = stored?.weight ?? i.defaultWeight;
      return {
        'ingredientId': i.ingredientId,
        'name': i.name,
        'weight': weight,
        'unit': i.unit,
        'controller': TextEditingController(text: weight.toStringAsFixed(0)),
      };
    }).toList();
  }

  /// Disposes the controllers of the rows being replaced — rebuilding the list
  /// without this leaks one controller per ingredient on every meal change.
  void _replaceIngredients(List<Map<String, dynamic>> next) {
    for (final ing in _ingredients) {
      (ing['controller'] as TextEditingController?)?.dispose();
    }
    _ingredients = next;
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
          _replaceIngredients([]);
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
      searchHintKey: 'add_meal.search_meal_name',
      initialSelectedIndex: _selectedTemplate != null
          ? _templates.indexOf(_selectedTemplate!)
          : 0,
      onConfirm: (index) {
        final template = _templates[index];
        setState(() {
          _selectedTemplate = template;
          // Picking a different meal starts from that meal's own defaults —
          // the previous meal's weights have nothing to say about it.
          _replaceIngredients(_ingredientsFor(template));
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
                  child: AppBackHeader(
                    title: widget.isEditMode
                        ? 'add_meal.edit_title'.tr()
                        : 'add_meal.title'.tr(),
                  ),
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
                                ? Icons.chevron_right
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
                                ? Icons.chevron_right
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
                          AppFieldLabel(text: 'add_meal.ingredients'.tr()),
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
                                          _unitLabel(ing['unit'] as String?),
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
                    text: widget.isEditMode
                        ? 'visit_details.save'.tr()
                        : 'add_meal.add_button'.tr(),
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

  /// Ingredient units arrive from the server as English identifiers. Only the
  /// ones the app has wording for are translated; anything else is shown as it
  /// came, which beats blanking out a unit the backend just introduced.
  String _unitLabel(String? unit) {
    if (unit == 'gram') return 'add_meal.unit_gram'.tr();
    return unit ?? '';
  }

  Widget _buildTimeField() {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);

    return AppTextField(
      hintText: formatPlanClock(dt),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      onTap: () async {
        final time = await showModalBottomSheet<TimeOfDay>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TimePickerBottomSheet(initialTime: _selectedTime),
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      readOnly: true,
    );
  }

  Future<void> _onSave() async {
    if (_selectedCategory == null || _selectedTemplate == null) {
      showAppSnackBar(
        context,
        text: 'add_meal.select_type_and_name_first'.tr(),
        isError: true,
      );
      return;
    }

    final ingredientWeights = _ingredients.map((i) {
      final controller = i['controller'] as TextEditingController;
      final weight = double.tryParse(controller.text) ?? i['weight'];
      return {
        'ingredientId': i['ingredientId'],
        'weight': weight,
      };
    }).toList();

    final timeStr = buildPlanItemTime(
      weekStart: widget.weekStart,
      dayNumber: widget.dayNumber,
      time: _selectedTime,
    );

    setState(() => _isLoading = true);
    final cubit = context.read<VisitDetailsCubit>();

    final bool success;
    final String message;

    if (widget.isEditMode) {
      // Edit mode (PATCH)
      final result = await cubit.updateMeal(
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        mealId: widget.meal!.mealId,
        mealCategoryId: _selectedCategory!.id,
        mealTemplateId: _selectedTemplate!.id,
        time: timeStr,
        ingredientWeights: ingredientWeights,
      );
      success = result.$1;
      message = result.$2;
    } else {
      // Add mode (POST)
      final result = await cubit.addMeal(
        assessmentId: widget.assessmentId,
        dayNumber: widget.dayNumber,
        mealCategoryId: _selectedCategory!.id,
        mealTemplateId: _selectedTemplate!.id,
        time: timeStr,
        ingredientWeights: ingredientWeights,
      );
      success = result.$1;
      message = result.$2;
    }

    setState(() => _isLoading = false);

    if (mounted) {
      showAppSnackBar(context, text: message, isSuccess: success, isError: !success);
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
