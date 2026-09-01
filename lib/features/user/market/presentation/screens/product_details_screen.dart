import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/routes/deep_link_back.dart';
import 'package:fitness_day/core/services/app_share_service.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/favorite_status_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/product_details_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/product_add_to_cart_bar.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/product_details_app_bar.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/product_details_section.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/product_photo_carousel.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/product_price_label.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/product_title_quantity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';

/// Fetches full product details and presents them with a photo carousel,
/// quantity selector, and sticky add-to-cart bar.
///
/// Only [product.id] is used for the API call; [product] itself is shown as
/// a loading fallback so the screen never appears blank.
class ProductDetailsScreen extends StatelessWidget {
  final ProductData product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Reachable from an App Link (/products/:id), which opens it with no page
    // underneath — see DeepLinkPopScope.
    return DeepLinkPopScope(
      child: BlocProvider(
        create: (_) => getIt<ProductDetailsCubit>()..load(product.id),
        child: _ProductDetailsView(fallback: product),
      ),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────

class _ProductDetailsView extends StatefulWidget {
  final ProductData fallback;

  const _ProductDetailsView({required this.fallback});

  @override
  State<_ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<_ProductDetailsView> {
  /// Draft quantity used only until the product is in the cart — after that the
  /// stepper reads the server line item through [CartCubit].
  int _quantity = 1;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Reached from a share link the store tab may never have opened, so the
    // cart would read as empty and the stepper / ✓ would both be wrong.
    final cart = getIt<CartCubit>();
    if (!cart.state.hasLoadedCart) cart.loadCart();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        final bool isLoading =
            state is ProductDetailsLoading || state is ProductDetailsInitial;

        final ProductData product =
            state is ProductDetailsSuccess ? state.product : widget.fallback;

        final int selectedPhoto =
            state is ProductDetailsSuccess ? state.selectedPhotoIndex : 0;

        return Scaffold(
          backgroundColor: AppColors.dialogBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── App bar ────────────────────────────────────────────
                ProductDetailsAppBar(
                  title: 'market.product_details_title'.tr(),
                ),

                // ── Body ───────────────────────────────────────────────
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : state is ProductDetailsFailure
                          ? AppErrorView(
                              error: state.error,
                              message: state.message,
                            )
                          : _ProductBody(
                              product: product,
                              selectedPhoto: selectedPhoto,
                              quantity: _quantity,
                              pageController: _pageController,
                              onQuantityChanged: (q) =>
                                  setState(() => _quantity = q),
                            ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: ProductAddToCartBar(
            productId: product.id,
            quantity: _quantity,
          ),
        );
      },
    );
  }
}

// ─── Scrollable product body ──────────────────────────────────────────────────

class _ProductBody extends StatelessWidget {
  final ProductData product;
  final int selectedPhoto;
  final int quantity;
  final PageController pageController;
  final ValueChanged<int> onQuantityChanged;

  const _ProductBody({
    required this.product,
    required this.selectedPhoto,
    required this.quantity,
    required this.pageController,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final photos = product.photos.isNotEmpty
        ? product.photos
        : [product.imageUrl];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo carousel — the heart reads the shared favourite state so it
          // agrees with the card this screen was opened from, in both
          // directions.
          BlocBuilder<FavoriteStatusCubit, FavoriteStatusState>(
            bloc: getIt<FavoriteStatusCubit>(),
            builder: (context, status) {
              final bool isFavorite = status.isFavorite(
                product.id,
                serverValue: product.isFavorite,
              );

              return ProductPhotoCarousel(
                photos: photos,
                selectedIndex: selectedPhoto,
                pageController: pageController,
                onPageChanged: (i) =>
                    context.read<ProductDetailsCubit>().selectPhoto(i),
                isFavorite: isFavorite,
                isTogglingFavorite: status.isToggling(product.id),
                onFavoriteTap: () => getIt<FavoriteStatusCubit>().toggle(
                  itemType: CartItemType.product,
                  id: product.id,
                  current: isFavorite,
                ),
                onShareTap: () => AppShareService.shareProduct(
                  context,
                  productId: product.id,
                  productName: product.name,
                ),
              );
            },
          ),

          SizedBox(height: 16.h),

          // Title + quantity stepper
          _CartQuantitySelector(
            product: product,
            localQuantity: quantity,
            onLocalChanged: onQuantityChanged,
          ),

          SizedBox(height: 8.h),

          // Price
          ProductPriceLabel(
            price: product.currentPrice,
            oldPrice: product.oldPrice,
          ),

          SizedBox(height: 16.h),

          // Details sections from API
          if (product.details.isNotEmpty)
            ...product.details.map(
              (d) => ProductDetailsSection(title: d.title, body: d.description),
            )
          else
            ProductDetailsSection(
              title: 'market.product_description_label'.tr(),
              body: '',
            ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

// ─── Cart-bound quantity stepper ──────────────────────────────────────────────

/// Product name plus a stepper that follows the shared [CartCubit].
///
/// Before the product is in the cart the number is a local draft that the
/// add-to-cart bar sends along. Once it is in the cart the stepper mirrors the
/// server line item and every tap goes through the cubit — `PATCH /cart/items`
/// on +/-, `DELETE` when the last unit is removed — so the number here, the
/// cart screen, and the badge never disagree.
class _CartQuantitySelector extends StatelessWidget {
  final ProductData product;
  final int localQuantity;
  final ValueChanged<int> onLocalChanged;

  const _CartQuantitySelector({
    required this.product,
    required this.localQuantity,
    required this.onLocalChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cart = getIt<CartCubit>();

    return BlocBuilder<CartCubit, CartState>(
      bloc: cart,
      builder: (context, state) {
        final bool inCart = state.isInCart(product.id);
        final int quantity =
            inCart ? state.quantityOf(product.id) : localQuantity;

        return ProductTitleQuantity(
          name: product.name,
          quantity: quantity,
          busy: state.isAdding(product.id),
          onIncrement: () {
            if (inCart) {
              cart.updateQuantity(
                itemIdentity: product.id,
                quantity: quantity + 1,
              );
            } else {
              onLocalChanged(quantity + 1);
            }
          },
          onDecrement: () {
            if (!inCart) {
              // Nothing to remove yet — 1 is the floor for the draft quantity.
              if (quantity > 1) onLocalChanged(quantity - 1);
            } else if (quantity > 1) {
              cart.updateQuantity(
                itemIdentity: product.id,
                quantity: quantity - 1,
              );
            } else {
              cart.removeItem(itemIdentity: product.id);
            }
          },
        );
      },
    );
  }
}
