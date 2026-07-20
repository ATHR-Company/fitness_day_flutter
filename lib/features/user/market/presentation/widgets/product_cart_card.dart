import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_package_card.dart';

/// A product card whose bottom button adds to cart against the shared
/// [CartCubit]. The button reflects live cart state — ✓ "added" when the item
/// is already in the cart, a spinner while the add request is in flight — so
/// the marker stays consistent across every store screen.
class ProductCartCard extends StatelessWidget {
  final SubscriptionPackageData package;
  final String? badge;
  final String detailsLabelKey;
  final CartItemType itemType;

  /// Tapping the card body (not the button) — typically opens details.
  final VoidCallback? onTap;

  const ProductCartCard({
    super.key,
    required this.package,
    required this.itemType,
    this.badge,
    this.detailsLabelKey = 'market.add_to_cart',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cart = getIt<CartCubit>();
    return BlocBuilder<CartCubit, CartState>(
      bloc: cart,
      builder: (context, state) {
        return SubscriptionPackageCard(
          package: package,
          badge: badge,
          detailsLabelKey: detailsLabelKey,
          onTap: onTap,
          isInCart: state.isInCart(package.id),
          isAdding: state.isAdding(package.id),
          onAddToCart: () => _add(context, cart),
        );
      },
    );
  }

  Future<void> _add(BuildContext context, CartCubit cart) async {
    final ok = await cart.addToCart(
      itemType: itemType,
      itemIdentity: package.id,
    );
    if (!ok && context.mounted) {
      final msg = cart.state.errorMessage;
      if (msg != null && msg.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }
  }
}
