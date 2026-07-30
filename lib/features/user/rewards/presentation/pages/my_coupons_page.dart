import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/features/user/rewards/presentation/manager/my_coupons_cubit.dart';
import 'package:fitness_day/features/user/rewards/presentation/widgets/redemption_card.dart';

/// "كوبوناتي" — the coupons already bought with points, so a code the user saw
/// once at redeem time can always be found again.
class MyCouponsPage extends StatelessWidget {
  const MyCouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MyCouponsCubit>()..loadFirstPage(),
      child: const _MyCouponsView(),
    );
  }
}

class _MyCouponsView extends StatefulWidget {
  const _MyCouponsView();

  @override
  State<_MyCouponsView> createState() => _MyCouponsViewState();
}

class _MyCouponsViewState extends State<_MyCouponsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MyCouponsCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.profileGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: AppBackHeader(title: 'awards.my_coupons'.tr()),
              ),
              Expanded(
                child: BlocBuilder<MyCouponsCubit, MyCouponsState>(
                  builder: (context, state) {
                    return switch (state) {
                      MyCouponsLoaded(:final redemptions, :final isLoadingMore)
                          when redemptions.isNotEmpty =>
                        ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          itemCount: redemptions.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == redemptions.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.primary),
                                ),
                              );
                            }
                            return RedemptionCard(
                              redemption: redemptions[index],
                            );
                          },
                        ),
                      MyCouponsLoaded() => _EmptyState(),
                      // The backend's message is shown as-is; it is already in
                      // the language the request asked for.
                      MyCouponsFailure(:final message) =>
                        _MessageState(message: message),
                      _ => Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 56.sp, color: AppColors.divider),
          SizedBox(height: 12.h),
          Text(
            'awards.no_coupons'.tr(),
            style: TextStyleManager.style13Medium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final String message;

  const _MessageState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.primary, size: 44.sp),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleManager.style11Medium,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.read<MyCouponsCubit>().loadFirstPage(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: Text('awards.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
