import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../services/whatsapp.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Brand.green,
                child: Icon(Icons.check_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Merci, commande reçue !',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text('Commande n° $orderId', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              const Text(
                'Nous vous appelons très bientôt pour confirmer.\n'
                'Vous payez à la livraison.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.4),
              ),
              const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Brand.whatsapp),
                onPressed: () => WhatsApp.open(
                  'Salam, je confirme ma commande n° $orderId 🙂',
                ),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Confirmer sur WhatsApp'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.go('/orders/$orderId'),
                child: const Text('Suivre ma commande'),
              ),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Retour à la boutique'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
