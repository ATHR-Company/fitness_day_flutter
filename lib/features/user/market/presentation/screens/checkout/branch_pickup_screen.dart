import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/presentation/manager/checkout_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/payment_method_screen.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/order_summary_panel.dart';

class BranchPickupScreen extends StatefulWidget {
  const BranchPickupScreen({super.key});

  @override
  State<BranchPickupScreen> createState() => _BranchPickupScreenState();
}

class _BranchPickupScreenState extends State<BranchPickupScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CheckoutCubit>();
    if (cubit.state.branches.isEmpty) cubit.loadBranches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dialogBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBranchSelector(context),
                    SizedBox(height: 24.h),
                    _buildContactInfo(),
                    SizedBox(height: 24.h),
                    _buildWorkingHours(context),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'market.branch_pickup_title'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 20.sp,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSelector(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        if (state.branchesLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state.branches.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(
              child: Text(
                'market.no_branches'.tr(),
                style: TextStyleManager.style11Medium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return Column(
          children: state.branches.map((branch) {
            final bool isSelected = state.branchIdentity == branch.id;
            return GestureDetector(
              onTap: () =>
                  context.read<CheckoutCubit>().setBranch(branch.id),
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                height: 56.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.2),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPlaceholder,
                          width: isSelected ? 4 : 1,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        branch.name,
                        style: TextStyleManager.style13Medium.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'market.contact_info_title'.tr(),
          style: TextStyleManager.style11Medium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 22.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.call, color: AppColors.white, size: 16.sp),
            ),
            SizedBox(width: 8.w),
            Text(
              '+966543759100',
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkingHours(BuildContext context) {
    final List<Map<String, String>> days = [
      {
        'day': 'common.weekdays_full.sat'.tr(),
        'time': 'market.working_hours_default'.tr(),
      },
      {
        'day': 'common.weekdays_full.sun'.tr(),
        'time': 'market.working_hours_default'.tr(),
      },
      {
        'day': 'common.weekdays_full.mon'.tr(),
        'time': 'market.working_hours_default'.tr(),
      },
      {
        'day': 'common.weekdays_full.tue'.tr(),
        'time': 'market.working_hours_default'.tr(),
      },
      {
        'day': 'common.weekdays_full.wed'.tr(),
        'time': 'market.working_hours_default'.tr(),
      },
      {
        'day': 'common.weekdays_full.thu'.tr(),
        'time': 'market.working_hours_default'.tr(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'market.working_hours_title'.tr(),
          style: TextStyleManager.style11Medium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            return _buildTimeCard(days[index]['day']!, days[index]['time']!);
          },
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: _buildTimeCard(
              'common.weekdays_full.fri'.tr(),
              'market.working_hours_friday'.tr(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard(String day, String time) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.access_time_filled,
                color: AppColors.primary,
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                day,
                style: TextStyleManager.style11Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            time,
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              const OrderSummaryPanel(),
              SizedBox(height: 16.h),
              BlocBuilder<CheckoutCubit, CheckoutState>(
                builder: (context, state) {
                  final bool hasBranch = state.branchIdentity != null;
                  return SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: hasBranch
                          ? () {
                              final checkoutCubit =
                                  context.read<CheckoutCubit>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: checkoutCubit,
                                    child: const PaymentMethodScreen(),
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.textSecondary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'market.confirm_order'.tr(),
                        style: TextStyleManager.style15Medium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
