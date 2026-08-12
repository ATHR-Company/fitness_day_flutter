import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/orders_screen.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/cart_bottom_summary.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/cart_item_tile.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/orders_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    // Feeds both badges (cart + orders) from `GET /orders/counters`.
    _cart.loadCounters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dialogBackground,
      body: SafeArea(
        bottom: false,
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
                _CartAppBar(cart: _cart),
                Expanded(
                  child: state.isLoading && items.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : items.isEmpty
                          ? const _CartEmptyState()
                          : _CartItemList(items: items, state: state, cart: _cart),
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
          return CartBottomSummary(state: state);
        },
      ),
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _CartAppBar extends StatelessWidget {
  final CartCubit cart;

  const _CartAppBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: SizedBox(
        height: 47.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Title
            Text(
              'market.cart_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            // Back button — leading edge
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: SizedBox(
                  width: 47.w,
                  height: 47.w,
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
            // Orders icon — trailing edge
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OrdersIconButton(
                size: 47,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                  // Paying an order changes the count.
                  cart.loadCounters();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState();

  @override
  Widget build(BuildContext context) {
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
}

// ─── Items list ───────────────────────────────────────────────────────────────

class _CartItemList extends StatelessWidget {
  final List<CartItemData> items;
  final CartState state;
  final CartCubit cart;

  const _CartItemList({
    required this.items,
    required this.state,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CartItemTile(
          item: item,
          busy: state.isAdding(item.id),
          cart: cart,
        );
      },
    );
  }
}
