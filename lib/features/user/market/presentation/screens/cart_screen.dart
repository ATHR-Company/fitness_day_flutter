import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/checkout_screen.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

// Dummy CartItem model
class CartItem {
  final ProductData product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Toggle this boolean to see empty/filled states, or base it on cartItems.isEmpty
  // For UI demonstration, we'll initialize it with some dummy data.
  // To view empty state, simply remove the items or change to empty list.
  List<CartItem> cartItems = [
    CartItem(
      product: ProductData(
        id: '1',
        name: 'market.mock_product_healthy_pack'.tr(),
        imageUrl:
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
        currentPrice: 3500,
        oldPrice: 5000,
      ),
      quantity: 1,
    ),
    CartItem(
      product: ProductData(
        id: '2',
        name: 'market.mock_product_gold_edition_carb'.tr(),
        imageUrl:
            'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
        currentPrice: 3500,
        oldPrice: 5000,
      ),
      quantity: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dialogBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: cartItems.isEmpty
                  ? _buildEmptyState()
                  : _buildFilledState(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cartItems.isEmpty ? null : _buildBottomSummary(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'market.cart_title'.tr(),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(
            SvgIcons.market_icon,
            width: 140.w,
            color: AppColors.textPlaceholder,
          ),
          // Empty Basket Icon
          SizedBox(height: 32.h),
          Text(
            'market.empty_cart_title'.tr(),
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'market.empty_cart_message'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'market.go_to_products'.tr(),
                style: TextStyleManager.style13Medium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: cartItems.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  40.r,
                ), // Highly rounded like in the image
                child: AppImage(
                  item.product.imageUrl,
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.product.name,
                            style: TextStyleManager.style11Medium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              cartItems.removeAt(index);
                            });
                          },
                          child: Icon(
                            Icons.close,
                            color: AppColors.primary,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${item.product.currentPrice.toInt()}',
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
                            if (item.product.oldPrice != null) ...[
                              SizedBox(width: 8.w),
                              Text(
                                '${item.product.oldPrice!.toInt()} ${'home.sar'.tr()}',
                                style: TextStyleManager.style9Medium.copyWith(
                                  color: AppColors.error,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Quantity selector
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  item.quantity++;
                                });
                              },
                              child: Icon(
                                Icons.add_circle,
                                color: AppColors.primary,
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '${item.quantity}',
                              style: TextStyleManager.style13Medium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: () {
                                if (item.quantity > 1) {
                                  setState(() {
                                    item.quantity--;
                                  });
                                }
                              },
                              child: Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.primary,
                                size: 22.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSummary() {
    final double total = cartItems.fold(
      0,
      (sum, item) => sum + (item.product.currentPrice * item.quantity),
    );

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
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'market.order_summary_title'.tr(),
                  style: TextStyleManager.style13Medium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'market.total_products_label'.tr(),
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${cartItems.length}',
                    style: TextStyleManager.style13Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'market.total_label'.tr(),
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${total.toInt()}',
                    style: TextStyleManager.style13Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'market.next_button'.tr(),
                    style: TextStyleManager.style15Medium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
