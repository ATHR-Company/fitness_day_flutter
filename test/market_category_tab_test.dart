import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/order_counters_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/plans_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/store_home_data.dart';
import 'package:fitness_day/features/user/market/domain/repositories/market_repository.dart';
import 'package:fitness_day/features/user/market/domain/repositories/cart_repository.dart';
import 'package:fitness_day/features/user/market/domain/repositories/checkout_repository.dart';
import 'package:fitness_day/features/user/market/domain/usecases/add_to_cart_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_cart_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_order_counters_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_plans_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_store_home_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/remove_cart_item_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/market_home_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/plans_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/market_main_screen.dart';

class _FakeMarketRepo implements MarketRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeCartRepo implements CartRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeCheckoutRepo implements CheckoutRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

int storeHomeCalls = 0;

class _FakeStoreHome extends GetStoreHomeUseCase {
  _FakeStoreHome() : super(_FakeMarketRepo());
  @override
  Future<ApiResult<StoreHomeData>> call() async {
    storeHomeCalls++;
    return Success(const StoreHomeData(
      headerBanners: [],
      middleBanners: [],
      categories: [
        CategoryItem(id: 'c1', name: 'Supplements'),
        CategoryItem(id: 'c2', name: 'Gear'),
        CategoryItem(id: 'c3', name: 'Clothing'),
        CategoryItem(id: 'c4', name: 'Equipment'),
        CategoryItem(id: 'c5', name: 'Vitamins'),
        CategoryItem(id: 'c6', name: 'Protein'),
        CategoryItem(id: 'c7', name: 'Accessories'),
      ],
      bestOffers: [],
      newProducts: [],
      bestSellers: [],
    ));
  }
}

class _FakePlans extends GetPlansUseCase {
  _FakePlans() : super(_FakeMarketRepo());
  @override
  Future<ApiResult<PlansData>> call({int page = 1, int limit = 8}) async =>
      Success(const PlansData(plans: [], total: 0, page: 1, limit: 8));
}

class _FakeGetCart extends GetCartUseCase {
  _FakeGetCart() : super(_FakeCartRepo());
  @override
  Future<ApiResult<CartData>> call() => Completer<ApiResult<CartData>>().future;
}

class _FakeCounters extends GetOrderCountersUseCase {
  _FakeCounters() : super(_FakeCheckoutRepo());
  @override
  Future<ApiResult<OrderCountersData>> call() =>
      Completer<ApiResult<OrderCountersData>>().future;
}

class _FakeCache implements AppCache {
  @override
  bool getIsSubscribed() => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  setUp(() {
    storeHomeCalls = 0;
    final gi = GetIt.instance;
    gi.reset();
    gi.registerFactory<MarketHomeCubit>(() => MarketHomeCubit(_FakeStoreHome()));
    gi.registerFactory<PlansCubit>(() => PlansCubit(_FakePlans()));
    gi.registerLazySingleton<AppCache>(() => _FakeCache());
    gi.registerLazySingleton<CartCubit>(() => CartCubit(
          getCartUseCase: _FakeGetCart(),
          addToCartUseCase: AddToCartUseCase(_FakeCartRepo()),
          updateQuantityUseCase: UpdateCartQuantityUseCase(_FakeCartRepo()),
          removeItemUseCase: RemoveCartItemUseCase(_FakeCartRepo()),
          getCountersUseCase: _FakeCounters(),
        ));
  });

  testWidgets('categories row keeps the selected pill visible after tab switch',
      (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => const MaterialApp(home: MarketMainScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final rowFinder = find.byType(SingleChildScrollView).first;
    double rowOffset() => tester
        .state<ScrollableState>(
          find
              .descendant(of: rowFinder, matching: find.byType(Scrollable))
              .first,
        )
        .position
        .pixels;

    // Scroll to the far end of the categories row and pick the last category.
    await tester.scrollUntilVisible(
      find.text('Accessories'),
      200,
      scrollable:
          find.descendant(of: rowFinder, matching: find.byType(Scrollable)).first,
    );
    await tester.pumpAndSettle();
    final offsetBefore = rowOffset();
    expect(offsetBefore, greaterThan(0),
        reason: 'the last category must sit off the initial viewport');

    await tester.tap(find.text('Accessories'));
    await tester.pumpAndSettle();
    expect(find.text('market.empty_category_title'), findsOneWidget,
        reason: 'tapping a pill filters the grid to that category');

    // Switch to Packages and back.
    await tester.tap(find.text('market.tab_packages'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('market.tab_products'));
    await tester.pumpAndSettle();

    // The store is not refetched, so the cubit still holds the selection.
    expect(storeHomeCalls, 1);
    expect(find.text('market.empty_category_title'), findsOneWidget);

    // ...and the row still shows the selected pill rather than snapping back
    // to "All" at offset 0.
    expect(rowOffset(), offsetBefore);
    final pillRect = tester.getRect(find.text('Accessories'));
    final screenWidth = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(pillRect.left, greaterThanOrEqualTo(0.0));
    expect(pillRect.right, lessThanOrEqualTo(screenWidth));
  });
}
