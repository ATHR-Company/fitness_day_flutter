import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/app_text_field.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/features/specialist/programs/data/models/specialist_program_model.dart';
import 'package:fitness_day/features/specialist/programs/presentation/manager/programs_cubit.dart';
import 'package:fitness_day/features/specialist/programs/presentation/manager/programs_state.dart';
import 'package:fitness_day/features/specialist/visits/presentation/manager/visit_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pick a program, pick a week, confirm, apply.
///
/// Two cubits, deliberately: `ProgramsCubit` (created here) reads the
/// catalogue, and the visit's own `VisitDetailsCubit` (passed down from the
/// visit screen) does the write, because it owns the plan cache that has to be
/// rebuilt afterwards. Same split the add-meal / add-exercise screens use.
///
/// The confirmation step is not decoration. Applying a week **replaces all
/// seven days and discards whatever the client had already completed** — the
/// specialist has to see that before it happens.
class ApplyProgramPage extends StatefulWidget {
  final String assessmentId;

  /// The day tab the specialist came from, so the visit screen can re-render
  /// the day they were looking at rather than jumping to day 1.
  final int currentDayNumber;

  const ApplyProgramPage({
    super.key,
    required this.assessmentId,
    required this.currentDayNumber,
  });

  @override
  State<ApplyProgramPage> createState() => _ApplyProgramPageState();
}

class _ApplyProgramPageState extends State<ApplyProgramPage> {
  bool _isApplying = false;

  Future<void> _apply(
    SpecialistProgramModel program,
    SpecialistProgramWeekModel week,
  ) async {
    final confirmed = await _confirm(program, week);
    if (confirmed != true || !mounted) return;

    setState(() => _isApplying = true);

    final (success, message) =
        await context.read<VisitDetailsCubit>().applyProgram(
              assessmentId: widget.assessmentId,
              programId: program.id,
              weekNumber: week.weekNumber,
              currentDayNumber: widget.currentDayNumber,
            );

    if (!mounted) return;
    setState(() => _isApplying = false);

    if (!success) {
      showAppSnackBar(context, text: message, isError: true);
      return;
    }

    // Shown before the pop: showAppSnackBar resolves the overlay off this
    // context, and after popping this widget is deactivated.
    showAppSnackBar(context, text: message, isSuccess: true);

    // `true` tells the visit screen the plan changed under it.
    Navigator.of(context).pop(true);
  }

  Future<bool?> _confirm(
    SpecialistProgramModel program,
    SpecialistProgramWeekModel week,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'apply_program.confirm_title'.tr(),
          style: TextStyleManager.style8Bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'apply_program.confirm_body'.tr(namedArgs: {
                'program': program.name,
                'week': '${week.weekNumber}',
              }),
              style: TextStyleManager.style9Medium,
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'apply_program.confirm_warning'.tr(),
                style: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'apply_program.cancel'.tr(),
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'apply_program.confirm'.tr(),
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProgramsCubit>()..loadPrograms(),
      child: Builder(
        builder: (innerContext) => LoaderHud(
          isCall: _isApplying,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.visitsBackgroundGradient,
              ),
              child: SafeArea(
                child: TopCenteredConstrainedBox(
                  horizontalPadding: 0,
                  child: BlocBuilder<ProgramsCubit, ProgramsState>(
                    builder: (context, state) {
                      final selected =
                          state is ProgramsLoaded ? state.selectedProgram : null;

                      return Column(
                        children: [
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: AppBackHeader(
                              title: selected == null
                                  ? 'apply_program.title'.tr()
                                  : selected.name,
                              // On the week step, back returns to the program
                              // list instead of leaving the screen — the
                              // specialist is one tap into a two-step picker.
                              onBackPressed: selected == null
                                  ? null
                                  : () => context
                                      .read<ProgramsCubit>()
                                      .clearSelection(),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Expanded(child: _buildBody(context, state)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProgramsState state) {
    if (state is ProgramsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProgramsFailure) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyleManager.style9Medium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'apply_program.retry'.tr(),
                color: AppColors.primary,
                onPressed: () =>
                    context.read<ProgramsCubit>().loadPrograms(),
              ),
            ],
          ),
        ),
      );
    }

    if (state is! ProgramsLoaded) return const SizedBox.shrink();

    final selected = state.selectedProgram;

    return selected == null
        ? _buildProgramList(context, state)
        : _buildWeekList(context, selected, state);
  }

  Widget _buildProgramList(BuildContext context, ProgramsLoaded state) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: _ProgramSearchField(
            onSearch: (value) =>
                context.read<ProgramsCubit>().loadPrograms(search: value),
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: state.programs.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      'apply_program.no_programs'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyleManager.style9Medium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                  itemCount: state.programs.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (_, index) {
                    final program = state.programs[index];

                    return _ProgramCard(
                      program: program,
                      onTap: () =>
                          context.read<ProgramsCubit>().selectProgram(program),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWeekList(
    BuildContext context,
    SpecialistProgramModel program,
    ProgramsLoaded state,
  ) {
    if (state.isLoadingWeeks) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      itemCount: state.weeks.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, index) {
        final week = state.weeks[index];

        return _WeekCard(
          week: week,
          onTap: () => _apply(program, week),
        );
      },
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final SpecialistProgramModel program;
  final VoidCallback onTap;

  const _ProgramCard({required this.program, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            if (program.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  program.image,
                  width: 56.w,
                  height: 56.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => SizedBox(width: 56.w),
                ),
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.name,
                    style: TextStyleManager.style8Bold,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    program.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleManager.style10Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'apply_program.weeks_count'
                        .tr(namedArgs: {'count': '${program.weeksCount}'}),
                    style: TextStyleManager.style10Medium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 26.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  final SpecialistProgramWeekModel week;
  final VoidCallback onTap;

  const _WeekCard({required this.week, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'apply_program.week'
                        .tr(namedArgs: {'number': '${week.weekNumber}'}),
                    style: TextStyleManager.style8Bold,
                  ),
                  SizedBox(height: 6.h),
                  // What the week actually contains, so the specialist knows
                  // what they are about to overwrite the visit with.
                  Text(
                    'apply_program.week_summary'.tr(namedArgs: {
                      'days': '${week.daysCount}',
                      'meals': '${week.mealsCount}',
                      'workouts': '${week.workoutsCount}',
                      'activities': '${week.activitiesCount}',
                    }),
                    style: TextStyleManager.style10Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 26.sp,
            ),
          ],
        ),
      ),
    );
  }
}

/// Search box with its own debounce.
///
/// `AppTextField` exposes a controller but no `onChanged`, so the debounce
/// hangs off a controller listener here rather than adding a parameter to a
/// widget a dozen other screens use.
class _ProgramSearchField extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const _ProgramSearchField({required this.onSearch});

  @override
  State<_ProgramSearchField> createState() => _ProgramSearchFieldState();
}

class _ProgramSearchFieldState extends State<_ProgramSearchField> {
  static const _debounce = Duration(milliseconds: 400);

  final TextEditingController _controller = TextEditingController();
  Timer? _timer;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final query = _controller.text.trim();

    // The listener also fires for selection and focus changes; without this
    // the list would refetch every time the caret moved.
    if (query == _lastQuery) return;
    _lastQuery = query;

    _timer?.cancel();
    _timer = Timer(_debounce, () => widget.onSearch(query));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      hintText: 'apply_program.search_hint'.tr(),
      suffixIcon: Icon(
        Icons.search,
        color: AppColors.textSecondary.withValues(alpha: 0.5),
        size: 22.sp,
      ),
    );
  }
}
