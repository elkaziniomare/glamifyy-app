import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../services/whatsapp.dart';
import '../common.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Glamifyy',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Brand.green),
        ),
        actions: [
          IconButton(
            tooltip: 'Mes commandes',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => context.go('/orders'),
          ),
          IconButton(
            tooltip: 'WhatsApp',
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => WhatsApp.open('Salam Glamifyy, j’ai une question 🙂'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(productsProvider);
          await ref.read(productsProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Hero()),
            const SliverToBoxAdapter(child: _CategoryChips()),
            products.when(
              data: (list) => list.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('Aucun produit dans cette catégorie.')),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverGrid.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.66,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, i) => _ProductCard(list[i]),
                      ),
                    ),
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorRetry(onRetry: () => ref.invalidate(productsProvider)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Brand.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soins naturels au chébé, karité et plantes',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10),
          _Perk(icon: Icons.payments_outlined, text: 'Paiement à la livraison'),
          _Perk(icon: Icons.local_shipping_outlined, text: 'Livraison partout au Maroc'),
          _Perk(icon: Icons.call_outlined, text: 'On vous appelle pour confirmer'),
        ],
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Brand.gold),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final selected = ref.watch(selectedCategoryProvider);
    final notifier = ref.read(selectedCategoryProvider.notifier);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip('Tout', selected == null, () => notifier.select(null)),
          for (final c in categories)
            _chip(c.name, selected == c.id, () => notifier.select(c.id)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: active,
          onSelected: (_) => onTap(),
          selectedColor: Brand.green,
          labelStyle: TextStyle(color: active ? Colors.white : Brand.ink),
          showCheckmark: false,
        ),
      );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/product/${product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1, child: NetImage(product.mainImage)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, height: 1.25),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                Money.format(product.price, minorUnit: product.minorUnit),
                style: const TextStyle(
                  color: Brand.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
