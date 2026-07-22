import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/components/progress_chart.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/components/stat_tile.dart';
import 'package:fitness_day/features/user/progress/presentation/manager/user_progress_cubit.dart';
import 'package:fitness_day/features/user/progress/presentation/manager/user_progress_state.dart';

/// Progress screen for the logged-in user. Reuses the same progress chart and
/// stat tiles as the specialist client-progress tab, but is driven by
/// [UserProgressCubit] (endpoint: /assessments/progress?visitNumber=N).
class UserProgressPage extends StatelessWidget {
  const UserProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserProgressCubit>(
      create: (_) => getIt<UserProgressCubit>()..loadProgress(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'home.category_progress'.tr(),
            style: TextStyleManager.style15Medium.copyWith(color: AppColors.black),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<UserProgressCubit, UserProgressState>(
          builder: (context, state) {
            if (state is UserProgressLoading || state is UserProgressInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is UserProgressFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyleManager.style13Medium.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<UserProgressCubit>().loadProgress(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: Text('common.retry'.tr(), style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            if (state is UserProgressSuccess) {
              final visit = state.data.visit;

              final weightVal = visit?.weight?.value?.toString() ?? '0';
              final weightUnit = visit?.weight?.unit ?? 'clients_page.kg'.tr();

              final heightVal = visit?.height?.value?.toString() ?? '0';
              final heightUnit = visit?.height?.unit ?? 'clients_page.cm'.tr();

              final idealWeightVal = visit?.idealWeight?.value?.toString() ?? '0';
              final idealWeightUnit = visit?.idealWeight?.unit ?? 'clients_page.kg'.tr();

              final bmiVal = visit?.bmi?.value?.toString() ?? '0';
              final bmiUnit = visit?.bmi?.unit ?? 'clients_page.bmi_unit'.tr();

              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                children: [
                  ProgressChart(
                    data: state.data,
                    selectedVisitNumber: state.selectedVisitNumber,
                    onSelectVisit: (visitNumber) => context
                        .read<UserProgressCubit>()
                        .loadProgress(visitNumber: visitNumber),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    'clients_page.visit_summary'.tr(),
                    style: TextStyleManager.style14Bold,
                  ),
                  SizedBox(height: 16.h),
                  StatTile(
                    label: 'clients_page.weight_short'.tr(),
                    value: weightVal,
                    measurement: weightUnit,
                    iconPath: SvgIcons.weight,
                    isCircle: false,
                  ),
                  StatTile(
                    label: 'clients_page.height_short'.tr(),
                    value: heightVal,
                    measurement: heightUnit,
                    iconPath: SvgIcons.height,
                    isCircle: false,
                  ),
                  StatTile(
                    label: 'clients_page.ideal_weight_short'.tr(),
                    value: idealWeightVal,
                    measurement: idealWeightUnit,
                    iconPath: SvgIcons.perfectWieght,
                    isCircle: false,
                  ),
                  StatTile(
                    label: 'clients_page.body_mass_short'.tr(),
                    value: bmiVal,
                    measurement: bmiUnit,
                    iconPath: SvgIcons.bodyMass,
                    isCircle: true,
                  ),
                  SizedBox(height: 24.h),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
