import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);
    final date = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: orders.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Vous n’avez pas encore commandé depuis l’application.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final o = orders[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: const CircleAvatar(
                      backgroundColor: Brand.sand,
                      child: Icon(Icons.inventory_2_outlined, color: Brand.green),
                    ),
                    title: Text('Commande n° ${o.id}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${o.quantity} × ${o.productName}\n${date.format(o.createdAt)}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/orders/${o.id}'),
                  ),
                );
              },
            ),
    );
  }
}
