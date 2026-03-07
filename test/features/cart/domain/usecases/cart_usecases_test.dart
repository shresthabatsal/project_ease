import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';
import 'package:project_ease/features/cart/domain/repositories/cart_repository.dart';
import 'package:project_ease/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:project_ease/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:project_ease/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:project_ease/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:project_ease/features/cart/domain/usecases/update_cart_usecase.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';

class MockCartRepository extends Mock implements ICartRepository {}

void main() {
  late MockCartRepository mockRepo;
  late GetCartUsecase getCart;
  late AddToCartUsecase addToCart;
  late UpdateCartItemUsecase updateCartItem;
  late RemoveCartItemUsecase removeCartItem;
  late ClearCartUsecase clearCart;

  final tProduct = const ProductEntity(
    productId: 'p1',
    name: 'Test Product',
    price: 150.0,
    stock: 10,
  );
  final tCartItem = CartItemEntity(
    cartItemId: 'ci1',
    product: tProduct,
    quantity: 2,
  );

  setUp(() {
    mockRepo = MockCartRepository();
    getCart = GetCartUsecase(mockRepo);
    addToCart = AddToCartUsecase(mockRepo);
    updateCartItem = UpdateCartItemUsecase(mockRepo);
    removeCartItem = RemoveCartItemUsecase(mockRepo);
    clearCart = ClearCartUsecase(mockRepo);
  });

  group('GetCartUsecase', () {
    test('returns list of cart items on success', () async {
      when(() => mockRepo.getCart()).thenAnswer(
        (_) async => Right<Failure, List<CartItemEntity>>([tCartItem]),
      );
      final result = await getCart();
      expect(result.isRight(), true);
      result.fold((_) {}, (items) => expect(items.first, tCartItem));
      verify(() => mockRepo.getCart()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns empty list when cart is empty', () async {
      when(
        () => mockRepo.getCart(),
      ).thenAnswer((_) async => Right<Failure, List<CartItemEntity>>([]));
      final result = await getCart();
      expect(result.isRight(), true);
      result.fold((_) {}, (items) => expect(items, isEmpty));
    });

    test('returns ApiFailure when network fails', () async {
      const failure = ApiFailure(message: 'Failed to fetch cart');
      when(
        () => mockRepo.getCart(),
      ).thenAnswer((_) async => Left<Failure, List<CartItemEntity>>(failure));
      final result = await getCart();
      expect(result.isLeft(), true);
      result.fold((f) => expect(f.message, 'Failed to fetch cart'), (_) {});
    });
  });

  group('AddToCartUsecase', () {
    test('calls repository with correct productId and quantity', () async {
      String? capturedId;
      int? capturedQty;
      when(
        () => mockRepo.addToCart(
          productId: any(named: 'productId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((inv) {
        capturedId = inv.namedArguments[const Symbol('productId')] as String;
        capturedQty = inv.namedArguments[const Symbol('quantity')] as int;
        return Future.value(Right<Failure, void>(null));
      });
      await addToCart(const AddToCartParams(productId: 'p1', quantity: 3));
      expect(capturedId, 'p1');
      expect(capturedQty, 3);
    });

    test('returns Right on success', () async {
      when(
        () => mockRepo.addToCart(
          productId: any(named: 'productId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => Right<Failure, void>(null));
      final result = await addToCart(
        const AddToCartParams(productId: 'p1', quantity: 1),
      );
      expect(result.isRight(), true);
    });

    test('returns ApiFailure when item cannot be added', () async {
      const failure = ApiFailure(message: 'Out of stock');
      when(
        () => mockRepo.addToCart(
          productId: any(named: 'productId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => Left<Failure, void>(failure));
      final result = await addToCart(
        const AddToCartParams(productId: 'p1', quantity: 5),
      );
      expect(result.isLeft(), true);
      result.fold((f) => expect(f.message, 'Out of stock'), (_) {});
    });
  });

  group('UpdateCartItemUsecase', () {
    test('returns updated CartItemEntity on success', () async {
      final updated = tCartItem.copyWith(quantity: 5);
      when(
        () => mockRepo.updateCartItem(
          cartItemId: any(named: 'cartItemId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => Right<Failure, CartItemEntity>(updated));
      final result = await updateCartItem(
        const UpdateCartItemParams(cartItemId: 'ci1', quantity: 5),
      );
      expect(result.isRight(), true);
      result.fold((_) {}, (item) => expect(item.quantity, 5));
      verify(
        () => mockRepo.updateCartItem(cartItemId: 'ci1', quantity: 5),
      ).called(1);
    });

    test('returns ApiFailure when update fails', () async {
      const failure = ApiFailure(message: 'Item not found');
      when(
        () => mockRepo.updateCartItem(
          cartItemId: any(named: 'cartItemId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => Left<Failure, CartItemEntity>(failure));
      final result = await updateCartItem(
        const UpdateCartItemParams(cartItemId: 'ci99', quantity: 2),
      );
      expect(result.isLeft(), true);
    });
  });

  group('RemoveCartItemUsecase', () {
    test(
      'passes cartItemId to repository and returns Right on success',
      () async {
        when(
          () => mockRepo.removeFromCart(any()),
        ).thenAnswer((_) async => Right<Failure, void>(null));
        final result = await removeCartItem('ci1');
        expect(result.isRight(), true);
        verify(() => mockRepo.removeFromCart('ci1')).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    test('returns ApiFailure when removal fails', () async {
      const failure = ApiFailure(message: 'Could not remove item');
      when(
        () => mockRepo.removeFromCart(any()),
      ).thenAnswer((_) async => Left<Failure, void>(failure));
      final result = await removeCartItem('ci1');
      expect(result.isLeft(), true);
    });
  });

  group('ClearCartUsecase', () {
    test('returns Right on successful clear', () async {
      when(
        () => mockRepo.clearCart(),
      ).thenAnswer((_) async => Right<Failure, void>(null));
      final result = await clearCart();
      expect(result.isRight(), true);
      verify(() => mockRepo.clearCart()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns ApiFailure when clear fails', () async {
      const failure = ApiFailure(message: 'Clear failed');
      when(
        () => mockRepo.clearCart(),
      ).thenAnswer((_) async => Left<Failure, void>(failure));
      final result = await clearCart();
      expect(result.isLeft(), true);
    });
  });
}
