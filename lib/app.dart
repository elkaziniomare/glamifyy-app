import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/theme.dart';
import 'features/catalog/home_screen.dart';
import 'features/order/order_success_screen.dart';
import 'features/orders/orders_screen.dart';
import 'features/orders/tracking_screen.dart';
import 'features/product/product_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'product/:id',
          builder: (context, state) =>
              ProductScreen(productId: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: 'success/:orderId',
          builder: (context, state) => OrderSuccessScreen(
            orderId: int.parse(state.pathParameters['orderId']!),
          ),
        ),
        GoRoute(
          path: 'orders',
          builder: (context, state) => const OrdersScreen(),
          routes: [
            GoRoute(
              path: ':orderId',
              builder: (context, state) => TrackingScreen(
                orderId: int.parse(state.pathParameters['orderId']!),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

class GlamifyyApp extends StatelessWidget {
  const GlamifyyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Glamifyy',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: router,
    );
  }
}
