import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/domain/usecases/toggle_favorite_usecase.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/subscription_package_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

export 'package:fitness_day/features/user/user_home/domain/entities/subscription_package_data.dart';

class SubscriptionPackageCard extends StatefulWidget {
  final SubscriptionPackageData package;
  final String detailsLabelKey;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsTap;
  /// Optional badge text (e.g. "عرض خاص") shown top-left of image.
  final String? badge;

  /// When provided, the bottom button becomes an *add to cart* action instead
  /// of a details navigation: it calls this, shows a spinner while [isAdding],
  /// and switches to a ✓ "added" state once [isInCart].
  final VoidCallback? onAddToCart;
  final bool isInCart;
  final bool isAdding;

  const SubscriptionPackageCard({
    super.key,
    required this.package,
    this.detailsLabelKey = 'home.details_button',
    this.isSelected = false,
    this.onTap,
    this.onDetailsTap,
    this.badge,
    this.onAddToCart,
    this.isInCart = false,
    this.isAdding = false,
  });

  @override
  State<SubscriptionPackageCard> createState() =>
      _SubscriptionPackageCardState();
}

class _SubscriptionPackageCardState extends State<SubscriptionPackageCard> {
  late bool _isFavorite;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.package.isFavorite;
  }

  Future<void> _handleFavoriteTap() async {
    if (_isTogglingFavorite) return;
    // Optimistic update
    setState(() {
      _isFavorite = !_isFavorite;
      _isTogglingFavorite = true;
    });
    // A package is a PLAN, not a product — the server keys favourites by both.
    final result = await getIt<ToggleFavoriteUseCase>()(
      itemType: CartItemType.plan,
      itemIdentity: widget.package.id,
    );
    if (!mounted) return;

    // The use case reports failure through ApiResult rather than throwing, so
    // the rollback has to be driven off the result, not a catch block.
    setState(() {
      if (result is Success<bool>) {
        _isFavorite = result.data;
      } else {
        _isFavorite = !_isFavorite;
      }
      _isTogglingFavorite = false;
    });
  }

  Widget _buildDetailsButton() {
    return ElevatedButton(
      onPressed: widget.onDetailsTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 4.w),
          Text(
            widget.detailsLabelKey.tr(),
            style: TextStyleManager.style9Medium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(  Directionality.of(context) == ui.TextDirection.rtl
                      ?Icons.keyboard_double_arrow_left:Icons.keyboard_double_arrow_right,
              size: 14.sp, color: AppColors.white),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    final bool added = widget.isInCart;
    return ElevatedButton(
      // Disabled while adding, and once already in the cart.
      onPressed: (widget.isAdding || added) ? null : widget.onAddToCart,
      style: ElevatedButton.styleFrom(
        backgroundColor: added ? AppColors.marketGreen : AppColors.primary,
        disabledBackgroundColor:
            added ? AppColors.marketGreen : AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
      ),
      child: widget.isAdding
          ? SizedBox(
              width: 14.sp,
              height: 14.sp,
              child: const CircularProgressIndicator(
                strokeWidth: 1.6,
                color: AppColors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 4.w),
                Text(
                  (added ? 'market.added' : widget.detailsLabelKey).tr(),
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                added
                    ? Icon(Icons.check_circle_rounded,
                        size: 14.sp, color: AppColors.white)
                    : AppImage(SvgIcons.market_icon,
                        width: 14.sp, height: 14.sp, color: AppColors.white),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : AppColors.divider,
              width: widget.isSelected ? 1 : 0.5,
            ),
            boxShadow: AppShadows.primaryShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image with overlays ───────────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                      ),
                      child: AppImage(
                        widget.package.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Badge — top start (right in RTL)
                    if (widget.badge != null && widget.badge!.isNotEmpty)
                      PositionedDirectional(
                        top: 8.h,
                        start: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            widget.badge!,
                            style: TextStyleManager.style9Medium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Favourite button — top end (left in RTL)
                    PositionedDirectional(
                      top: 8.h,
                      end: 8.w,
                      child: GestureDetector(
                        onTap: _handleFavoriteTap,
                        child: Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.primaryShadow,
                          ),
                          child: _isTogglingFavorite
                              ? SizedBox(
                                  width: 18.sp,
                                  height: 18.sp,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _isFavorite
                                      ? AppColors.error
                                      : AppColors.primary,
                                  size: 18.sp,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Details ──────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.package.name,
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${widget.package.currentPrice}',
                          style: TextStyleManager.style15Medium.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'home.sar'.tr(),
                          style: TextStyleManager.style8Medium.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        if (widget.package.oldPrice > 0) ...[
                          SizedBox(width: 10.w),
                          Text(
                            '${widget.package.oldPrice} ${'home.sar'.tr()}',
                            style: TextStyleManager.style8Medium.copyWith(
                              color: AppColors.error,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: SizedBox(
                        height: 32.h,
                        child: widget.onAddToCart != null
                            ? _buildAddToCartButton()
                            : _buildDetailsButton(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
