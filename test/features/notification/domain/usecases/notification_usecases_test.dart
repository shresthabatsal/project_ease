import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/notification/domain/entities/notification_entity.dart';
import 'package:project_ease/features/notification/domain/repositories/notification_repository.dart';
import 'package:project_ease/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:project_ease/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:project_ease/features/notification/domain/usecases/get_unread_count_usecase.dart';
import 'package:project_ease/features/notification/domain/usecases/mark_all_as_read_usecase.dart';
import 'package:project_ease/features/notification/domain/usecases/mark_as_read_usecase.dart';

class MockNotificationRepository extends Mock
    implements INotificationRepository {}

void main() {
  late MockNotificationRepository mockRepo;
  late GetNotificationsUsecase getNotifications;
  late GetUnreadCountUsecase getUnreadCount;
  late MarkAsReadUsecase markAsRead;
  late MarkAllAsReadUsecase markAllAsRead;
  late DeleteNotificationUsecase deleteNotification;

  final tNotification = NotificationEntity(
    id: 'n1',
    orderId: 'o1',
    type: NotificationType.orderCreated,
    title: 'Order Placed',
    message: 'Your order has been placed.',
    isRead: false,
    createdAt: DateTime(2025, 11, 30),
  );

  setUp(() {
    mockRepo = MockNotificationRepository();
    getNotifications = GetNotificationsUsecase(repo: mockRepo);
    getUnreadCount = GetUnreadCountUsecase(repo: mockRepo);
    markAsRead = MarkAsReadUsecase(repo: mockRepo);
    markAllAsRead = MarkAllAsReadUsecase(repo: mockRepo);
    deleteNotification = DeleteNotificationUsecase(repo: mockRepo);
  });

  group('GetNotificationsUsecase', () {
    test('returns list of notifications on success', () async {
      when(() => mockRepo.getNotifications()).thenAnswer(
        (_) async => Right<Failure, List<NotificationEntity>>([tNotification]),
      );
      final result = await getNotifications();
      expect(result.isRight(), true);
      result.fold((_) {}, (list) => expect(list.first.id, 'n1'));
      verify(() => mockRepo.getNotifications()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns empty list when there are no notifications', () async {
      when(
        () => mockRepo.getNotifications(),
      ).thenAnswer((_) async => Right<Failure, List<NotificationEntity>>([]));
      final result = await getNotifications();
      expect(result.isRight(), true);
      result.fold((_) {}, (list) => expect(list, isEmpty));
    });

    test('returns ApiFailure on network error', () async {
      const failure = ApiFailure(message: 'Failed to load notifications');
      when(() => mockRepo.getNotifications()).thenAnswer(
        (_) async => Left<Failure, List<NotificationEntity>>(failure),
      );
      final result = await getNotifications();
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'Failed to load notifications'),
        (_) {},
      );
    });
  });

  group('GetUnreadCountUsecase', () {
    test('returns correct unread count', () async {
      when(
        () => mockRepo.getUnreadCount(),
      ).thenAnswer((_) async => Right<Failure, int>(3));
      final result = await getUnreadCount();
      expect(result.isRight(), true);
      result.fold((_) {}, (count) => expect(count, 3));
      verify(() => mockRepo.getUnreadCount()).called(1);
    });

    test('returns zero when all notifications are read', () async {
      when(
        () => mockRepo.getUnreadCount(),
      ).thenAnswer((_) async => Right<Failure, int>(0));
      final result = await getUnreadCount();
      expect(result.isRight(), true);
      result.fold((_) {}, (count) => expect(count, 0));
    });
  });

  group('MarkAsReadUsecase', () {
    test('passes correct notificationId to repository', () async {
      String? capturedId;
      when(() => mockRepo.markAsRead(any())).thenAnswer((inv) {
        capturedId = inv.positionalArguments[0] as String;
        return Future.value(Right<Failure, void>(null));
      });
      await markAsRead('n1');
      expect(capturedId, 'n1');
    });

    test('returns Right on success', () async {
      when(
        () => mockRepo.markAsRead(any()),
      ).thenAnswer((_) async => Right<Failure, void>(null));
      final result = await markAsRead('n1');
      expect(result.isRight(), true);
      verify(() => mockRepo.markAsRead('n1')).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('isRead flag is true after copyWith', () {
      final updated = tNotification.copyWith(isRead: true);
      expect(updated.isRead, true);
      expect(updated.id, tNotification.id);
    });
  });

  group('MarkAllAsReadUsecase', () {
    test('returns Right and calls repository once', () async {
      when(
        () => mockRepo.markAllAsRead(),
      ).thenAnswer((_) async => Right<Failure, void>(null));
      final result = await markAllAsRead();
      expect(result.isRight(), true);
      verify(() => mockRepo.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns ApiFailure when marking all fails', () async {
      const failure = ApiFailure(message: 'Server error');
      when(
        () => mockRepo.markAllAsRead(),
      ).thenAnswer((_) async => Left<Failure, void>(failure));
      final result = await markAllAsRead();
      expect(result.isLeft(), true);
    });
  });

  group('DeleteNotificationUsecase', () {
    test('passes notificationId to repository and returns Right', () async {
      when(
        () => mockRepo.deleteNotification(any()),
      ).thenAnswer((_) async => Right<Failure, void>(null));
      final result = await deleteNotification('n1');
      expect(result.isRight(), true);
      verify(() => mockRepo.deleteNotification('n1')).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns ApiFailure when deletion fails', () async {
      const failure = ApiFailure(message: 'Notification not found');
      when(
        () => mockRepo.deleteNotification(any()),
      ).thenAnswer((_) async => Left<Failure, void>(failure));
      final result = await deleteNotification('n99');
      expect(result.isLeft(), true);
    });
  });
}
