import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/app_fonts.dart';
import 'package:project_ease/features/order/presentation/pages/order_detail_screen.dart';
import 'package:project_ease/features/notification/domain/entities/notification_entity.dart';
import 'package:project_ease/features/notification/presentation/state/notification_state.dart';
import 'package:project_ease/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(notificationViewModelProvider.notifier).loadNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final state = ref.watch(notificationViewModelProvider);
    final notifier = ref.read(notificationViewModelProvider.notifier);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notifications'),
        actions: [
          if (state.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: notifier.markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(context, state, notifier, isTablet),
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationState state,
    NotificationViewModel notifier,
    bool isTablet,
  ) {
    if (state.status == NotificationStatus.loading &&
        state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll let you know when something happens",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.loadNotifications,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.notifications.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 72, color: Color(0xFFF0F0F0)),
        itemBuilder: (context, i) {
          final n = state.notifications[i];
          return _NotificationTile(
            notification: n,
            isTablet: isTablet,
            onTap: () {
              if (!n.isRead) notifier.markAsRead(n.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(orderId: n.orderId),
                ),
              );
            },
            onDelete: () => notifier.deleteNotification(n.id),
          );
        },
      ),
    );
  }
}

// Notification tile

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final bool isTablet;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.isTablet,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final isUnread = !n.isRead;

    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade50,
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.red.shade400,
          size: 24,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isUnread ? AppColors.primary.withOpacity(0.04) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconBg(n.type),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(n.type), color: _iconColor(n.type), size: 20),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 14,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.message,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),

                    // OTP chip
                    if (n.otp != null &&
                        (n.type == NotificationType.orderConfirmed ||
                            n.type == NotificationType.readyForCollection)) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'OTP: ${n.otp}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 4),
                    Text(
                      timeago.format(n.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(NotificationType type) => switch (type) {
    NotificationType.orderCreated => Icons.receipt_long_rounded,
    NotificationType.paymentVerified => Icons.verified_rounded,
    NotificationType.orderConfirmed => Icons.check_circle_rounded,
    NotificationType.readyForCollection => Icons.shopping_bag_rounded,
    NotificationType.collectionReminder => Icons.alarm_rounded,
    NotificationType.orderCollected => Icons.done_all_rounded,
    NotificationType.orderCancelled => Icons.cancel_rounded,
    NotificationType.paymentRejected => Icons.error_rounded,
    NotificationType.unknown => Icons.notifications_rounded,
  };

  Color _iconBg(NotificationType type) => switch (type) {
    NotificationType.orderCancelled => Colors.red.shade50,
    NotificationType.paymentRejected => Colors.red.shade50,
    NotificationType.paymentVerified ||
    NotificationType.orderConfirmed => Colors.green.shade50,
    NotificationType.readyForCollection => AppColors.primary.withOpacity(0.12),
    _ => Colors.blue.shade50,
  };

  Color _iconColor(NotificationType type) => switch (type) {
    NotificationType.orderCancelled => Colors.red.shade400,
    NotificationType.paymentRejected => Colors.red.shade400,
    NotificationType.paymentVerified ||
    NotificationType.orderConfirmed => Colors.green.shade500,
    NotificationType.readyForCollection => AppColors.primary,
    _ => Colors.blue.shade400,
  };
}
