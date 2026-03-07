import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_ease/features/notification/domain/entities/notification_entity.dart';
import 'package:project_ease/features/notification/presentation/pages/notification_screen.dart';
import 'package:project_ease/features/notification/presentation/state/notification_state.dart';
import 'package:project_ease/features/notification/presentation/view_model/notification_view_model.dart';

class FakeNotificationNotifier extends NotificationViewModel {
  final NotificationState _fixedState;
  FakeNotificationNotifier(this._fixedState);

  @override
  NotificationState build() => _fixedState;

  @override
  Future<void> loadNotifications() async {}

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> deleteNotification(String id) async {}
}

NotificationEntity _notif({
  String id = 'n1',
  bool isRead = false,
  String title = 'Order Placed',
  String message = 'Your order has been placed.',
}) => NotificationEntity(
  id: id,
  orderId: 'o1',
  type: NotificationType.orderCreated,
  title: title,
  message: message,
  isRead: isRead,
  createdAt: DateTime(2025, 11, 30),
);

Widget _buildNotifications(NotificationState state) {
  return ProviderScope(
    overrides: [
      notificationViewModelProvider.overrideWith(
        () => FakeNotificationNotifier(state),
      ),
    ],
    child: const MaterialApp(home: NotificationsScreen()),
  );
}

void main() {
  group('NotificationsScreen Widget Tests', () {
    testWidgets('shows AppBar with "Notifications" title', (tester) async {
      await tester.pumpWidget(
        _buildNotifications(
          const NotificationState(status: NotificationStatus.success),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading and list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildNotifications(
          const NotificationState(status: NotificationStatus.loading),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no notifications', (tester) async {
      await tester.pumpWidget(
        _buildNotifications(
          const NotificationState(status: NotificationStatus.success),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets(
      'shows "Mark all read" button when unread notifications exist',
      (tester) async {
        await tester.pumpWidget(
          _buildNotifications(
            NotificationState(
              status: NotificationStatus.success,
              notifications: [_notif(isRead: false)],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Mark all read'), findsOneWidget);
      },
    );

    testWidgets(
      'does not show "Mark all read" when all notifications are read',
      (tester) async {
        await tester.pumpWidget(
          _buildNotifications(
            NotificationState(
              status: NotificationStatus.success,
              notifications: [_notif(isRead: true)],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Mark all read'), findsNothing);
      },
    );

    testWidgets('shows notification title', (tester) async {
      await tester.pumpWidget(
        _buildNotifications(
          NotificationState(
            status: NotificationStatus.success,
            notifications: [_notif(title: 'Order Confirmed')],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Order Confirmed'), findsOneWidget);
    });

    testWidgets('shows notification message', (tester) async {
      await tester.pumpWidget(
        _buildNotifications(
          NotificationState(
            status: NotificationStatus.success,
            notifications: [_notif(message: 'Ready for pickup!')],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ready for pickup!'), findsOneWidget);
    });

    testWidgets('shows multiple notifications', (tester) async {
      await tester.pumpWidget(
        _buildNotifications(
          NotificationState(
            status: NotificationStatus.success,
            notifications: [
              _notif(id: 'n1', title: 'Order Placed'),
              _notif(id: 'n2', title: 'Order Confirmed'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Order Confirmed'), findsOneWidget);
    });

    testWidgets('renders notifications in a ListView', (tester) async {
      await tester.pumpWidget(
        _buildNotifications(
          NotificationState(
            status: NotificationStatus.success,
            notifications: [
              _notif(),
              _notif(id: 'n2', title: 'Payment Verified'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets(
      'shows empty state even when status is error with no notifications',
      (tester) async {
        await tester.pumpWidget(
          _buildNotifications(
            const NotificationState(
              status: NotificationStatus.error,
              notifications: [],
              errorMessage: 'Failed to load notifications',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('No notifications yet'), findsOneWidget);
      },
    );
  });
}
