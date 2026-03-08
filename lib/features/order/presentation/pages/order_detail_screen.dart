import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/entities/payment_entity.dart';
import 'package:project_ease/features/order/domain/usecases/get_order_payment_usecase.dart';
import 'package:project_ease/features/order/presentation/pages/receipt_upload_screen.dart';
import 'package:project_ease/features/order/presentation/view_model/order_view_model.dart';

final _orderDetailProvider = FutureProvider.autoDispose
    .family<OrderEntity?, String>((ref, orderId) async {
      final vm = ref.read(orderViewModelProvider.notifier);
      return vm.fetchOrder(orderId);
    });

final _orderPaymentProvider = FutureProvider.autoDispose
    .family<PaymentEntity?, String>((ref, orderId) async {
      final usecase = ref.read(getOrderPaymentUsecaseProvider);
      final result = await usecase(orderId);
      return result.fold((_) => null, (p) => p);
    });

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_orderDetailProvider(orderId));
    final paymentAsync = ref.watch(_orderPaymentProvider(orderId));
    final isTablet = MediaQuery.of(context).size.width >= 600;

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
          'Order Details',
          style: TextStyle(
            fontSize: isTablet ? 20 : 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () {
              ref.invalidate(_orderDetailProvider(orderId));
              ref.invalidate(_orderPaymentProvider(orderId));
            },
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => _ErrorView(
          message: e.toString(),
          onRetry: () {
            ref.invalidate(_orderDetailProvider(orderId));
            ref.invalidate(_orderPaymentProvider(orderId));
          },
        ),
        data: (order) {
          if (order == null) {
            return _ErrorView(
              message: 'Order not found.',
              onRetry: () {
                ref.invalidate(_orderDetailProvider(orderId));
                ref.invalidate(_orderPaymentProvider(orderId));
              },
            );
          }
          // payment is null until receipt is submitted
          final payment = paymentAsync.when(
            data: (p) => p,
            loading: () => null,
            error: (_, __) => null,
          );
          return _DetailBody(
            order: order,
            payment: payment,
            orderId: orderId,
            isTablet: isTablet,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailBody
// ─────────────────────────────────────────────────────────────────────────────

class _DetailBody extends ConsumerWidget {
  final OrderEntity order;
  final PaymentEntity? payment; // null = no receipt submitted yet
  final String orderId;
  final bool isTablet;

  const _DetailBody({
    required this.order,
    required this.payment,
    required this.orderId,
    required this.isTablet,
  });

  // Show Pay Now only if no receipt has been submitted yet
  bool get _canPay =>
      payment == null &&
      order.paymentStatus == 'PENDING' &&
      order.status != 'CANCELLED' &&
      order.status != 'COLLECTED';

  // Show "receipt submitted, awaiting verification" state
  bool get _receiptSubmitted =>
      payment != null && order.paymentStatus == 'PENDING';

  bool get _canCancel =>
      order.status != 'COLLECTED' && order.status != 'CANCELLED';

  bool get _showOtp =>
      (order.status == 'CONFIRMED' || order.status == 'READY_FOR_COLLECTION') &&
      order.otp != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 16,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status banner
                _StatusBanner(
                  order: order,
                  receiptSubmitted: _receiptSubmitted,
                  isTablet: isTablet,
                ),

                const SizedBox(height: 16),

                // Pickup code (only after payment verified)
                if (_showOtp) ...[
                  _OtpCard(otp: order.otp!, isTablet: isTablet),
                  const SizedBox(height: 16),
                ],

                // Order info
                _SectionCard(
                  title: 'Order Info',
                  children: [
                    _DetailRow(
                      label: 'Order ID',
                      value: _shortId(order.orderId),
                      isTablet: isTablet,
                    ),
                    _DetailRow(
                      label: 'Store',
                      value: order.storeName ?? order.storeId,
                      isTablet: isTablet,
                    ),
                    _DetailRow(
                      label: 'Pickup Date',
                      value: _fmtDate(order.pickupDate),
                      isTablet: isTablet,
                    ),
                    _DetailRow(
                      label: 'Pickup Time',
                      value: order.pickupTime,
                      isTablet: isTablet,
                    ),
                    _DetailRow(
                      label: 'Order Date',
                      value: _fmtDateTime(order.orderDate),
                      isTablet: isTablet,
                    ),
                    if (order.notes?.isNotEmpty == true)
                      _DetailRow(
                        label: 'Notes',
                        value: order.notes!,
                        isTablet: isTablet,
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Items ────────────────────────────────────────────────
                _SectionCard(
                  title: 'Items',
                  children: [
                    ...order.items.map(
                      (item) => _ItemRow(item: item, isTablet: isTablet),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'NPR ${order.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Payment ──────────────────────────────────────────────
                _SectionCard(
                  title: 'Payment',
                  children: [
                    _DetailRow(
                      label: 'Method',
                      value: 'Online',
                      isTablet: isTablet,
                    ),
                    _DetailRow(
                      label: 'Status',
                      value: _paymentLabel(order.paymentStatus),
                      valueColor: _paymentColor(order.paymentStatus),
                      isTablet: isTablet,
                    ),
                    if (_receiptSubmitted)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Colors.orange.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Receipt submitted · Awaiting admin verification',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // ── Action buttons ───────────────────────────────────────────────
        if (_canPay || _canCancel)
          _BottomActions(
            canPay: _canPay,
            canCancel: _canCancel,
            isTablet: isTablet,
            onPay: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceiptUploadScreen(order: order),
              ),
            ).then((_) => ref.invalidate(_orderDetailProvider(orderId))),
            onCancel: () => _showCancelDialog(context, ref),
          ),
      ],
    );
  }

  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Order',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this order?',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: reasonCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Reason (optional)',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep Order',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel Order',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final reason = reasonCtrl.text.trim().isEmpty
          ? null
          : reasonCtrl.text.trim();
      final success = await ref
          .read(orderViewModelProvider.notifier)
          .cancelOrder(orderId, reason);
      if (context.mounted) {
        if (success) {
          SnackbarUtils.showSuccess(context, 'Order cancelled.');
          ref.invalidate(_orderDetailProvider(orderId));
        } else {
          SnackbarUtils.showError(
            context,
            ref.read(orderViewModelProvider).errorMessage ??
                'Failed to cancel order.',
          );
        }
      }
    }
  }

  static String _shortId(String id) =>
      '#${id.length > 8 ? id.substring(id.length - 8).toUpperCase() : id.toUpperCase()}';

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _fmtDateTime(DateTime d) =>
      '${_fmtDate(d)} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _paymentLabel(String s) => switch (s) {
    'PENDING' =>
      _receiptSubmitted ? 'Pending Verification' : 'Awaiting payment',
    'VERIFIED' => 'Verified',
    'FAILED' => 'Failed',
    _ => s,
  };

  Color _paymentColor(String s) => switch (s) {
    'PENDING' => Colors.orange,
    'VERIFIED' => Colors.green,
    'FAILED' => Colors.red,
    _ => Colors.grey,
  };
}

// Status banner

class _StatusBanner extends StatelessWidget {
  final OrderEntity order;
  final bool receiptSubmitted;
  final bool isTablet;

  const _StatusBanner({
    required this.order,
    required this.receiptSubmitted,
    required this.isTablet,
  });

  ({String label, String description, Color color, IconData icon}) get _info =>
      switch (order.status) {
        'PENDING' => (
          label: 'Pending',
          description: receiptSubmitted
              ? 'Receipt submitted. Awaiting store confirmation.'
              : 'Please upload your payment receipt to proceed.',
          color: Colors.orange,
          icon: Icons.hourglass_top_rounded,
        ),
        'CONFIRMED' => (
          label: 'Confirmed',
          description: 'The store has confirmed your order.',
          color: Colors.blue,
          icon: Icons.check_circle_outline_rounded,
        ),
        'READY_FOR_COLLECTION' => (
          label: 'Ready for Collection',
          description: 'Your order is ready. Visit the store.',
          color: Colors.purple,
          icon: Icons.storefront_outlined,
        ),
        'COLLECTED' => (
          label: 'Collected',
          description: 'You have collected this order.',
          color: Colors.green,
          icon: Icons.check_circle_rounded,
        ),
        'CANCELLED' => (
          label: 'Cancelled',
          description: 'This order has been cancelled.',
          color: Colors.red,
          icon: Icons.cancel_outlined,
        ),
        _ => (
          label: order.status,
          description: '',
          color: Colors.grey,
          icon: Icons.info_outline_rounded,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final i = _info;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: i.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: i.color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: i.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(i.icon, color: i.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 15 : 14,
                    color: i.color,
                  ),
                ),
                if (i.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    i.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: i.color.withOpacity(0.75),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pickup code card

class _OtpCard extends StatelessWidget {
  final String otp;
  final bool isTablet;

  const _OtpCard({required this.otp, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: otp));
        SnackbarUtils.showSuccess(context, 'OTP copied!');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.9), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'OTP',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  otp,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 30 : 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to copy · Show this OTP at the store to collect your order',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// Section card

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTablet;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isTablet,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItemEntity item;
  final bool isTablet;

  const _ItemRow({required this.item, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.productName,
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            '×${item.quantity}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 12),
          Text(
            'NPR ${item.subtotal.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom action bar

class _BottomActions extends StatelessWidget {
  final bool canPay;
  final bool canCancel;
  final bool isTablet;
  final VoidCallback onPay;
  final VoidCallback onCancel;

  const _BottomActions({
    required this.canPay,
    required this.canCancel,
    required this.isTablet,
    required this.onPay,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 16,
        12,
        isTablet ? 32 : 16,
        12 + pad,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canCancel) ...[
            Expanded(
              flex: canPay ? 1 : 2,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (canPay) const SizedBox(width: 10),
          ],
          if (canPay)
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.payment_rounded, size: 18),
                label: const Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Error view

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
