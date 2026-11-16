import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Small on-device storage: last customer details and orders placed from this phone.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const _customerKey = 'customer';
  static const _ordersKey = 'orders';

  Customer? get customer {
    final raw = _prefs.getString(_customerKey);
    if (raw == null) return null;
    return Customer.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveCustomer(Customer customer) =>
      _prefs.setString(_customerKey, jsonEncode(customer.toJson()));

  List<PlacedOrder> get orders {
    final raw = _prefs.getStringList(_ordersKey) ?? const [];
    final list = raw
        .map((e) => PlacedOrder.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> addOrder(PlacedOrder order) {
    final raw = _prefs.getStringList(_ordersKey) ?? <String>[];
    return _prefs.setStringList(_ordersKey, [...raw, jsonEncode(order.toJson())]);
  }
}
