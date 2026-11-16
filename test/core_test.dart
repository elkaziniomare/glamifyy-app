import 'package:flutter_test/flutter_test.dart';
import 'package:glamifyy_app/core/money.dart';
import 'package:glamifyy_app/core/phone.dart';
import 'package:glamifyy_app/core/text.dart';
import 'package:glamifyy_app/data/cities.dart';
import 'package:glamifyy_app/data/models.dart';
import 'package:glamifyy_app/data/order_api.dart';
import 'package:glamifyy_app/features/orders/tracking_screen.dart';

void main() {
  group('MoroccanPhone (mirrors MCWC_Phone)', () {
    test('accepts local and international formats', () {
      for (final raw in ['0612345678', '06 12 34 56 78', '+212612345678', '00212712345678', '212512345678']) {
        expect(MoroccanPhone.isValid(raw), isTrue, reason: raw);
      }
    });

    test('rejects invalid numbers', () {
      for (final raw in ['', '0812345678', '061234567', '+33612345678', 'abc']) {
        expect(MoroccanPhone.isValid(raw), isFalse, reason: raw);
      }
    });

    test('normalizes to +212', () {
      expect(MoroccanPhone.normalize('06 12-34-56-78'), '+212612345678');
    });
  });

  group('Money', () {
    test('formats whole and fractional dirhams', () {
      expect(Money.format(4500), '45 DH');
      expect(Money.format(36900), '369 DH');
      expect(Money.format(4550), '45,50 DH');
      expect(Money.format(150000), '1 500 DH');
    });
  });

  group('TextUtils', () {
    test('decodes WordPress entities', () {
      expect(TextUtils.decodeEntities('Chébé &#038; Karité'), 'Chébé & Karité');
      expect(TextUtils.decodeEntities('Huile d&rsquo;Argan'), 'Huile d’Argan');
      expect(TextUtils.decodeEntities('Scrub &#8211; Aker'), 'Scrub – Aker');
    });

    test('strips tags', () {
      expect(TextUtils.plain('<p>Soin <b>doux</b></p>\n'), 'Soin doux');
    });
  });

  test('Product.fromStoreJson reads Store API fields', () {
    final p = Product.fromStoreJson({
      'id': 415,
      'name': 'Beurre au Chébé &#038; Karité',
      'short_description': '<p>Nourrit les cheveux.</p>',
      'description': '<p>Long</p>',
      'type': 'simple',
      'is_in_stock': true,
      'is_purchasable': true,
      'permalink': 'https://glamifyy.shop/produit/x/',
      'prices': {'price': '4500', 'regular_price': '5000', 'currency_minor_unit': 2},
      'images': [
        {'src': 'https://glamifyy.shop/a.png'},
      ],
      'categories': [
        {'id': 16},
      ],
    });
    expect(p.name, 'Beurre au Chébé & Karité');
    expect(p.shortDescription, 'Nourrit les cheveux.');
    expect(p.price, 4500);
    expect(p.onSale, isTrue);
    expect(p.canQuickOrder, isTrue);
    expect(p.mainImage, 'https://glamifyy.shop/a.png');
  });

  group('OrderApi.parseQuickOrderResponse', () {
    test('extracts the order id from the redirect URL', () {
      final id = OrderApi.parseQuickOrderResponse({
        'success': true,
        'data': {'redirect': 'https://glamifyy.shop/commande/order-received/612/?key=wc_order_x'},
      });
      expect(id, 612);
    });

    test('supports plain permalinks', () {
      final id = OrderApi.parseQuickOrderResponse({
        'success': true,
        'data': {'redirect': 'https://glamifyy.shop/?page_id=9&order-received=77&key=k'},
      });
      expect(id, 77);
    });

    test('surfaces the server message on failure', () {
      expect(
        () => OrderApi.parseQuickOrderResponse({
          'success': false,
          'data': {'message': 'Numéro de téléphone invalide.'},
        }),
        throwsA(isA<OrderException>().having((e) => e.message, 'message', 'Numéro de téléphone invalide.')),
      );
    });
  });

  test('tracking steps follow Maroc Checkout statuses', () {
    expect(stepIndexFor('mcwc-to-confirm'), 0);
    expect(stepIndexFor('mcwc-confirmed'), 1);
    expect(stepIndexFor('processing'), 2);
    expect(stepIndexFor('completed'), 3);
    expect(stepIndexFor('mcwc-refused'), -1);
  });

  test('city list matches the plugin', () {
    expect(cities.length, 60);
    expect(cities.map((c) => c.code).toSet().length, cities.length);
    expect(cities.first.code, 'CAS');
  });
}
