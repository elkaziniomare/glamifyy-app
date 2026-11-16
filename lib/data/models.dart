import '../core/text.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.descriptionHtml,
    required this.price,
    required this.regularPrice,
    required this.minorUnit,
    required this.images,
    required this.categoryIds,
    required this.isInStock,
    required this.isPurchasable,
    required this.isSimple,
    required this.permalink,
  });

  final int id;
  final String name;
  final String shortDescription;
  final String descriptionHtml;

  /// Amounts in minor units (centimes).
  final int price;
  final int regularPrice;
  final int minorUnit;
  final List<String> images;
  final List<int> categoryIds;
  final bool isInStock;
  final bool isPurchasable;
  final bool isSimple;
  final String permalink;

  bool get onSale => price < regularPrice;

  /// The quick COD form only supports simple, purchasable, in-stock products.
  bool get canQuickOrder => isSimple && isPurchasable && isInStock;

  String? get mainImage => images.isEmpty ? null : images.first;

  factory Product.fromStoreJson(Map<String, dynamic> json) {
    final prices = (json['prices'] as Map?)?.cast<String, dynamic>() ?? const {};
    final images = (json['images'] as List? ?? const [])
        .whereType<Map>()
        .map((i) => i['src'] as String? ?? '')
        .where((src) => src.isNotEmpty)
        .toList();
    final categories = (json['categories'] as List? ?? const [])
        .whereType<Map>()
        .map((c) => (c['id'] as num).toInt())
        .toList();
    final price = int.tryParse('${prices['price'] ?? 0}') ?? 0;
    return Product(
      id: (json['id'] as num).toInt(),
      name: TextUtils.decodeEntities(json['name'] as String? ?? ''),
      shortDescription: TextUtils.plain(json['short_description'] as String? ?? ''),
      descriptionHtml: json['description'] as String? ?? '',
      price: price,
      regularPrice: int.tryParse('${prices['regular_price'] ?? price}') ?? price,
      minorUnit: (prices['currency_minor_unit'] as num?)?.toInt() ?? 2,
      images: images,
      categoryIds: categories,
      isInStock: json['is_in_stock'] as bool? ?? true,
      isPurchasable: json['is_purchasable'] as bool? ?? true,
      isSimple: (json['type'] as String? ?? 'simple') == 'simple',
      permalink: json['permalink'] as String? ?? '',
    );
  }
}

class Category {
  const Category({required this.id, required this.name, required this.count});

  final int id;
  final String name;
  final int count;

  factory Category.fromStoreJson(Map<String, dynamic> json) => Category(
        id: (json['id'] as num).toInt(),
        name: TextUtils.decodeEntities(json['name'] as String? ?? ''),
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}

/// Customer details remembered between orders.
class Customer {
  const Customer({
    required this.name,
    required this.phone,
    required this.cityCode,
    required this.address,
  });

  final String name;
  final String phone;
  final String cityCode;
  final String address;

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'city': cityCode,
        'address': address,
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        cityCode: json['city'] as String? ?? '',
        address: json['address'] as String? ?? '',
      );
}

/// An order placed from this phone, kept locally for tracking.
class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.phone,
    required this.createdAt,
  });

  final int id;
  final String productName;
  final int quantity;
  final String phone;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'product': productName,
        'qty': quantity,
        'phone': phone,
        'at': createdAt.toIso8601String(),
      };

  factory PlacedOrder.fromJson(Map<String, dynamic> json) => PlacedOrder(
        id: (json['id'] as num).toInt(),
        productName: json['product'] as String? ?? '',
        quantity: (json['qty'] as num?)?.toInt() ?? 1,
        phone: json['phone'] as String? ?? '',
        createdAt: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Order status returned by the Maroc Checkout Pro tracking endpoint.
class OrderStatus {
  const OrderStatus({
    required this.id,
    required this.status,
    required this.label,
    required this.total,
    required this.minorUnit,
    required this.items,
    this.createdAt,
  });

  final int id;
  final String status;
  final String label;
  final int total;
  final int minorUnit;
  final List<String> items;
  final DateTime? createdAt;

  factory OrderStatus.fromJson(Map<String, dynamic> json) => OrderStatus(
        id: (json['id'] as num).toInt(),
        status: json['status'] as String? ?? '',
        label: TextUtils.decodeEntities(json['status_label'] as String? ?? ''),
        total: int.tryParse('${json['total'] ?? 0}') ?? 0,
        minorUnit: (json['minor_unit'] as num?)?.toInt() ?? 2,
        items: (json['items'] as List? ?? const [])
            .whereType<Map>()
            .map((i) => '${i['qty']} × ${TextUtils.decodeEntities('${i['name']}')}')
            .toList(),
        createdAt: DateTime.tryParse(json['date'] as String? ?? ''),
      );
}
