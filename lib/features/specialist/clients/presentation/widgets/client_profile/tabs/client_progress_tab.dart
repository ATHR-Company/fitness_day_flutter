import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/utils/measurement.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/client_progress_cubit.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/client_progress_state.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/components/progress_chart.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/components/stat_tile.dart';

class ClientProgressTab extends StatelessWidget {
  final String userId;

  const ClientProgressTab({super.key, required this.userId});

  /// Two decimals at most; `'-'` when the visit has no reading for this metric,
  /// so a missing value doesn't read as a measured zero.
  static String _measure(double? value) =>
      value == null ? '-' : Measurement.format(value);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientProgressCubit>(
      create: (context) => getIt<ClientProgressCubit>()..loadProgress(userId: userId),
      child: BlocBuilder<ClientProgressCubit, ClientProgressState>(
        builder: (context, state) {
          if (state is ClientProgressLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ClientProgressFailure) {
            return AppErrorView(
              error: state.error,
              message: state.message,
              onRetry: () => context.read<ClientProgressCubit>().loadProgress(userId: userId),
            );
          }

          if (state is ClientProgressSuccess) {
            final visit = state.data.visit;

            // These come off the wire as raw doubles — a weight arrived as
            // 50.066556668568886 and `toString()` rendered every digit of it.
            final weightVal = _measure(visit?.weight?.value);
            final weightUnit = visit?.weight?.unit ?? 'clients_page.kg'.tr();

            final heightVal = _measure(visit?.height?.value);
            final heightUnit = visit?.height?.unit ?? 'clients_page.cm'.tr();

            final idealWeightVal = _measure(visit?.idealWeight?.value);
            final idealWeightUnit = visit?.idealWeight?.unit ?? 'clients_page.kg'.tr();

            final bmiVal = _measure(visit?.bmi?.value);
            final bmiUnit = visit?.bmi?.unit ?? 'clients_page.bmi_unit'.tr();

            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              children: [
                ProgressChart(
                  data: state.data,
                  selectedVisitNumber: state.selectedVisitNumber,
                  onSelectVisit: (visitNumber) => context
                      .read<ClientProgressCubit>()
                      .loadProgress(userId: userId, visitNumber: visitNumber),
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
    );
  }
}
