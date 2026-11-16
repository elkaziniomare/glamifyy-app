import 'package:dio/dio.dart';

import 'models.dart';

/// Read-only catalogue from the public WooCommerce Store API.
/// No secret keys are shipped in the app: the Store API is public by design.
class StoreApi {
  StoreApi(this._dio);

  final Dio _dio;

  static const _base = '/wp-json/wc/store/v1';

  Future<List<Category>> categories() async {
    final res = await _dio.get<List<dynamic>>('$_base/products/categories');
    return (res.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Category.fromStoreJson)
        .where((c) => c.count > 0)
        .toList();
  }

  Future<List<Product>> products({int? categoryId, String? search}) async {
    final res = await _dio.get<List<dynamic>>(
      '$_base/products',
      queryParameters: {
        'per_page': 50,
        'category': ?categoryId,
        'search': ?_nonEmpty(search),
      },
    );
    return (res.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Product.fromStoreJson)
        .toList();
  }

  static String? _nonEmpty(String? s) => (s == null || s.isEmpty) ? null : s;

  Future<Product> product(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/products/$id');
    return Product.fromStoreJson(res.data!);
  }
}
