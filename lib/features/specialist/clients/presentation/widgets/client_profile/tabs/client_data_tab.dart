import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/utils/measurement.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/components/info_card.dart';

class ClientDataTab extends StatelessWidget {
  final SpecialistClientProfileDataModel data;

  const ClientDataTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _buildProfileHeader(),
          SizedBox(height: 16.h),
          InfoCard(
            title: 'clients_page.bmi_report'.tr(),
            icon: Icon(
              Icons.monitor_weight_outlined,
              color: AppColors.primary,
              size: 24.sp,
            ),
            data: {
              'clients_page.body_mass'.tr():
                  '${data.bodyReport?.bmi?.value ?? ''} ${data.bodyReport?.bmi?.unit ?? ''} (${data.bodyReport?.bmi?.status ?? ''})',
              'clients_page.ideal_weight'.tr():
                  '${data.bodyReport?.idealWeight?.value ?? ''} ${data.bodyReport?.idealWeight?.unit ?? ''}',
              'clients_page.calories'.tr():
                  '${data.bodyReport?.calories?.value ?? ''} ${data.bodyReport?.calories?.unit ?? ''}',
              'clients_page.protein_needs'.tr():
                  '${data.bodyReport?.proteinNeeds?.value ?? ''} ${data.bodyReport?.proteinNeeds?.unit ?? ''}',
            },
            greenValues: [
              'clients_page.body_mass'.tr(),
              'clients_page.ideal_weight'.tr(),
              'clients_page.calories'.tr(),
              'clients_page.protein_needs'.tr(),
            ],
          ),
          _buildHealthProblemsCard(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final adherenceRate = data.userData?.adherenceRate;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(4.r),
          topEnd: Radius.circular(4.r),
          bottomStart: Radius.circular(4.r),
          bottomEnd: Radius.circular(32.r),
        ),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Stack(
        children: [
          // Badge
          if (adherenceRate != null)
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: AppColors.timeRemainingGradient,
                  borderRadius: BorderRadiusDirectional.only(
                    topEnd: Radius.circular(4.r),
                    bottomStart: Radius.circular(12.r),
                  ),
                  boxShadow: AppShadows.primaryShadow,
                ),
                child: Text(
                  'clients_page.commitment_rate'.tr(args: [adherenceRate.toInt().toString()]),
                  style: TextStyleManager.style10Medium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          SizedBox(height: 16.h),
        
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 70.r,
                      height: 70.r,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider, width: 2),
                      ),
                      child: ClipOval(
                        child: AppImage(
                          data.userData?.avatar ?? '',
                          width: 70.r,
                          height: 70.r,
                          fit: BoxFit.cover,
                          isAvatar: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        data.userData?.fullName ?? '',
                        style: TextStyleManager.style14Bold.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderDetail(
                            'clients_page.goal'.tr(),
                            data.userData?.goal ?? '',
                          ),
                          SizedBox(height: 8.h),
                          _buildHeaderDetail(
                            'clients_page.height_short'.tr(),
                            _measure(
                              data.userData?.height,
                              'clients_page.cm'.tr(),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _buildHeaderDetail(
                            'spec_mock_activity'.tr(),
                            data.userData?.activityLevel ?? '',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderDetail('clients_page.age'.tr(), data.userData?.age?.toString() ?? ''),
                          SizedBox(height: 8.h),
                          _buildHeaderDetail(
                            'clients_page.weight'.tr(),
                            _measure(
                              data.userData?.weight,
                              'clients_page.kg'.tr(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthProblemsCard() {
    final questions = data.healthQuestions ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(4.r),
          topEnd: Radius.circular(4.r),
          bottomStart: Radius.circular(4.r),
          bottomEnd: Radius.circular(32.r),
        ),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'clients_page.health_problems'.tr(),
                style: TextStyleManager.style14Bold,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (questions.isEmpty)
            Text(
              'clients_page.no_health_problems'.tr(),
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textPrimary,
              ),
            )
          else
            ...questions.map(
              (q) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AnswerMark(answer: q.answer),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            q.question ?? '',
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (q.details != null && q.details!.isNotEmpty)
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: 24.w, top: 4.h),
                        child: Text.rich(
                          TextSpan(
                            text: '${'clients_page.reason'.tr()} : ',
                            style: TextStyleManager.style10Medium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: q.details,
                                style: TextStyleManager.style10Medium.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// A measurement with its unit, or "not set" when the API has no value for
  /// this client. The old `?? 0` printed "0 سم", which reads as a client who
  /// is zero centimetres tall rather than one whose height was never recorded.
  String _measure(double? value, String unit) =>
      value == null ? 'profile_not_set'.tr() : Measurement.withUnit(value, unit);

  Widget _buildHeaderDetail(String label, String value) {
    return Text.rich(
      TextSpan(
        text: '$label : ',
        style: TextStyleManager.style11Medium.copyWith(
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(
            text: value,
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// The client's answer to one health question, as a mark next to it.
///
/// Yes and no are both real answers and are coloured as such — green and red.
/// A null answer is the third case: the question was never answered, so it
/// stays grey rather than being reported as a "no" the client never gave.
class _AnswerMark extends StatelessWidget {
  final bool? answer;

  const _AnswerMark({required this.answer});

  @override
  Widget build(BuildContext context) {
    return Icon(
      switch (answer) {
        true => Icons.check_circle_rounded,
        false => Icons.cancel_rounded,
        null => Icons.radio_button_unchecked_rounded,
      },
      color: switch (answer) {
        true => AppColors.primary,
        false => AppColors.error,
        null => AppColors.textSecondary,
      },
      size: 16.sp,
    );
  }
}
