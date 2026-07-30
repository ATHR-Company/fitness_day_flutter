import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/plan_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';

class PackageDetailsDialog extends StatelessWidget {
  /// Provide either [planId] (preferred — fetches real data) or the legacy
  /// [package] fallback for non-plan product dialogs.
  final String? planId;
  final ProductData? package;
  final bool isSubscribed;
  final String? expiryDate;

  const PackageDetailsDialog({
    super.key,
    this.planId,
    this.package,
    this.isSubscribed = false,
    this.expiryDate,
  }) : assert(planId != null || package != null,
            'Provide planId or package');

  @override
  Widget build(BuildContext context) {
    if (planId != null) {
      return BlocProvider(
        create: (_) => getIt<PlanDetailsCubit>()..load(planId!),
        child: _PlanDetailsDialogContent(
          isSubscribed: isSubscribed,
          expiryDate: expiryDate,
        ),
      );
    }

    // Legacy fallback — uses ProductData directly
    return _StaticDialogContent(
      name: package!.name,
      imageUrl: package!.imageUrl,
      price: package!.currentPrice,
      descriptions: const [],
      isSubscribed: isSubscribed,
      expiryDate: expiryDate,
      cartItemId: package!.id,
      cartItemType: CartItemType.product,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// API-driven content
// ─────────────────────────────────────────────────────────────────────────────
class _PlanDetailsDialogContent extends StatefulWidget {
  final bool isSubscribed;
  final String? expiryDate;

  const _PlanDetailsDialogContent({
    required this.isSubscribed,
    this.expiryDate,
  });

  @override
  State<_PlanDetailsDialogContent> createState() =>
      _PlanDetailsDialogContentState();
}

class _PlanDetailsDialogContentState extends State<_PlanDetailsDialogContent> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanDetailsCubit, PlanDetailsState>(
      builder: (context, state) {
        if (state is PlanDetailsLoading || state is PlanDetailsInitial) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            backgroundColor: AppColors.white,
            insetPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: SizedBox(
              height: 200.h,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        if (state is PlanDetailsFailure) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            backgroundColor: AppColors.white,
            insetPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Text(state.message,
                  style: TextStyleManager.style14Medium,
                  textAlign: TextAlign.center),
            ),
          );
        }

        if (state is! PlanDetailsSuccess) return const SizedBox.shrink();

        final details = state.details;
        final photos = details.photos.isNotEmpty
            ? details.photos
            : [details.coverPhoto];

        // `GET /plans/:id` returns a `subscription` object when the user is
        // subscribed to this plan, so the dialog knows on its own — the
        // caller no longer has to say so (only the store's "current
        // subscription" card used to pass it).
        return _StaticDialogContent(
          name: details.name,
          imageUrl: details.coverPhoto,
          photos: photos,
          selectedPhotoIndex: state.selectedPhotoIndex,
          pageController: _pageController,
          onPageChanged: (i) =>
              context.read<PlanDetailsCubit>().selectPhoto(i),
          price: details.price,
          descriptions: details.descriptions,
          isSubscribed: details.isSubscribed || widget.isSubscribed,
          expiryDate: details.subscription?.endDate ?? widget.expiryDate,
          cartItemId: details.id,
          cartItemType: CartItemType.plan,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable dialog layout
// ─────────────────────────────────────────────────────────────────────────────
class _StaticDialogContent extends StatelessWidget {
  final String name;
  final String imageUrl;
  final List<String> photos;
  final int selectedPhotoIndex;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;
  final double price;
  final List<String> descriptions;
  final bool isSubscribed;
  final String? expiryDate;
  final String? cartItemId;
  final CartItemType cartItemType;

  const _StaticDialogContent({
    required this.name,
    required this.imageUrl,
    this.photos = const [],
    this.selectedPhotoIndex = 0,
    this.pageController,
    this.onPageChanged,
    required this.price,
    required this.descriptions,
    required this.isSubscribed,
    this.expiryDate,
    this.cartItemId,
    this.cartItemType = CartItemType.plan,
  });

  /// The API sends the end date as an ISO timestamp
  /// (`2026-08-25T18:45:08.902Z`); show it as a plain local date.
  String _formatExpiry(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd/MM/yyyy').format(parsed.toLocal());
  }

  Future<void> _addToCart(BuildContext context, CartCubit cart) async {
    final id = cartItemId;
    if (id == null) return;
    final ok = await cart.addToCart(itemType: cartItemType, itemIdentity: id);
    if (!ok && context.mounted) {
      final msg = cart.state.errorMessage;
      if (msg != null && msg.isNotEmpty) {
        showAppSnackBar(context, text: msg, isError: true);
      }
    }
  }

  Widget _buildAddToCartButton(BuildContext context) {
    final cart = getIt<CartCubit>();
    return BlocBuilder<CartCubit, CartState>(
      bloc: cart,
      builder: (context, state) {
        final bool added = cartItemId != null && state.isInCart(cartItemId!);
        final bool adding = cartItemId != null && state.isAdding(cartItemId!);
        return ElevatedButton(
          onPressed:
              (added || adding) ? null : () => _addToCart(context, cart),
          style: ElevatedButton.styleFrom(
            backgroundColor: added ? AppColors.marketGreen : AppColors.primary,
            disabledBackgroundColor:
                added ? AppColors.marketGreen : AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            elevation: 0,
          ),
          child: adding
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (added)
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.white, size: 20.sp)
                    else
                      AppImage(SvgIcons.market_icon,
                          color: AppColors.white, width: 20.w, height: 20.h),
                    SizedBox(width: 8.w),
                    Text(
                      (added ? 'market.added' : 'market.add_to_cart').tr(),
                      style: TextStyleManager.style13Medium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPhotos = photos.isNotEmpty ? photos : [imageUrl];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'market.package_details_title'.tr(),
                    style: TextStyleManager.style15Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close,
                          color: AppColors.primary, size: 24.sp),
                    ),
                  ),
                ],
              ),
            ),

            // ── Photo carousel ───────────────────────────────────────────────
            ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(0.r)),
              child: SizedBox(
                height: 180.h,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: displayPhotos.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (_, i) => AppImage(
                    displayPhotos[i],
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Dots
            if (displayPhotos.length > 1) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(displayPhotos.length, (i) {
                  final isActive = i == selectedPhotoIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: isActive ? 18.w : 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }),
              ),
            ],

            // ── Title & Price ────────────────────────────────────────────────
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyleManager.style13Medium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                      softWrap: true,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${price.toInt()}',
                        style: TextStyleManager.style15Medium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'home.sar'.tr(),
                        style: TextStyleManager.style11Medium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Descriptions ─────────────────────────────────────────────────
            if (descriptions.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: descriptions.map((desc) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5.h),
                            child: Icon(Icons.circle,
                                color: AppColors.primary, size: 10.sp),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              desc,
                              style: TextStyleManager.style9Medium.copyWith(
                                color: AppColors.black,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            SizedBox(height: 16.h),

            // ── Subscription section / Add to cart button ────────────────────
            if (isSubscribed) ...[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTint,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month,
                            color: AppColors.primary, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'market.subscription_expiry_label'.tr(),
                          style: TextStyleManager.style9Medium.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatExpiry(expiryDate),
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
          ] else ...[
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 40.w, vertical: 8.h),
                child: SizedBox(
                  height: 48.h,
                  child: _buildAddToCartButton(context),
                ),
              ),
            ],
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
