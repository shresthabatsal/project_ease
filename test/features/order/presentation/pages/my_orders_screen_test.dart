import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/my_orders_screen.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/presentation/state/order_state.dart';
import 'package:project_ease/features/order/presentation/view_model/order_view_model.dart';

class FakeOrderNotifier extends OrderViewModel {
  final OrderState _fixedState;
  FakeOrderNotifier(this._fixedState);

  @override
  OrderState build() => _fixedState;

  @override
  Future<void> loadOrders() async {}

  @override
  Future<bool> cancelOrder(String orderId, String? reason) async => false;
}

OrderEntity _order({
  String id = 'o1',
  String status = 'PENDING',
  String? storeName = 'Main Store',
}) => OrderEntity(
  orderId: id,
  storeId: 's1',
  storeName: storeName,
  items: const [],
  totalAmount: 250.0,
  pickupDate: DateTime(2025, 12, 1),
  pickupTime: '10:00 AM',
  paymentStatus: 'PENDING',
  status: status,
  orderDate: DateTime(2025, 11, 30),
);

Widget _buildMyOrders(OrderState state, {String? initialFilter}) {
  return ProviderScope(
    overrides: [
      orderViewModelProvider.overrideWith(() => FakeOrderNotifier(state)),
    ],
    child: MaterialApp(home: MyOrdersScreen(initialFilter: initialFilter)),
  );
}

void main() {
  group('MyOrdersScreen Widget Tests', () {
    testWidgets('shows AppBar with "My Orders" title', (tester) async {
      await tester.pumpWidget(
        _buildMyOrders(const OrderState(status: OrderStatus.success)),
      );
      await tester.pumpAndSettle();
      expect(find.text('My Orders'), findsOneWidget);
    });

    testWidgets('shows loading indicator when status is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildMyOrders(const OrderState(status: OrderStatus.loading)),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state message when orders list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildMyOrders(
          const OrderState(status: OrderStatus.success, orders: []),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No orders yet.'), findsOneWidget);
    });

    testWidgets('shows all filter chips', (tester) async {
      await tester.pumpWidget(
        _buildMyOrders(const OrderState(status: OrderStatus.success)),
      );
      await tester.pumpAndSettle();
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Collected'), findsOneWidget);
    });

    testWidgets('shows order short ID on card', (tester) async {
      await tester.pumpWidget(
        _buildMyOrders(
          OrderState(
            status: OrderStatus.success,
            orders: [_order(id: 'o1')],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('#O1'), findsOneWidget);
    });

    testWidgets('shows status label "Pending" on PENDING order card', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildMyOrders(
          OrderState(
            status: OrderStatus.success,
            orders: [_order(status: 'PENDING')],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Pending'),
        findsWidgets,
      );
    });

    testWidgets('shows error message when status is error', (tester) async {
      await tester.pumpWidget(
        _buildMyOrders(
          const OrderState(
            status: OrderStatus.error,
            errorMessage: 'Failed to load orders.',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Failed to load orders.'), findsOneWidget);
    });

    testWidgets(
      'pre-selects filter: no matching orders shows filtered empty state',
      (tester) async {
        await tester.pumpWidget(
          _buildMyOrders(
            OrderState(
              status: OrderStatus.success,
              orders: [_order(status: 'PENDING')],
            ),
            initialFilter: 'CANCELLED',
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('No orders with this status.'), findsOneWidget);
      },
    );

    testWidgets('shows two orders with different status labels', (
      tester,
    ) async {
      final orders = [
        _order(id: 'o1', status: 'PENDING'),
        _order(id: 'o2', status: 'CONFIRMED'),
      ];
      await tester.pumpWidget(
        _buildMyOrders(OrderState(status: OrderStatus.success, orders: orders)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Confirmed'), findsWidgets);
    });

    testWidgets(
      'tapping Cancelled filter chip filters out non-cancelled orders',
      (tester) async {
        final orders = [
          _order(id: 'o1', status: 'PENDING'),
          _order(id: 'o2', status: 'CANCELLED'),
        ];
        await tester.pumpWidget(
          _buildMyOrders(
            OrderState(status: OrderStatus.success, orders: orders),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancelled').first);
        await tester.pumpAndSettle();

        expect(find.text('#O1'), findsNothing);
        expect(
          find.text('#O2'),
          findsOneWidget,
        );
      },
    );
  });
}
