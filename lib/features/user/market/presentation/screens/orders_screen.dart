import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/market/domain/entities/order_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/orders_cubit.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersCubit _ordersCubit = getIt<OrdersCubit>();

  @override
  void initState() {
    super.initState();
    _ordersCubit.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.marketScaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<OrdersCubit, OrdersState>(
                bloc: _ordersCubit,
                builder: (context, state) {
                  switch (state) {
                    case OrdersInitial():
                    case OrdersLoading():
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    case OrdersFailure():
                      return _buildErrorState(state.message);
                    case OrdersSuccess():
                      final orders = state.orders;
                      if (orders.isEmpty) {
                        return _buildEmptyState();
                      }
                      return RefreshIndicator(
                        onRefresh: () => _ordersCubit.loadOrders(),
                        color: AppColors.primary,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return _buildOrderCard(order);
                          },
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
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
            'market.orders_title'.tr(),
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
          SizedBox(height: 32.h),
          Text(
            'market.no_orders_title'.tr(),
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'market.no_orders_message'.tr(),
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => _ordersCubit.loadOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                'market.retry_button'.tr(),
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderData order) {
    final String statusLabel;
    final Color badgeColor;
    final Color textColor;

    switch (order.status) {
      case 'PENDING_PAYMENT':
        statusLabel = 'market.order_status_pending_payment'.tr();
        badgeColor = const Color(0xFFFFF6E6);
        textColor = const Color(0xFFE28B00);
        break;
      case 'COMPLETED':
      case 'DELIVERED':
        statusLabel = 'market.order_status_completed'.tr();
        badgeColor = const Color(0xFFEAF8EB);
        textColor = AppColors.success;
        break;
      case 'CANCELLED':
      case 'FAILED':
        statusLabel = 'market.order_status_cancelled'.tr();
        badgeColor = const Color(0xFFFEECEB);
        textColor = AppColors.error;
        break;
      default:
        statusLabel = 'market.order_status_pending'.tr();
        badgeColor = const Color(0xFFF5F5F5);
        textColor = AppColors.textSecondary;
    }

    String displayDate = order.createdAt;
    if (order.createdAt.contains('T')) {
      displayDate = order.createdAt.split('T')[0];
    }

    final shortId = order.id.length > 8
        ? order.id.substring(order.id.length - 8)
        : order.id;

    final int count = order.itemsCount ?? order.items.length;
    final String itemsLabel = count == 1
        ? 'market.items_count_single'.tr()
        : 'market.items_count_multi'.tr(args: [count.toString()]);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'market.order_id'.tr(args: [shortId]),
                style: TextStyleManager.style13Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyleManager.style9Medium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: AppColors.divider.withValues(alpha: 0.3), height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'market.order_date'.tr(args: [displayDate]),
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    itemsLabel,
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'market.order_total'.tr(args: [
                      order.total.toInt().toString(),
                      'home.sar'.tr(),
                    ]),
                    style: TextStyleManager.style14Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
