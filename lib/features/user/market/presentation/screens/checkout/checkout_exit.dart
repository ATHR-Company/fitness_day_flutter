import 'package:flutter/material.dart';

import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';

/// Unwinds the whole checkout stack and lands back on the screen it started
/// from (the store).
///
/// Why not `context.go(UserAppRoutes.store)`: every checkout screen is pushed
/// with `Navigator.push`, so they are *pageless* routes sitting on top of the
/// store's router page. `go` only clears them as a side effect — by replacing
/// that page, which drops the pageless routes anchored to it. The moment the
/// buyer is already on `/store`, the resulting match list is identical, no page
/// is removed, and the pushed screens stay exactly where they were. That is why
/// leaving worked the first time and back looked dead on the second order.
///
/// Popping to the nearest page-based route (`route.settings is Page`) clears
/// the pushed screens directly, so it behaves the same however the store was
/// reached, and keeps the store's own state instead of rebuilding it.
void leaveCheckoutToStore(BuildContext context) {
  // The order consumed the cart and joined the unpaid list.
  getIt<CartCubit>().loadCart();
  getIt<CartCubit>().loadCounters();
  Navigator.of(context).popUntil((route) => route.settings is Page);
}
