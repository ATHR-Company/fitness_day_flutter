/// Badge counts from `GET /orders/counters`.
///
/// Cheap enough to refresh on every app open — it exists so the badges don't
/// need a full cart or orders fetch.
class OrderCountersData {
  /// Sum of quantities in the cart — the same number as `summary.totalItems`
  /// from `GET /cart`, and what the cart badge should show.
  final int cartItemsCount;

  /// Distinct products/plans in the cart.
  final int cartLinesCount;

  /// Orders created but never paid.
  final int pendingPaymentOrdersCount;

  const OrderCountersData({
    this.cartItemsCount = 0,
    this.cartLinesCount = 0,
    this.pendingPaymentOrdersCount = 0,
  });

  bool get hasUnpaidOrders => pendingPaymentOrdersCount > 0;
}
