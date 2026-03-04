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

  // Mutable callbacks, can be updated after initial connect
  void Function(Map<String, dynamic>)? _onNotification;
  void Function(int)? _onUnreadCount;
  void Function(Map<String, dynamic>)? _onTicketMessage;

  SocketService({required UserSessionService session}) : _session = session;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    void Function(Map<String, dynamic> payload)? onNotification,
    void Function(int count)? onUnreadCount,
    void Function(Map<String, dynamic> payload)? onTicketMessage,
  }) {
    _onNotification = onNotification;
    _onUnreadCount = onUnreadCount;
    _onTicketMessage = onTicketMessage;

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
      if (data is Map<String, dynamic>) _onNotification?.call(data);
    });

    _socket!.on('unread_count', (data) {
      if (data is Map<String, dynamic>) {
        _onUnreadCount?.call(data['count'] as int? ?? 0);
      }
    });

    // Backend emits 'new_message' to the ticket_<id> room when admin sends
    _socket!.on('new_message', (data) {
      if (data is Map<String, dynamic>) _onTicketMessage?.call(data);
    });

    _socket!.on('error', (_) {});
  }

  void setTicketMessageCallback(void Function(Map<String, dynamic>)? callback) {
    _onTicketMessage = callback;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void joinTicket(String ticketId) {
    if (isConnected) {
      _socket?.emit('join_ticket', ticketId);
    } else {
      // Retry once the socket connects
      _socket?.once('connect', (_) {
        _socket?.emit('join_ticket', ticketId);
      });
    }
  }

  void leaveTicket(String ticketId) => _socket?.emit('leave_ticket', ticketId);

  void emitMarkAsRead(String notificationId) =>
      _socket?.emit('mark_as_read', notificationId);

  void requestUnreadCount() => _socket?.emit('get_unread_count');
}
