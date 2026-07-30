import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/utils/money_format.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/market/domain/entities/order_data.dart';

/// Everything that is inside one order: its items, then the money breakdown.
///
/// Reads the order it was handed rather than re-fetching it — `GET /orders`
/// already returns the full `items` array, and the names and photos on it are
/// checkout-time snapshots, so refetching the products would risk showing
/// something other than what was actually bought.
class OrderDetailsDialog extends StatelessWidget {
  final OrderData order;

  /// Shown only while the order still owes money. The dialog closes first, so
  /// the payment flow owns the screen.
  final VoidCallback? onPayTap;

  const OrderDetailsDialog({super.key, required this.order, this.onPayTap});

  static Future<void> show(
    BuildContext context, {
    required OrderData order,
    VoidCallback? onPayTap,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => OrderDetailsDialog(order: order, onPayTap: onPayTap),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String shortId = order.id.length > 8
        ? order.id.substring(order.id.length - 8)
        : order.id;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'market.order_id'.tr(args: [shortId]),
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionTitle('market.order_details_items'.tr()),
                  SizedBox(height: 8.h),
                  ...order.items.map(
                    (item) => _ItemRow(item: item, currency: order.currency),
                  ),
                  if (order.delivery != null) ...[
                    SizedBox(height: 16.h),
                    _DeliverySection(delivery: order.delivery!),
                  ],
                  SizedBox(height: 16.h),
                  _SectionTitle('market.order_details_summary'.tr()),
                  SizedBox(height: 8.h),
                  _SummaryRow(
                    label: 'market.order_details_subtotal'.tr(),
                    value: formatMoney(order.subtotal, currency: order.currency),
                  ),
                  if (order.discount > 0)
                    _SummaryRow(
                      label: 'market.order_details_discount'.tr(),
                      value:
                          '- ${formatMoney(order.discount, currency: order.currency)}',
                      valueColor: AppColors.error,
                    ),
                  _SummaryRow(
                    label: 'market.order_details_shipping'.tr(),
                    value: formatMoney(order.shipping, currency: order.currency),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Divider(
                      color: AppColors.divider.withValues(alpha: 0.4),
                      height: 1,
                    ),
                  ),
                  _SummaryRow(
                    label: 'market.order_details_total'.tr(),
                    value: formatMoney(order.total, currency: order.currency),
                    isEmphasised: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              children: [
                if (onPayTap != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onPayTap!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
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
                  ),
                  SizedBox(height: 10.h),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                    ),
                    child: Text(
                      'market.order_details_close'.tr(),
                      style: TextStyleManager.style13Medium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'market.order_details_title'.tr(),
            style: TextStyleManager.style15Medium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          PositionedDirectional(
            start: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, color: AppColors.primary, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyleManager.style13Medium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }
}

/// Where the order goes: the branch it is collected from, or the address it
/// ships to — never both, because the backend fills exactly one.
class _DeliverySection extends StatelessWidget {
  final OrderDeliveryData delivery;

  const _DeliverySection({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final branch = delivery.branch;
    final address = delivery.address;
    final bool isPickup = delivery.isPickup;

    // Pickup with no branch (or delivery with no address) means the backend
    // sent nothing to show — an empty card would just be noise.
    if (isPickup && branch == null) return const SizedBox.shrink();
    if (!isPickup && address == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          (isPickup
                  ? 'market.order_details_pickup_branch'
                  : 'market.order_details_delivery_address')
              .tr(),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundTint,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isPickup
                    ? Icons.storefront_rounded
                    : Icons.location_on_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: isPickup
                    ? _lines([branch!.name, branch.address, branch.phone])
                    : _lines([
                        address!.title,
                        address.parts
                            .join('market.order_items_separator'.tr()),
                      ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Renders the non-empty parts, first one emphasised as the heading.
  Widget _lines(List<String> parts) {
    final visible = parts.where((p) => p.trim().isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          if (i > 0) SizedBox(height: 4.h),
          Text(
            visible[i],
            style: i == 0
                ? TextStyleManager.style11Medium.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  )
                : TextStyleManager.style9Medium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
          ),
        ],
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItemData item;
  final String? currency;

  const _ItemRow({required this.item, this.currency});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
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
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'market.order_details_qty_price'.tr(args: [
                    item.quantity.toString(),
                    formatMoney(item.unitPrice, currency: currency),
                  ]),
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            formatMoney(item.lineTotal, currency: currency),
            style: TextStyleManager.style11Medium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isEmphasised;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isEmphasised = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isEmphasised
        ? TextStyleManager.style14Medium.copyWith(fontWeight: FontWeight.bold)
        : TextStyleManager.style11Medium;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: style.copyWith(
              color: isEmphasised ? AppColors.black : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: style.copyWith(
              color: valueColor ??
                  (isEmphasised ? AppColors.primary : AppColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
