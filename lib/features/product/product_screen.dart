import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../services/whatsapp.dart';
import '../common.dart';
import '../order/order_sheet.dart';

class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productProvider(productId));
    return Scaffold(
      appBar: AppBar(),
      body: product.when(
        data: (p) => _ProductBody(p),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorRetry(onRetry: () => ref.invalidate(productProvider(productId))),
      ),
      bottomNavigationBar: product.whenOrNull(data: (p) => _OrderBar(p)),
    );
  }
}

class _ProductBody extends StatelessWidget {
  const _ProductBody(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _Gallery(product.images),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    Money.format(product.price, minorUnit: product.minorUnit),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Brand.green,
                    ),
                  ),
                  if (product.onSale) ...[
                    const SizedBox(width: 10),
                    Text(
                      Money.format(product.regularPrice, minorUnit: product.minorUnit),
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
              if (product.shortDescription.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(product.shortDescription, style: const TextStyle(height: 1.4)),
              ],
              const SizedBox(height: 16),
              const _Reassurance(),
              if (product.descriptionHtml.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                HtmlWidget(product.descriptionHtml),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery(this.images);

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.length <= 1) {
      return AspectRatio(aspectRatio: 1, child: NetImage(images.isEmpty ? null : images.first));
    }
    return AspectRatio(
      aspectRatio: 1,
      child: PageView(children: [for (final url in images) NetImage(url)]),
    );
  }
}

class _Reassurance extends StatelessWidget {
  const _Reassurance();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Brand.sand,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          _Line(Icons.payments_outlined, 'Vous payez à la livraison, en espèces'),
          _Line(Icons.local_shipping_outlined, 'Livraison dans toutes les villes du Maroc'),
          _Line(Icons.call_outlined, 'Nous vous appelons pour confirmer la commande'),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Brand.green),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _OrderBar extends StatelessWidget {
  const _OrderBar(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Brand.whatsapp,
                ),
                onPressed: () => WhatsApp.open(
                  'Salam, je veux commander : ${product.name} '
                  '(${Money.format(product.price, minorUnit: product.minorUnit)})',
                ),
                child: const Icon(Icons.chat_outlined),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: product.canQuickOrder
                    ? () => showOrderSheet(context, product)
                    : null,
                child: Text(product.canQuickOrder ? 'Commander maintenant' : 'Indisponible'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
