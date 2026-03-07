import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';
import 'package:project_ease/features/order/domain/usecases/buy_now_usecase.dart';
import 'package:project_ease/features/order/domain/usecases/cancel_order_usecase.dart';
import 'package:project_ease/features/order/domain/usecases/create_order_usecase.dart';
import 'package:project_ease/features/order/domain/usecases/get_orders_usecasse.dart';
import 'package:project_ease/features/order/domain/usecases/get_users_order_usecase.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late MockOrderRepository mockRepo;
  late CreateOrderUsecase createOrder;
  late BuyNowUsecase buyNow;
  late GetUserOrdersUsecase getUserOrders;
  late GetOrderUsecase getOrder;
  late CancelOrderUsecase cancelOrder;

  final tOrder = OrderEntity(
    orderId: 'o1',
    storeId: 's1',
    storeName: 'Test Store',
    items: const [],
    totalAmount: 300.0,
    pickupDate: DateTime(2025, 12, 1),
    pickupTime: '10:00 AM',
    paymentStatus: 'PENDING',
    status: 'PENDING',
    orderDate: DateTime(2025, 11, 30),
  );

  setUp(() {
    mockRepo = MockOrderRepository();
    createOrder = CreateOrderUsecase(mockRepo);
    buyNow = BuyNowUsecase(mockRepo);
    getUserOrders = GetUserOrdersUsecase(mockRepo);
    getOrder = GetOrderUsecase(mockRepo);
    cancelOrder = CancelOrderUsecase(mockRepo);
  });

  group('CreateOrderUsecase', () {
    test('returns OrderEntity on successful order creation', () async {
      when(
        () => mockRepo.createOrder(
          storeId: any(named: 'storeId'),
          pickupDate: any(named: 'pickupDate'),
          pickupTime: any(named: 'pickupTime'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => Right<Failure, OrderEntity>(tOrder));

      final result = await createOrder(
        const CreateOrderParams(
          storeId: 's1',
          pickupDate: '2025-12-01',
          pickupTime: '10:00 AM',
        ),
      );

      expect(result.isRight(), true);
      result.fold((_) {}, (o) => expect(o.orderId, 'o1'));
    });

    test('passes all params correctly to repository', () async {
      String? capturedStore, capturedDate, capturedTime, capturedNotes;
      when(
        () => mockRepo.createOrder(
          storeId: any(named: 'storeId'),
          pickupDate: any(named: 'pickupDate'),
          pickupTime: any(named: 'pickupTime'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((inv) {
        capturedStore = inv.namedArguments[const Symbol('storeId')] as String;
        capturedDate = inv.namedArguments[const Symbol('pickupDate')] as String;
        capturedTime = inv.namedArguments[const Symbol('pickupTime')] as String;
        capturedNotes = inv.namedArguments[const Symbol('notes')] as String?;
        return Future.value(Right<Failure, OrderEntity>(tOrder));
      });
      await createOrder(
        const CreateOrderParams(
          storeId: 's1',
          pickupDate: '2025-12-01',
          pickupTime: '10:00 AM',
          notes: 'Leave at door',
        ),
      );
      expect(capturedStore, 's1');
      expect(capturedDate, '2025-12-01');
      expect(capturedTime, '10:00 AM');
      expect(capturedNotes, 'Leave at door');
    });

    test('returns ApiFailure when order creation fails', () async {
      const failure = ApiFailure(message: 'Cart is empty');
      when(
        () => mockRepo.createOrder(
          storeId: any(named: 'storeId'),
          pickupDate: any(named: 'pickupDate'),
          pickupTime: any(named: 'pickupTime'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => Left<Failure, OrderEntity>(failure));

      final result = await createOrder(
        const CreateOrderParams(
          storeId: 's1',
          pickupDate: '2025-12-01',
          pickupTime: '10:00 AM',
        ),
      );
      expect(result.isLeft(), true);
      result.fold((f) => expect(f.message, 'Cart is empty'), (_) {});
    });
  });

  group('BuyNowUsecase', () {
    test('returns OrderEntity on success', () async {
      when(
        () => mockRepo.buyNow(
          productId: any(named: 'productId'),
          quantity: any(named: 'quantity'),
          storeId: any(named: 'storeId'),
          pickupDate: any(named: 'pickupDate'),
          pickupTime: any(named: 'pickupTime'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => Right<Failure, OrderEntity>(tOrder));

      final result = await buyNow(
        const BuyNowParams(
          productId: 'p1',
          quantity: 1,
          storeId: 's1',
          pickupDate: '2025-12-01',
          pickupTime: '10:00 AM',
        ),
      );
      expect(result.isRight(), true);
    });

    test('returns ApiFailure when product is out of stock', () async {
      const failure = ApiFailure(message: 'Insufficient stock');
      when(
        () => mockRepo.buyNow(
          productId: any(named: 'productId'),
          quantity: any(named: 'quantity'),
          storeId: any(named: 'storeId'),
          pickupDate: any(named: 'pickupDate'),
          pickupTime: any(named: 'pickupTime'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => Left<Failure, OrderEntity>(failure));

      final result = await buyNow(
        const BuyNowParams(
          productId: 'p1',
          quantity: 999,
          storeId: 's1',
          pickupDate: '2025-12-01',
          pickupTime: '10:00 AM',
        ),
      );
      expect(result.isLeft(), true);
    });
  });

  group('GetUserOrdersUsecase', () {
    test('returns list of orders on success', () async {
      when(
        () => mockRepo.getUserOrders(),
      ).thenAnswer((_) async => Right<Failure, List<OrderEntity>>([tOrder]));
      final result = await getUserOrders();
      expect(result.isRight(), true);
      result.fold((_) {}, (orders) => expect(orders.first.orderId, 'o1'));
      verify(() => mockRepo.getUserOrders()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns empty list when user has no orders', () async {
      when(
        () => mockRepo.getUserOrders(),
      ).thenAnswer((_) async => Right<Failure, List<OrderEntity>>([]));
      final result = await getUserOrders();
      expect(result.isRight(), true);
      result.fold((_) {}, (orders) => expect(orders, isEmpty));
    });

    test('returns NetworkFailure on network error', () async {
      const failure = NetworkFailure(message: 'No internet');
      when(
        () => mockRepo.getUserOrders(),
      ).thenAnswer((_) async => Left<Failure, List<OrderEntity>>(failure));
      final result = await getUserOrders();
      expect(result.isLeft(), true);
      result.fold((f) => expect(f.message, 'No internet'), (_) {});
    });
  });

  group('GetOrderUsecase', () {
    test('returns single order by ID', () async {
      when(
        () => mockRepo.getOrder(any()),
      ).thenAnswer((_) async => Right<Failure, OrderEntity>(tOrder));
      final result = await getOrder('o1');
      expect(result.isRight(), true);
      result.fold((_) {}, (o) => expect(o.orderId, 'o1'));
      verify(() => mockRepo.getOrder('o1')).called(1);
    });
  });

  group('CancelOrderUsecase', () {
    test('returns cancelled order on success', () async {
      final cancelled = OrderEntity(
        orderId: 'o1',
        storeId: 's1',
        items: const [],
        totalAmount: 300.0,
        pickupDate: DateTime(2025, 12, 1),
        pickupTime: '10:00 AM',
        paymentStatus: 'PENDING',
        status: 'CANCELLED',
        orderDate: DateTime(2025, 11, 30),
      );
      when(
        () => mockRepo.cancelOrder(any(), any()),
      ).thenAnswer((_) async => Right<Failure, OrderEntity>(cancelled));
      final result = await cancelOrder(
        const CancelOrderParams(orderId: 'o1', reason: 'Changed mind'),
      );
      expect(result.isRight(), true);
      result.fold((_) {}, (o) => expect(o.status, 'CANCELLED'));
    });

    test('passes orderId and reason to repository', () async {
      String? capturedId;
      String? capturedReason;
      when(() => mockRepo.cancelOrder(any(), any())).thenAnswer((inv) {
        capturedId = inv.positionalArguments[0] as String;
        capturedReason = inv.positionalArguments[1] as String?;
        return Future.value(Right<Failure, OrderEntity>(tOrder));
      });
      await cancelOrder(
        const CancelOrderParams(orderId: 'o1', reason: 'Wrong item'),
      );
      expect(capturedId, 'o1');
      expect(capturedReason, 'Wrong item');
    });
  });
}
