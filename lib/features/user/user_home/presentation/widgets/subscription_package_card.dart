import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
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

  const SubscriptionPackageCard({
    super.key,
    required this.package,
    this.detailsLabelKey = 'home.details_button',
    this.isSelected = false,
    this.onTap,
    this.onDetailsTap,
    this.badge,
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
    try {
      final useCase = getIt<ToggleFavoriteUseCase>();
      await useCase(widget.package.id);
    } catch (_) {
      // Roll back on failure
      if (mounted) setState(() => _isFavorite = !_isFavorite);
    } finally {
      if (mounted) setState(() => _isTogglingFavorite = false);
    }
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
                        child: ElevatedButton(
                          onPressed: widget.onDetailsTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                            padding:
                                EdgeInsets.symmetric(horizontal: 10.w),
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
                              Icon(Icons.keyboard_double_arrow_right,
                                  size: 14.sp, color: AppColors.white),
                            ],
                          ),
                        ),
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
