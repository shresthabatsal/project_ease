import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/services/websocket/socket_service.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/features/support/data/models/message_api_model.dart';
import 'package:project_ease/features/support/domain/entities/message_entity.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';
import 'package:project_ease/features/support/presentation/state/support_state.dart';
import 'package:project_ease/features/support/presentation/view_model/support_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class TicketChatScreen extends ConsumerStatefulWidget {
  final TicketEntity ticket;
  const TicketChatScreen({super.key, required this.ticket});

  @override
  ConsumerState<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends ConsumerState<TicketChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatViewModelProvider.notifier).loadChat(widget.ticket);

      final socket = ref.read(socketServiceProvider);

      // Register callback directly on socket so admin replies are received
      // even if the socket was already connected before this screen mounted.
      socket.setTicketMessageCallback((payload) {
        if (!mounted) return;
        try {
          final model = MessageApiModel.fromJson(payload);
          ref
              .read(chatViewModelProvider.notifier)
              .addRealtimeMessage(model.toEntity());
        } catch (_) {}
      });

      // Join the ticket room — retries automatically if not yet connected
      socket.joinTicket(widget.ticket.ticketId);
    });
  }

  @override
  void dispose() {
    final socket = ref.read(socketServiceProvider);
    socket.leaveTicket(widget.ticket.ticketId);
    // Clear the callback so messages don't fire after screen is gone
    socket.setTicketMessageCallback(null);
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    // Auto-scroll when new messages arrive
    ref.listen(
      chatViewModelProvider.select((s) => s.messages.length),
      (_, __) => _scrollToBottom(),
    );

    final ticket = state.ticket ?? widget.ticket;
    final isClosed = ticket.status == TicketStatus.closed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.title,
              style: TextStyle(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                _StatusDot(status: ticket.status),
                const SizedBox(width: 4),
                Text(
                  ticket.status.label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (ticket.adminName != null) ...[
                  Text(' · ', style: TextStyle(color: Colors.grey.shade400)),
                  Text(
                    ticket.adminName!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          if (!isClosed)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'close',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Close Ticket'),
                    ],
                  ),
                ),
              ],
              onSelected: (v) {
                if (v == 'close') _confirmClose(context);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Ticket info banner ──────────────────────────────────────────
          _TicketInfoBanner(ticket: ticket, isTablet: isTablet),

          // ── Messages ────────────────────────────────────────────────────
          Expanded(child: _buildMessages(state, isTablet)),

          // ── Closed notice or input ──────────────────────────────────────
          if (isClosed)
            _ClosedBanner()
          else
            _MessageInput(
              controller: _msgCtrl,
              isTablet: isTablet,
              onSend: _sendMessage,
            ),
        ],
      ),
    );
  }

  Widget _buildMessages(ChatState state, bool isTablet) {
    if (state.status == SupportStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet.\nStart the conversation!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade400, height: 1.5),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      itemCount: state.messages.length,
      itemBuilder: (ctx, i) {
        final msg = state.messages[i];
        final prev = i > 0 ? state.messages[i - 1] : null;
        final showDate =
            prev == null || !_sameDay(msg.createdAt, prev.createdAt);
        return Column(
          children: [
            if (showDate) _DateDivider(date: msg.createdAt),
            _MessageBubble(message: msg, isTablet: isTablet),
          ],
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    final ok = await ref.read(chatViewModelProvider.notifier).sendMessage(text);
    if (!ok && mounted) {
      final err = ref.read(chatViewModelProvider).errorMessage;
      SnackbarUtils.showError(context, err ?? 'Failed to send');
    }
  }

  void _confirmClose(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Close ticket?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Once closed, you won\'t be able to send messages. You can open a new ticket if needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref
                  .read(chatViewModelProvider.notifier)
                  .closeTicket();
              if (mounted && !ok) {
                SnackbarUtils.showError(context, 'Failed to close ticket');
              }
            },
            child: const Text('Close', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ticket info banner at top of chat
// ─────────────────────────────────────────────────────────────────────────────

class _TicketInfoBanner extends StatelessWidget {
  final TicketEntity ticket;
  final bool isTablet;

  const _TicketInfoBanner({required this.ticket, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _chip(ticket.category.label, AppColors.primary),
          const SizedBox(width: 8),
          _priorityChip(ticket.priority),
          const Spacer(),
          Text(
            '#${ticket.ticketId.substring(ticket.ticketId.length > 6 ? ticket.ticketId.length - 6 : 0)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade400,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
    ),
  );

  Widget _priorityChip(TicketPriority p) {
    final color = switch (p) {
      TicketPriority.high => Colors.red.shade400,
      TicketPriority.medium => Colors.orange.shade400,
      TicketPriority.low => Colors.green.shade400,
    };
    return _chip(p.label, color);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message bubble
// ─────────────────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isTablet;

  const _MessageBubble({required this.message, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromUser;
    final isPending = message.messageId.startsWith('pending_');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isUser && message.senderName != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 13,
                  color: isUser ? Colors.black87 : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPending
                        ? 'Sending…'
                        : timeago.format(message.createdAt, locale: 'en_short'),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                  if (isUser && isPending) ...[
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date divider
// ─────────────────────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label =
        date.year == now.year && date.month == now.month && date.day == now.day
        ? 'Today'
        : '${date.day}/${date.month}/${date.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade200, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade200, height: 1)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status dot
// ─────────────────────────────────────────────────────────────────────────────

class _StatusDot extends StatelessWidget {
  final TicketStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TicketStatus.open => const Color(0xFF2196F3),
      TicketStatus.inProgress => const Color(0xFFFF9800),
      TicketStatus.resolved => const Color(0xFF4CAF50),
      TicketStatus.closed => Colors.grey,
    };
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Closed banner
// ─────────────────────────────────────────────────────────────────────────────

class _ClosedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: Colors.grey.shade100,
      child: Text(
        'This ticket is closed',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message input bar
// ─────────────────────────────────────────────────────────────────────────────

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isTablet;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.isTablet,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        12,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              style: TextStyle(fontSize: isTablet ? 15 : 14),
              decoration: InputDecoration(
                hintText: 'Type a message…',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
