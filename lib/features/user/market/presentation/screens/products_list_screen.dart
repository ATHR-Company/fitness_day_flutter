import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_package_card.dart';
import 'package:fitness_day/features/user/market/presentation/screens/product_details_screen.dart';
import 'package:flutter_svg/svg.dart';

class ProductsListScreen extends StatefulWidget {
  final String title;
  final List<ProductData> products;
  final bool isGrid;

  const ProductsListScreen({
    super.key,
    required this.title,
    required this.products,
    this.isGrid = true,
  });

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  late List<ProductData> _products;

  @override
  void initState() {
    super.initState();
    _products = widget.products.map((product) => product).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: widget.isGrid
                    ? GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 0.58, // Adjust based on card height
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final package = SubscriptionPackageData(
                            imageUrl: product.imageUrl,
                            name: product.name,
                            currentPrice: product.currentPrice.toInt(),
                            oldPrice: product.oldPrice?.toInt() ?? 0,
                            isFavorite: product.isFavorite,
                          );
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(product: product),
                                ),
                              );
                            },
                            child: SubscriptionPackageCard(
                              package: package,
                              detailsLabelKey: 'home.add_to_cart',
                              onFavoriteTap: () {
                                setState(() {
                                  _products[index] = ProductData(
                                    id: product.id,
                                    name: product.name,
                                    imageUrl: product.imageUrl,
                                    currentPrice: product.currentPrice,
                                    oldPrice: product.oldPrice,
                                    isFavorite: !product.isFavorite,
                                    discountTag: product.discountTag,
                                    offerTag: product.offerTag,
                                  );
                                });
                              },
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final package = SubscriptionPackageData(
                            imageUrl: product.imageUrl,
                            name: product.name,
                            currentPrice: product.currentPrice.toInt(),
                            oldPrice: product.oldPrice?.toInt() ?? 0,
                            isFavorite: product.isFavorite,
                          );
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(product: product),
                                  ),
                                );
                              },
                              child: SubscriptionPackageCard(
                                package: package,
                                detailsLabelKey: 'home.add_to_cart',
                                onFavoriteTap: () {
                                  setState(() {
                                    _products[index] = ProductData(
                                      id: product.id,
                                      name: product.name,
                                      imageUrl: product.imageUrl,
                                      currentPrice: product.currentPrice,
                                      oldPrice: product.oldPrice,
                                      isFavorite: !product.isFavorite,
                                      discountTag: product.discountTag,
                                      offerTag: product.offerTag,
                                    );
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
            
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.black,
              size: 20.sp,
            ),
          ),
        
          const Spacer(),
          
          Text(
            widget.title,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          
          const Spacer(),
          // Cart Icon
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44.w,
              height: 44.w,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: SvgPicture.asset(
                SvgIcons.market_icon,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
      
        ],
      ),
    );
  }
}
