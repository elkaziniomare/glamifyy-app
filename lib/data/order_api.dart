import 'package:dio/dio.dart';

import 'models.dart';

class OrderException implements Exception {
  const OrderException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Thrown when the store does not expose order tracking yet
/// (Maroc Checkout Pro < 0.6.0) or the order/phone pair is unknown.
class TrackingUnavailable implements Exception {
  const TrackingUnavailable();
}

/// Places COD orders through the Maroc Checkout Pro quick-form endpoint,
/// so app orders get the same validation, shipping rate, risk check and
/// "to confirm" status as orders from the website.
class OrderApi {
  OrderApi(this._dio);

  final Dio _dio;

  static const _genericError =
      'Une erreur est survenue. Réessayez ou contactez-nous sur WhatsApp.';

  Future<int> placeQuickOrder({
    required int productId,
    required int quantity,
    required Customer customer,
  }) async {
    final Response<dynamic> res;
    try {
      res = await _dio.post<dynamic>(
        '/wp-admin/admin-ajax.php',
        data: {
          'action': 'mcwcp_quick_order',
          'product_id': productId,
          'quantity': quantity,
          'name': customer.name,
          'phone': customer.phone,
          'city': customer.cityCode,
          'address': customer.address,
          'website': '', // honeypot, must stay empty
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
    } on DioException {
      throw const OrderException(_genericError);
    }
    return parseQuickOrderResponse(res.data);
  }

  /// Parses `{"success":true,"data":{"redirect":".../order-received/123/?key=..."}}`.
  static int parseQuickOrderResponse(dynamic body) {
    if (body is! Map) throw const OrderException(_genericError);
    final data = body['data'];
    if (body['success'] != true) {
      final message = data is Map ? data['message'] as String? : null;
      throw OrderException(message ?? _genericError);
    }
    final redirect = data is Map ? '${data['redirect'] ?? ''}' : '';
    final match = RegExp(r'order-received[/=](\d+)').firstMatch(redirect);
    if (match == null) throw const OrderException(_genericError);
    return int.parse(match.group(1)!);
  }

  /// Requires the `mcwcp/v1/track` endpoint (Maroc Checkout Pro 0.6.0+).
  Future<OrderStatus> track({required int orderId, required String phone}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/wp-json/mcwcp/v1/track',
        queryParameters: {'order': orderId, 'phone': phone},
      );
      return OrderStatus.fromJson(res.data!);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 403) throw const TrackingUnavailable();
      rethrow;
    }
  }
}
