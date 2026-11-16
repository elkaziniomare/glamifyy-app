import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config.dart';
import 'local_store.dart';
import 'models.dart';
import 'order_api.dart';
import 'store_api.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
});

final storeApiProvider = Provider<StoreApi>((ref) => StoreApi(ref.watch(dioProvider)));
final orderApiProvider = Provider<OrderApi>((ref) => OrderApi(ref.watch(dioProvider)));

/// Overridden in `main()` once SharedPreferences is loaded.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final localStoreProvider =
    Provider<LocalStore>((ref) => LocalStore(ref.watch(sharedPrefsProvider)));

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(storeApiProvider).categories(),
);

class SelectedCategory extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? id) => state = id;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategory, int?>(SelectedCategory.new);

final productsProvider = FutureProvider<List<Product>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  return ref.watch(storeApiProvider).products(categoryId: category);
});

final productProvider = FutureProvider.family<Product, int>(
  (ref, id) => ref.watch(storeApiProvider).product(id),
);

/// Bumped after each new order so the orders screen refreshes.
class OrdersVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final ordersVersionProvider = NotifierProvider<OrdersVersion, int>(OrdersVersion.new);

final myOrdersProvider = Provider<List<PlacedOrder>>((ref) {
  ref.watch(ordersVersionProvider);
  return ref.watch(localStoreProvider).orders;
});

/// Keyed by (order id, phone): records compare by value.
final trackingProvider = FutureProvider.family<OrderStatus, (int, String)>(
  (ref, key) => ref.watch(orderApiProvider).track(orderId: key.$1, phone: key.$2),
);
