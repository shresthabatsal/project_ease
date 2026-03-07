import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/notification/domain/entities/notification_entity.dart';
import 'package:project_ease/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:project_ease/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:project_ease/features/notification/domain/usecases/get_unread_count_usecase.dart';
import 'package:project_ease/features/notification/domain/usecases/mark_all_as_read_usecase.dart';
import 'package:project_ease/features/notification/domain/usecases/mark_as_read_usecase.dart';
import 'package:project_ease/features/notification/presentation/state/notification_state.dart';

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
      NotificationViewModel.new,
    );

class NotificationViewModel extends Notifier<NotificationState> {
  late final GetNotificationsUsecase _getNotifications;
  late final GetUnreadCountUsecase _getUnreadCount;
  late final MarkAsReadUsecase _markAsRead;
  late final MarkAllAsReadUsecase _markAllAsRead;
  late final DeleteNotificationUsecase _deleteNotification;

  @override
  NotificationState build() {
    _getNotifications = ref.read(getNotificationsUsecaseProvider);
    _getUnreadCount = ref.read(getUnreadCountUsecaseProvider);
    _markAsRead = ref.read(markAsReadUsecaseProvider);
    _markAllAsRead = ref.read(markAllAsReadUsecaseProvider);
    _deleteNotification = ref.read(deleteNotificationUsecaseProvider);
    return const NotificationState();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(status: NotificationStatus.loading);
    final result = await _getNotifications();
    result.fold(
      (f) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: f.message,
      ),
      (list) {
        final unread = list.where((n) => !n.isRead).length;
        state = state.copyWith(
          status: NotificationStatus.success,
          notifications: list,
          unreadCount: unread,
        );
      },
    );
  }

  Future<void> loadUnreadCount() async {
    final result = await _getUnreadCount();
    result.fold((_) {}, (count) => state = state.copyWith(unreadCount: count));
  }

  Future<void> markAsRead(String notificationId) async {
    final updated = state.notifications
        .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
        .toList();
    state = state.copyWith(
      notifications: updated,
      unreadCount: (state.unreadCount - 1).clamp(0, 999),
    );
    await _markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: updated, unreadCount: 0);
    await _markAllAsRead();
  }

  Future<void> deleteNotification(String notificationId) async {
    final updated = state.notifications
        .where((n) => n.id != notificationId)
        .toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
    await _deleteNotification(notificationId);
  }

  void addRealtimeNotification(NotificationEntity notification) {
    final updated = [notification, ...state.notifications];
    state = state.copyWith(
      notifications: updated,
      unreadCount: state.unreadCount + 1,
    );
  }

  void setUnreadCount(int count) => state = state.copyWith(unreadCount: count);
}
