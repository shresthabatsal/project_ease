import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:project_ease/features/notification/domain/entities/notification_entity.dart';
import 'package:project_ease/features/notification/domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>(
  (ref) => NotificationRepository(
    remote: ref.read(notificationRemoteDatasourceProvider),
  ),
);

class NotificationRepository implements INotificationRepository {
  final NotificationRemoteDatasource _remote;
  NotificationRepository({required NotificationRemoteDatasource remote})
    : _remote = remote;

  Either<Failure, T> _handleError<T>(Object e, String fallback) {
    if (e is DioException) {
      final msg = (e.response?.data is Map)
          ? e.response?.data['message'] ?? fallback
          : fallback;
      return Left(ApiFailure(message: msg, statusCode: e.response?.statusCode));
    }
    return Left(ApiFailure(message: e.toString()));
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final models = await _remote.getNotifications();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return _handleError(e, 'Failed to load notifications');
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      return Right(await _remote.getUnreadCount());
    } catch (e) {
      return _handleError(e, 'Failed to get unread count');
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _remote.markAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return _handleError(e, 'Failed to mark as read');
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _remote.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return _handleError(e, 'Failed to mark all as read');
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String id) async {
    try {
      await _remote.deleteNotification(id);
      return const Right(null);
    } catch (e) {
      return _handleError(e, 'Failed to delete notification');
    }
  }
}
