import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/order_api.dart';
import '../../data/providers.dart';
import '../../services/whatsapp.dart';

/// WooCommerce / Maroc Checkout statuses, in delivery order.
const _steps = <(String, IconData)>[
  ('À confirmer', Icons.hourglass_top_rounded),
  ('Confirmée', Icons.thumb_up_alt_outlined),
  ('En livraison', Icons.local_shipping_outlined),
  ('Livrée', Icons.home_outlined),
];

/// Maps WooCommerce + Maroc Checkout Pro statuses (MCWCP_Statuses) to a step.
/// Returns -1 for orders that are no longer active (refused, cancelled…).
int stepIndexFor(String status) {
  switch (status) {
    case 'mcwc-to-confirm':
    case 'mcwc-no-answer':
    case 'pending':
    case 'on-hold':
      return 0;
    case 'mcwc-confirmed':
      return 1;
    case 'processing':
      return 2;
    case 'completed':
      return 3;
    default:
      return -1;
  }
}

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref
        .watch(myOrdersProvider)
        .where((o) => o.id == orderId)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text('Commande n° $orderId')),
      body: order == null
          ? const Center(child: Text('Commande introuvable sur ce téléphone.'))
          : _Tracking(order),
    );
  }
}

class _Tracking extends ConsumerWidget {
  const _Tracking(this.order);

  final PlacedOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (order.id, order.phone);
    final status = ref.watch(trackingProvider(key));
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(trackingProvider(key));
        try {
          await ref.read(trackingProvider(key).future);
        } catch (_) {
          // The error state is rendered below.
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${order.quantity} × ${order.productName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          status.when(
            data: (s) => _StatusCard(s),
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => _Fallback(order: order, unavailable: e is TrackingUnavailable),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard(this.status);

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final current = stepIndexFor(status.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status.label,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Brand.green)),
            const SizedBox(height: 4),
            Text('Total : ${Money.format(status.total, minorUnit: status.minorUnit)}'),
            const SizedBox(height: 16),
            if (current < 0)
              const Text('Cette commande n’est plus active. Contactez-nous sur WhatsApp si besoin.')
            else
              for (var i = 0; i < _steps.length; i++)
                _StepRow(
                  icon: _steps[i].$2,
                  label: _steps[i].$1,
                  done: i <= current,
                  isLast: i == _steps.length - 1,
                ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.label,
    required this.done,
    required this.isLast,
  });

  final IconData icon;
  final String label;
  final bool done;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = done ? Brand.green : Colors.black26;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: done ? Brand.green : Brand.sand,
              child: Icon(icon, size: 18, color: done ? Colors.white : Colors.black38),
            ),
            if (!isLast) Container(width: 2, height: 22, color: color),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(label,
              style: TextStyle(
                fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                color: done ? Brand.ink : Colors.black45,
              )),
        ),
      ],
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.order, required this.unavailable});

  final PlacedOrder order;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              unavailable
                  ? 'Le suivi en ligne n’est pas encore disponible pour cette commande.'
                  : 'Impossible de récupérer le statut. Vérifiez votre connexion.',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Brand.whatsapp),
              onPressed: () => WhatsApp.open(
                'Salam, où en est ma commande n° ${order.id} ?',
              ),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Demander sur WhatsApp'),
            ),
          ],
        ),
      ),
    );
  }
}
