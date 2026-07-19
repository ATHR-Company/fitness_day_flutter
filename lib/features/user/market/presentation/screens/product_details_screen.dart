import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/product_details_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetailsScreen extends StatelessWidget {
  /// Pass only [product.id] — full details are fetched from the API.
  /// The [product] is used as a fallback for name/price while loading.
  final ProductData product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductDetailsCubit>()..load(product.id),
      child: _ProductDetailsView(fallback: product),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View
// ─────────────────────────────────────────────────────────────────────────────
class _ProductDetailsView extends StatefulWidget {
  final ProductData fallback;

  const _ProductDetailsView({required this.fallback});

  @override
  State<_ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<_ProductDetailsView> {
  int _quantity = 1;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        final isLoading = state is ProductDetailsLoading || state is ProductDetailsInitial;
        final product = state is ProductDetailsSuccess ? state.product : widget.fallback;
        final selectedPhoto = state is ProductDetailsSuccess ? state.selectedPhotoIndex : 0;

        return Scaffold(
          backgroundColor: AppColors.dialogBackground,
          body: SafeArea(
            child: Column(
              children: [
                _AppBar(title: 'market.product_details_title'.tr()),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (state is ProductDetailsFailure)
                  Expanded(
                    child: Center(
                      child: Text(state.message, style: TextStyleManager.style14Medium),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Photo carousel
                          _PhotoCarousel(
                            photos: product.photos.isNotEmpty
                                ? product.photos
                                : [product.imageUrl],
                            selectedIndex: selectedPhoto,
                            onPageChanged: (i) =>
                                context.read<ProductDetailsCubit>().selectPhoto(i),
                            pageController: _pageController,
                          ),
                          SizedBox(height: 16.h),

                          // Title + quantity
                          _TitleAndQuantity(
                            name: product.name,
                            quantity: _quantity,
                            onIncrement: () => setState(() => _quantity++),
                            onDecrement: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                          ),
                          SizedBox(height: 8.h),

                          // Price
                          _Price(
                            price: product.currentPrice,
                            oldPrice: product.oldPrice,
                          ),
                          SizedBox(height: 16.h),

                          // Details sections from API
                          if (product.details.isNotEmpty)
                            ...product.details.map(
                              (d) => _DetailsSection(
                                title: d.title,
                                body: d.description,
                              ),
                            )
                          else ...[
                            // Fallback static sections (shown while details not loaded)
                            _DetailsSection(
                              title: 'market.product_description_label'.tr(),
                              body: '',
                            ),
                          ],

                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomAddToCart(quantity: _quantity),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo Carousel
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoCarousel extends StatelessWidget {
  final List<String> photos;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final PageController pageController;

  const _PhotoCarousel({
    required this.photos,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                SizedBox(
                  height: 250.h,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: photos.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (_, i) => AppImage(
                      photos[i],
                      height: 250.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 12.h,
                  start: 12.w,
                  child: Row(
                    children: [
                      _IconBtn(Icons.favorite_border, AppColors.primary),
                      SizedBox(width: 8.w),
                      _IconBtn(Icons.share, AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (photos.length > 1) ...[
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (i) {
                final isActive = i == selectedIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: isActive ? 20.w : 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBtn(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20.sp),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Title + Quantity
// ─────────────────────────────────────────────────────────────────────────────
class _TitleAndQuantity extends StatelessWidget {
  final String name;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _TitleAndQuantity({
    required this.name,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyleManager.heading3.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Row(
            children: [
              GestureDetector(
                onTap: onIncrement,
                child: Icon(Icons.add_circle_outline,
                    color: AppColors.primary, size: 28.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                '$quantity',
                style: TextStyleManager.heading3.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: onDecrement,
                child: Icon(Icons.remove_circle_outline,
                    color: AppColors.primary, size: 28.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Price
// ─────────────────────────────────────────────────────────────────────────────
class _Price extends StatelessWidget {
  final double price;
  final double? oldPrice;

  const _Price({required this.price, this.oldPrice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '${price.toInt()}',
            style: TextStyleManager.heading1.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'home.sar'.tr(),
            style: TextStyleManager.style13Medium.copyWith(color: AppColors.black),
          ),
          if (oldPrice != null) ...[
            SizedBox(width: 12.w),
            Text(
              '${oldPrice!.toInt()} ${'home.sar'.tr()}',
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.error,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Details Section (from API `details` array)
// ─────────────────────────────────────────────────────────────────────────────
class _DetailsSection extends StatelessWidget {
  final String title;
  final String body;

  const _DetailsSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyleManager.style13Medium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final String title;

  const _AppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.arrow_back_ios_rounded,
                      size: 20.sp, color: AppColors.black),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: AppImage(SvgIcons.market_icon, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Add to Cart
// ─────────────────────────────────────────────────────────────────────────────
class _BottomAddToCart extends StatelessWidget {
  final int quantity;

  const _BottomAddToCart({required this.quantity});

  @override
  Widget build(BuildContext context) {
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
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppImage(SvgIcons.market_icon,
                          color: AppColors.white, width: 20.w, height: 20.h),
                      SizedBox(width: 8.w),
                      Text(
                        'market.add_to_cart'.tr(),
                        style: TextStyleManager.style15Medium.copyWith(
                          color: AppColors.white,
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
    );
  }
}
