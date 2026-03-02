import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/core/services/storage/user_service_session.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final socketServiceProvider = Provider<SocketService>((ref) {
  final session = ref.read(userSessionServiceProvider);
  return SocketService(session: session);
});

class SocketService {
  final UserSessionService _session;
  io.Socket? _socket;

  SocketService({required UserSessionService session}) : _session = session;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    void Function(Map<String, dynamic> payload)? onNotification,
    void Function(int count)? onUnreadCount,
  }) {
    final userId = _session.getUserId();
    if (userId == null || userId.isEmpty) return;
    if (isConnected) return;

    _socket = io.io(
      ApiEndpoints.serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': userId})
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.on('connect', (_) => _socket!.emit('get_unread_count'));

    _socket!.on('notification_received', (data) {
      if (data is Map<String, dynamic>) onNotification?.call(data);
    });

    _socket!.on('unread_count', (data) {
      if (data is Map<String, dynamic>) {
        onUnreadCount?.call(data['count'] as int? ?? 0);
      }
    });

    _socket!.on('error', (_) {});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void emitMarkAsRead(String notificationId) =>
      _socket?.emit('mark_as_read', notificationId);

  void requestUnreadCount() => _socket?.emit('get_unread_count');
}
