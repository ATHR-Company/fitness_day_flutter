import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Sticky bottom bar with the "Add to cart" / "Added ✓" button.
class ProductAddToCartBar extends StatelessWidget {
  final String productId;
  final int quantity;

  const ProductAddToCartBar({
    super.key,
    required this.productId,
    required this.quantity,
  });

  Future<void> _add(BuildContext context, CartCubit cart) async {
    final ok = await cart.addToCart(
      itemType: CartItemType.product,
      itemIdentity: productId,
      quantity: quantity,
    );
    if (!ok && context.mounted) {
      final msg = cart.state.errorMessage;
      if (msg != null && msg.isNotEmpty) {
        showAppSnackBar(context, text: msg, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = getIt<CartCubit>();

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
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),

              // Add to cart button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: BlocBuilder<CartCubit, CartState>(
                  bloc: cart,
                  builder: (context, state) {
                    final bool added = state.isInCart(productId);
                    final bool adding = state.isAdding(productId);

                    return ElevatedButton(
                      onPressed: (added || adding)
                          ? null
                          : () => _add(context, cart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            added ? AppColors.marketGreen : AppColors.primary,
                        disabledBackgroundColor:
                            added ? AppColors.marketGreen : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        elevation: 0,
                      ),
                      child: adding
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (added)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.white,
                                    size: 22.sp,
                                  )
                                else
                                  AppImage(
                                    SvgIcons.market_icon,
                                    color: AppColors.white,
                                    width: 20.w,
                                    height: 20.h,
                                  ),
                                SizedBox(width: 8.w),
                                Text(
                                  (added
                                          ? 'market.added'
                                          : 'market.add_to_cart')
                                      .tr(),
                                  style: TextStyleManager.style15Medium
                                      .copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    );
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
