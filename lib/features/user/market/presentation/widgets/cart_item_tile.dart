import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A single row in the cart list showing the product image, name, price,
/// availability badge, and a quantity stepper.
class CartItemTile extends StatelessWidget {
  final CartItemData item;
  final bool busy;
  final CartCubit cart;

  const CartItemTile({
    super.key,
    required this.item,
    required this.busy,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: item.isAvailable ? 1 : 0.6,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: item.isAvailable
                ? AppColors.textSecondary.withValues(alpha: 0.2)
                : AppColors.error.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            // ── Product image ────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(40.r),
              child: AppImage(
                item.mainPhoto,
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(width: 12.w),

            // ── Name + price + stepper ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row + delete button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyleManager.style11Medium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: busy
                            ? null
                            : () => cart.removeItem(itemIdentity: item.id),
                        child: Icon(
                          Icons.close,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),

                  // Unavailable badge
                  if (!item.isAvailable)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        'market.item_unavailable'.tr(),
                        style: TextStyleManager.style9Medium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  SizedBox(height: 8.h),

                  // Price + quantity stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PriceLabel(item: item),
                      if (busy)
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      else
                        _QuantityStepper(item: item, cart: cart),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Price label ──────────────────────────────────────────────────────────────

class _PriceLabel extends StatelessWidget {
  final CartItemData item;

  const _PriceLabel({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${item.price.toInt()}',
          style: TextStyleManager.style13Medium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          'home.sar'.tr(),
          style: TextStyleManager.style9Medium.copyWith(
            color: AppColors.black,
          ),
        ),
        if (item.compareAtPrice != null &&
            item.compareAtPrice! > item.price) ...[
          SizedBox(width: 8.w),
          Text(
            '${item.compareAtPrice!.toInt()} ${'home.sar'.tr()}',
            style: TextStyleManager.style9Medium.copyWith(
              color: AppColors.error,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Quantity stepper ─────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  final CartItemData item;
  final CartCubit cart;

  const _QuantityStepper({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Increment
        GestureDetector(
          onTap: () => cart.updateQuantity(
            itemIdentity: item.id,
            quantity: item.quantity + 1,
          ),
          child: Icon(Icons.add_circle, color: AppColors.primary, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          '${item.quantity}',
          style: TextStyleManager.style13Medium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 12.w),
        // Decrement / remove
        GestureDetector(
          onTap: item.quantity > 1
              ? () => cart.updateQuantity(
                    itemIdentity: item.id,
                    quantity: item.quantity - 1,
                  )
              : () => cart.removeItem(itemIdentity: item.id),
          child: Icon(
            Icons.remove_circle_outline,
            color: AppColors.primary,
            size: 22.sp,
          ),
        ),
      ],
    );
  }
}
