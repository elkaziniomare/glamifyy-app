import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money.dart';
import '../../core/phone.dart';
import '../../core/theme.dart';
import '../../data/cities.dart';
import '../../data/models.dart';
import '../../data/order_api.dart';
import '../../data/providers.dart';

Future<void> showOrderSheet(BuildContext context, Product product) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Brand.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => OrderSheet(product: product),
  );
}

/// One-step COD order: name, phone, city, address — like the website quick form.
class OrderSheet extends ConsumerStatefulWidget {
  const OrderSheet({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends ConsumerState<OrderSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  String? _city;
  int _quantity = 1;
  bool _sending = false;
  bool _submitted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(localStoreProvider).customer;
    _name = TextEditingController(text: saved?.name ?? '');
    _phone = TextEditingController(text: saved?.phone ?? '');
    _address = TextEditingController(text: saved?.address ?? '');
    _city = cities.any((c) => c.code == saved?.cityCode) ? saved!.cityCode : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _submitted = true;
    });
    if (!_form.currentState!.validate()) return;
    setState(() => _sending = true);

    final customer = Customer(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      cityCode: _city!,
      address: _address.text.trim(),
    );
    try {
      final orderId = await ref.read(orderApiProvider).placeQuickOrder(
            productId: widget.product.id,
            quantity: _quantity,
            customer: customer,
          );
      final store = ref.read(localStoreProvider);
      await store.saveCustomer(customer);
      await store.addOrder(
        PlacedOrder(
          id: orderId,
          productName: widget.product.name,
          quantity: _quantity,
          phone: MoroccanPhone.normalize(customer.phone),
          createdAt: DateTime.now(),
        ),
      );
      ref.read(ordersVersionProvider.notifier).bump();
      if (!mounted) return;
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      router.go('/success/$orderId');
    } on OrderException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final total = Money.format(p.price * _quantity, minorUnit: p.minorUnit);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Form(
          key: _form,
          autovalidateMode:
              _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Commandez en 30 secondes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (v) => (v ?? '').trim().length < 2 ? 'Merci d’indiquer votre nom.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  hintText: '06 12 34 56 78',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                validator: (v) => MoroccanPhone.isValid(v ?? '')
                    ? null
                    : 'Numéro invalide. Exemple : 06 12 34 56 78',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _city,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Ville'),
                items: [
                  for (final c in cities)
                    DropdownMenuItem(value: c.code, child: Text(c.label)),
                ],
                onChanged: (v) => setState(() => _city = v),
                validator: (v) => v == null ? 'Merci de choisir votre ville.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Adresse (quartier, rue, n°)'),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.fullStreetAddress],
                validator: (v) =>
                    (v ?? '').trim().length < 3 ? 'Merci d’indiquer votre adresse.' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Quantité', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton.outlined(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  IconButton.outlined(
                    onPressed: _quantity < 20 ? () => setState(() => _quantity++) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total produits : $total + livraison selon la ville',
                style: const TextStyle(color: Colors.black54),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('Valider ma commande'),
              ),
              const SizedBox(height: 8),
              const Text(
                '💵 Paiement à la livraison · 📞 Nous vous appelons pour confirmer',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
