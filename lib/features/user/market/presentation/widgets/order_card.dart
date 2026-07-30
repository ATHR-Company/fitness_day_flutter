import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/utils/money_format.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/market/domain/entities/order_data.dart';

/// One row in the orders list: status, what was bought, the total, and — while
/// the order still owes money — a button to finish paying it.
class OrderCard extends StatelessWidget {
  /// How many item thumbnails fit before the rest collapse into "+N".
  static const int _maxVisibleItems = 3;

  final OrderData order;

  /// Starts (or resumes) the payment. Null hides the button entirely.
  final VoidCallback? onPayTap;

  /// Opens the order's contents. Null makes the card inert.
  final VoidCallback? onTap;

  /// A payment is already running for some order, so the button is inert.
  final bool isBusy;

  const OrderCard({
    super.key,
    required this.order,
    this.onPayTap,
    this.onTap,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
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
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(order: order),
          SizedBox(height: 12.h),
          Divider(color: AppColors.divider.withValues(alpha: 0.3), height: 1),
          SizedBox(height: 12.h),

          if (order.items.isNotEmpty) ...[
            _ItemsPreview(
              items: order.items,
              maxVisible: _maxVisibleItems,
            ),
            SizedBox(height: 12.h),
          ],

          _Footer(order: order),

          if (onPayTap != null) ...[
            SizedBox(height: 14.h),
            _PayButton(onTap: isBusy ? null : onPayTap),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final OrderData order;

  const _Header({required this.order});

  ({String label, Color background, Color foreground}) get _status {
    return switch (order.status) {
      'PENDING_PAYMENT' => (
          label: 'market.order_status_pending_payment'.tr(),
          background: const Color(0xFFFFF6E6),
          foreground: const Color(0xFFE28B00),
        ),
      'PAYMENT_FAILED' => (
          label: 'market.order_status_payment_failed'.tr(),
          background: const Color(0xFFFEECEB),
          foreground: AppColors.error,
        ),
      // Paid is not the same as delivered — the buyer is told which one it is.
      'PAID' => (
          label: 'market.order_status_paid'.tr(),
          background: const Color(0xFFEAF8EB),
          foreground: AppColors.success,
        ),
      'PROCESSING' || 'PREPARING' => (
          label: 'market.order_status_processing'.tr(),
          background: const Color(0xFFE8F3FB),
          foreground: AppColors.secondary,
        ),
      'SHIPPED' || 'OUT_FOR_DELIVERY' => (
          label: 'market.order_status_shipped'.tr(),
          background: const Color(0xFFE8F3FB),
          foreground: AppColors.secondary,
        ),
      'DELIVERED' => (
          label: 'market.order_status_delivered'.tr(),
          background: const Color(0xFFEAF8EB),
          foreground: AppColors.success,
        ),
      'COMPLETED' => (
          label: 'market.order_status_completed'.tr(),
          background: const Color(0xFFEAF8EB),
          foreground: AppColors.success,
        ),
      'CANCELLED' || 'FAILED' => (
          label: 'market.order_status_cancelled'.tr(),
          background: const Color(0xFFFEECEB),
          foreground: AppColors.error,
        ),
      _ => (
          label: 'market.order_status_pending'.tr(),
          background: const Color(0xFFF5F5F5),
          foreground: AppColors.textSecondary,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final String shortId = order.id.length > 8
        ? order.id.substring(order.id.length - 8)
        : order.id;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'market.order_id'.tr(args: [shortId]),
            style: TextStyleManager.style13Medium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: status.background,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            status.label,
            style: TextStyleManager.style9Medium.copyWith(
              color: status.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Thumbnails of what was bought.
///
/// `name` and `mainPhoto` are snapshots stored on the order at checkout, so
/// they keep showing what the buyer actually paid for even after the product
/// changed price or was deleted — never re-fetch the product to render this.
class _ItemsPreview extends StatelessWidget {
  final List<OrderItemData> items;
  final int maxVisible;

  const _ItemsPreview({required this.items, required this.maxVisible});

  @override
  Widget build(BuildContext context) {
    final visible = items.take(maxVisible).toList();
    final int hidden = items.length - visible.length;

    return Row(
      children: [
        ...visible.map(
          (item) => Padding(
            padding: EdgeInsetsDirectional.only(end: 8.w),
            child: _ItemThumb(item: item),
          ),
        ),
        if (hidden > 0)
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '+$hidden',
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            items
                .map((i) => i.name)
                .where((n) => n.isNotEmpty)
                // The comma itself is localized — Arabic uses "، ", not ", ".
                .join('market.order_items_separator'.tr()),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyleManager.style9Medium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemThumb extends StatelessWidget {
  final OrderItemData item;

  const _ItemThumb({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        width: 48.w,
        height: 48.w,
        child: AppImage(
          ApiEndpoints.resolveMediaUrl(item.mainPhoto),
          width: 48.w,
          height: 48.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final OrderData order;

  const _Footer({required this.order});

  @override
  Widget build(BuildContext context) {
    String displayDate = order.createdAt;
    if (displayDate.contains('T')) displayDate = displayDate.split('T').first;

    final int count = order.itemsCount ?? order.items.length;
    final String itemsLabel = count == 1
        ? 'market.items_count_single'.tr()
        : 'market.items_count_multi'.tr(args: [count.toString()]);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'market.order_date'.tr(args: [displayDate]),
              style: TextStyleManager.style11Medium
                  .copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 4.h),
            Text(
              itemsLabel,
              style: TextStyleManager.style11Medium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        // Currency comes from the order, never from a hardcoded symbol — the
        // backend switches markets by config.
        Text(
          formatMoney(order.total, currency: order.currency),
          style: TextStyleManager.style14Medium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _PayButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _PayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'market.complete_payment'.tr(),
          style: TextStyleManager.style13Medium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
