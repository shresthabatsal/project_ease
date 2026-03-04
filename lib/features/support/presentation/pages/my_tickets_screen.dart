import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';
import 'package:project_ease/features/support/presentation/pages/ticket_chat_screen.dart';
import 'package:project_ease/features/support/presentation/pages/create_ticket_screen.dart';
import 'package:project_ease/features/support/presentation/state/support_state.dart';
import 'package:project_ease/features/support/presentation/view_model/support_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ticketListViewModelProvider);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Support',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
            onPressed: () =>
                ref.read(ticketListViewModelProvider.notifier).loadTickets(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Ticket',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _buildBody(context, state, isTablet),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TicketListState state,
    bool isTablet,
  ) {
    if (state.status == SupportStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == SupportStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'Something went wrong',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context
                  .findAncestorStateOfType<ConsumerState>()
                  ?.ref
                  .read(ticketListViewModelProvider.notifier)
                  .loadTickets(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.support_agent_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No tickets yet',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Report an issue and we\'ll help you out',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.findAncestorWidgetOfExactType<Consumer>().toString().isEmpty
          ? Future.value()
          : Future.value(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          isTablet ? 24 : 16,
          16,
          isTablet ? 24 : 16,
          100,
        ),
        itemCount: state.tickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) => _TicketCard(
          ticket: state.tickets[i],
          isTablet: isTablet,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TicketChatScreen(ticket: state.tickets[i]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ticket card
// ─────────────────────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final TicketEntity ticket;
  final bool isTablet;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _categoryIcon(ticket.category),
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.title,
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ticket.category.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: ticket.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ticket.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _PriorityChip(priority: ticket.priority),
                const Spacer(),
                if (ticket.adminName != null) ...[
                  Icon(
                    Icons.person_outline_rounded,
                    size: 12,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    ticket.adminName!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  timeago.format(ticket.updatedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(TicketCategory cat) => switch (cat) {
    TicketCategory.bug => Icons.bug_report_outlined,
    TicketCategory.complaint => Icons.sentiment_dissatisfied_outlined,
    TicketCategory.refund => Icons.currency_rupee_rounded,
    TicketCategory.delivery => Icons.local_shipping_outlined,
    TicketCategory.other => Icons.help_outline_rounded,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Small chips
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final TicketStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      TicketStatus.open => (const Color(0xFF2196F3), const Color(0xFFE3F2FD)),
      TicketStatus.inProgress => (
        const Color(0xFFFF9800),
        const Color(0xFFFFF3E0),
      ),
      TicketStatus.resolved => (
        const Color(0xFF4CAF50),
        const Color(0xFFE8F5E9),
      ),
      TicketStatus.closed => (Colors.grey, const Color(0xFFF5F5F5)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final TicketPriority priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (priority) {
      TicketPriority.high => (
        Colors.red.shade400,
        Icons.keyboard_double_arrow_up_rounded,
      ),
      TicketPriority.medium => (
        Colors.orange.shade400,
        Icons.drag_handle_rounded,
      ),
      TicketPriority.low => (
        Colors.green.shade400,
        Icons.keyboard_double_arrow_down_rounded,
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          priority.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
