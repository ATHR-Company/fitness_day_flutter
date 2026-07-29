import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/checkout/checkout_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/orders_screen.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartCubit _cart = getIt<CartCubit>();

  @override
  void initState() {
    super.initState();
    // Refresh against the server every time the cart is opened.
    _cart.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dialogBackground,
      body: SafeArea(
        child: BlocConsumer<CartCubit, CartState>(
          bloc: _cart,
          listenWhen: (prev, curr) =>
              curr.errorMessage != null &&
              curr.errorMessage != prev.errorMessage,
          listener: (context, state) {
            showAppSnackBar(context, text: state.errorMessage!, isError: true);
            _cart.clearError();
          },
          builder: (context, state) {
            final items = state.cart.items;
            return Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: state.isLoading && items.isEmpty
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: AppColors.primary),
                        )
                      : items.isEmpty
                          ? _buildEmptyState()
                          : _buildFilledState(items, state),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        bloc: _cart,
        builder: (context, state) {
          if (state.cart.items.isEmpty) return const SizedBox.shrink();
          return _buildBottomSummary(state);
        },
      ),
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
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
              child: _buildIconButton(
                child: AppImage(
                  SvgIcons.market_icon,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required Widget child, Color? background}) {
    return Container(
      width: 38.w,
      height: 38.w,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: background ?? AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(child: child),
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

  Widget _buildFilledState(List<CartItemData> items, CartState state) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: items.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        final bool busy = state.isAdding(item.id);
        return _CartItemTile(item: item, busy: busy, cart: _cart);
      },
    );
  }

  Widget _buildBottomSummary(CartState state) {
    final cart = state.cart;
    final bool canCheckout = cart.canCheckout;

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
                    '${cart.totalItems}',
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${cart.subtotal.toInt()}',
                        style: TextStyleManager.style13Medium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'home.sar'.tr(),
                        style: TextStyleManager.style9Medium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (!canCheckout) ...[
                SizedBox(height: 8.h),
                Text(
                  'market.cannot_checkout_hint'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: canCheckout
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.4),
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

// ─────────────────────────────────────────────────────────────────────────────
// Cart item tile
// ─────────────────────────────────────────────────────────────────────────────
class _CartItemTile extends StatelessWidget {
  final CartItemData item;
  final bool busy;
  final CartCubit cart;

  const _CartItemTile({
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Row(
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
                      ),
                      // Quantity selector
                      busy
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Row(
                              children: [
                                GestureDetector(
                                  onTap: () => cart.updateQuantity(
                                    itemIdentity: item.id,
                                    quantity: item.quantity + 1,
                                  ),
                                  child: Icon(
                                    Icons.add_circle,
                                    color: AppColors.primary,
                                    size: 22.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  '${item.quantity}',
                                  style:
                                      TextStyleManager.style13Medium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                GestureDetector(
                                  onTap: item.quantity > 1
                                      ? () => cart.updateQuantity(
                                            itemIdentity: item.id,
                                            quantity: item.quantity - 1,
                                          )
                                      : () => cart.removeItem(
                                            itemIdentity: item.id,
                                          ),
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
      ),
    );
  }
}
