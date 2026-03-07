import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';
import 'package:project_ease/features/cart/presentation/state/cart_state.dart';
import 'package:project_ease/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/cart_screen.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';
import 'package:project_ease/features/store/presentation/state/store_state.dart';
import 'package:project_ease/features/store/presentation/view_model/store_view_model.dart';

class FakeCartNotifier extends CartViewModel {
  final CartState _fixedState;
  FakeCartNotifier(this._fixedState);

  @override
  CartState build() => _fixedState;

  @override
  Future<void> loadCart() async {}

  @override
  Future<void> clear() async {}

  @override
  Future<void> removeItem(String cartItemId) async {}

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {}
}

class FakeStoreNotifier extends StoreViewModel {
  @override
  StoreState build() => const StoreState();
}

ProductEntity _product({
  String id = 'p1',
  String name = 'Milk',
  double price = 80,
}) => ProductEntity(productId: id, name: name, price: price, stock: 5);

CartItemEntity _item({String id = 'ci1', String name = 'Milk', int qty = 2}) =>
    CartItemEntity(
      cartItemId: id,
      product: _product(name: name),
      quantity: qty,
    );

Widget _buildCart(CartState state) {
  return ProviderScope(
    overrides: [
      cartViewModelProvider.overrideWith(() => FakeCartNotifier(state)),
      storeViewModelProvider.overrideWith(() => FakeStoreNotifier()),
    ],
    child: const MaterialApp(home: CartScreen()),
  );
}

void main() {
  group('CartScreen Widget Tests', () {
    testWidgets(
      'shows loading indicator when status is loading and cart is empty',
      (tester) async {
        await tester.pumpWidget(
          _buildCart(const CartState(status: CartStatus.loading)),
        );
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('shows empty cart message when cart is empty', (tester) async {
      await tester.pumpWidget(
        _buildCart(const CartState(status: CartStatus.loaded)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('shows AppBar with "My Cart" title', (tester) async {
      await tester.pumpWidget(
        _buildCart(const CartState(status: CartStatus.loaded)),
      );
      await tester.pumpAndSettle();
      expect(find.text('My Cart'), findsOneWidget);
    });

    testWidgets('shows Clear button when cart has items', (tester) async {
      await tester.pumpWidget(
        _buildCart(CartState(status: CartStatus.loaded, items: [_item()])),
      );
      await tester.pumpAndSettle();
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('does not show Clear button when cart is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildCart(const CartState(status: CartStatus.loaded)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('shows product name when cart has items', (tester) async {
      await tester.pumpWidget(
        _buildCart(CartState(status: CartStatus.loaded, items: [_item()])),
      );
      await tester.pumpAndSettle();
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('shows Proceed to Checkout button when cart has items', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildCart(CartState(status: CartStatus.loaded, items: [_item()])),
      );
      await tester.pumpAndSettle();
      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });

    testWidgets('shows total amount in cart summary', (tester) async {
      await tester.pumpWidget(
        _buildCart(
          CartState(status: CartStatus.loaded, items: [_item(qty: 2)]),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('160'), findsWidgets);
    });

    testWidgets('shows item count in cart summary', (tester) async {
      await tester.pumpWidget(
        _buildCart(
          CartState(status: CartStatus.loaded, items: [_item(qty: 3)]),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('3 items'), findsOneWidget);
    });

    testWidgets('shows multiple cart item names', (tester) async {
      final items = [
        _item(id: 'ci1', name: 'Milk'),
        _item(id: 'ci2', name: 'Bread'),
      ];
      await tester.pumpWidget(
        _buildCart(CartState(status: CartStatus.loaded, items: items)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('Bread'), findsOneWidget);
    });
  });
}
