import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/order_detail_screen.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/presentation/state/order_state.dart';
import 'package:project_ease/features/order/presentation/view_model/order_view_model.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  final String? initialFilter;

  const MyOrdersScreen({super.key, this.initialFilter});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  late String? _activeFilter = widget.initialFilter; // null = All

  static const _filters = [
    'PENDING',
    'CONFIRMED',
    'READY_FOR_COLLECTION',
    'COLLECTED',
    'CANCELLED',
  ];

  static const _filterLabels = {
    'PENDING': 'Pending',
    'CONFIRMED': 'Confirmed',
    'READY_FOR_COLLECTION': 'Ready',
    'COLLECTED': 'Collected',
    'CANCELLED': 'Cancelled',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(orderViewModelProvider.notifier).loadOrders(),
    );
  }

  List<OrderEntity> _filtered(List<OrderEntity> orders) {
    if (_activeFilter == null) return orders;
    return orders.where((o) => o.status == _activeFilter).toList();
  }

  Color _statusColor(String status) => switch (status) {
    'PENDING' => Colors.orange,
    'CONFIRMED' => Colors.blue,
    'READY_FOR_COLLECTION' => Colors.purple,
    'COLLECTED' => Colors.green,
    'CANCELLED' => Colors.red,
    _ => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderViewModelProvider);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final filtered = _filtered(state.orders);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Orders',
          style: TextStyle(
            fontSize: isTablet ? 20 : 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Filter bar ───────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // "All" chip
                  _FilterChip(
                    label: 'All',
                    active: _activeFilter == null,
                    color: AppColors.primary,
                    onTap: () => setState(() => _activeFilter = null),
                  ),
                  ..._filters.map(
                    (f) => _FilterChip(
                      label: _filterLabels[f] ?? f,
                      active: _activeFilter == f,
                      color: _statusColor(f),
                      onTap: () => setState(
                        () => _activeFilter = _activeFilter == f ? null : f,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Orders list ──────────────────────────────────────────────
          Expanded(
            child: () {
              if (state.status == OrderStatus.loading && state.orders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == OrderStatus.error && state.orders.isEmpty) {
                return _ErrorView(
                  message: state.errorMessage ?? 'Failed to load orders.',
                  onRetry: () =>
                      ref.read(orderViewModelProvider.notifier).loadOrders(),
                );
              }
              if (filtered.isEmpty) {
                return _EmptyView(filtered: _activeFilter != null);
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.read(orderViewModelProvider.notifier).loadOrders(),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 16,
                    vertical: 12,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _OrderCard(
                    order: filtered[i],
                    isTablet: isTablet,
                    statusColor: _statusColor(filtered[i].status),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailScreen(orderId: filtered[i].orderId),
                        ),
                      ).then(
                        (_) => ref
                            .read(orderViewModelProvider.notifier)
                            .loadOrders(),
                      );
                    },
                  ),
                ),
              );
            }(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter chip
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final bool isTablet;
  final Color statusColor;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.isTablet,
    required this.statusColor,
    required this.onTap,
  });

  String get _shortId {
    final id = order.orderId;
    return '#${id.length > 8 ? id.substring(id.length - 8).toUpperCase() : id.toUpperCase()}';
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String get _statusLabel => switch (order.status) {
    'PENDING' => 'Pending',
    'CONFIRMED' => 'Confirmed',
    'READY_FOR_COLLECTION' => 'Ready',
    'COLLECTED' => 'Collected',
    'CANCELLED' => 'Cancelled',
    _ => order.status,
  };

  @override
  Widget build(BuildContext context) {
    final payPending =
        order.paymentStatus == 'PENDING' && order.status != 'CANCELLED';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: ID + status badge ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    _shortId,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor.withOpacity(0.85),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),

            // ── Items summary ──────────────────────────────────────
            Text(
              () {
                final preview = order.items
                    .take(2)
                    .map((i) => '${i.productName} ×${i.quantity}')
                    .join(', ');
                final more = order.items.length > 2
                    ? ' +${order.items.length - 2} more'
                    : '';
                return preview + more;
              }(),
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // ── Footer: date + pay badge + total ───────────────────
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(order.pickupDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
                const Spacer(),
                if (payPending) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      'Pay Now',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
                Text(
                  'NPR ${order.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty + Error views
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final bool filtered;

  const _EmptyView({required this.filtered});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 14),
          Text(
            filtered ? 'No orders with this status.' : 'No orders yet.',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          ),
          if (!filtered) ...[
            const SizedBox(height: 6),
            Text(
              'Start shopping to place your first order!',
              style: TextStyle(color: Colors.grey.shade300, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 14),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
