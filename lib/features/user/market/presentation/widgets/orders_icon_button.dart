import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';

/// The entry point to "My Orders", with the unpaid-orders count on it.
///
/// The number is `pendingPaymentOrdersCount` from `GET /orders/counters`, read
/// off the shared [CartCubit] — so every place this button appears shows the
/// same figure without fetching it again.
class OrdersIconButton extends StatelessWidget {
  final VoidCallback onTap;

  /// Diameter of the circular button. Bars use different sizes.
  final double size;

  const OrdersIconButton({super.key, required this.onTap, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      bloc: getIt<CartCubit>(),
      builder: (context, state) {
        final int count = state.pendingPaymentOrdersCount;
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size.w,
                height: size.w,
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: AppImage(
                    SvgIcons.branchPickup,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (count > 0)
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      // How many orders still owe money.
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18.w,
                      minHeight: 18.w,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      textAlign: TextAlign.center,
                      style: TextStyleManager.style9Medium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 8.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
