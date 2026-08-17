import 'package:flutter/material.dart';

import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';

/// Unwinds every imperatively pushed market screen and lands on the store.
///
/// Cart, orders and the whole checkout flow are pushed with `Navigator.push`,
/// so they are *pageless* routes sitting on top of the store's router page.
/// A plain `Navigator.pop` therefore goes back one screen — which is the store
/// only when the store is what pushed it. Opening orders from the cart and
/// popping lands back on the cart, not the store.
///
/// Why not `context.go(UserAppRoutes.store)`: `go` only clears pushed screens
/// as a side effect — by replacing the page they are anchored to. When the
/// buyer is already on `/store` the resulting match list is identical, no page
/// is removed, and the pushed screens stay exactly where they were.
///
/// Popping to the nearest page-based route (`route.settings is Page`) clears
/// them directly, so it behaves the same however the store was reached, and
/// keeps the store's own state instead of rebuilding it.
void backToStore(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.settings is Page);
}

/// [backToStore] after a completed order.
void leaveCheckoutToStore(BuildContext context) {
  // The order consumed the cart and joined the unpaid list.
  getIt<CartCubit>().loadCart();
  getIt<CartCubit>().loadCounters();
  backToStore(context);
}
