import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';
import 'package:project_ease/features/dashboard/presentation/receipt_upload_screen.dart';
import 'package:project_ease/features/order/presentation/state/order_state.dart';
import 'package:project_ease/features/order/presentation/view_model/order_view_model.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String storeId;
  final String? storeName;
  final List<CartItemEntity> items;
  final double total;
  final bool isBuyNow;
  final ProductEntity? buyNowProduct;
  final int? buyNowQuantity;

  const CheckoutScreen({
    super.key,
    required this.storeId,
    this.storeName,
    required this.items,
    required this.total,
    required this.isBuyNow,
    this.buyNowProduct,
    this.buyNowQuantity,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _notesController = TextEditingController();
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  String? _dateError;
  String? _timeError;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String get _formattedDate {
    if (_pickupDate == null) return 'Select date';
    final d = _pickupDate!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get _formattedTime {
    if (_pickupTime == null) return 'Select time';
    final h = _pickupTime!.hour.toString().padLeft(2, '0');
    final m = _pickupTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _pickupDateISO {
    final d = _pickupDate!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get _pickupTimeHHMM {
    final h = _pickupTime!.hour.toString().padLeft(2, '0');
    final m = _pickupTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _pickupDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _pickupTime = picked;
        _timeError = null;
      });
    }
  }

  bool _validate() {
    setState(() {
      _dateError = _pickupDate == null ? 'Please select a pickup date' : null;
      _timeError = _pickupTime == null ? 'Please select a pickup time' : null;
    });
    return _pickupDate != null && _pickupTime != null;
  }

  Future<void> _placeOrder() async {
    if (!_validate()) return;

    final vm = ref.read(orderViewModelProvider.notifier);
    bool success;

    if (widget.isBuyNow) {
      success = await vm.buyNow(
        productId: widget.buyNowProduct!.productId,
        quantity: widget.buyNowQuantity!,
        storeId: widget.storeId,
        pickupDate: _pickupDateISO,
        pickupTime: _pickupTimeHHMM,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      success = await vm.createOrder(
        storeId: widget.storeId,
        pickupDate: _pickupDateISO,
        pickupTime: _pickupTimeHHMM,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      final order = ref.read(orderViewModelProvider).currentOrder!;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ReceiptUploadScreen(order: order)),
      );
    } else {
      final error = ref.read(orderViewModelProvider).errorMessage;
      SnackbarUtils.showError(
        context,
        error ?? 'Failed to place order. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final orderState = ref.watch(orderViewModelProvider);
    final isLoading = orderState.status == OrderStatus.loading;

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
          'Checkout',
          style: TextStyle(
            fontSize: isTablet ? 20 : 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          isTablet ? 32 : 16,
          14,
          isTablet ? 32 : 16,
          14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: isTablet ? 54 : 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Place Order — NPR ${widget.total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isTablet ? 32 : 16,
          12,
          isTablet ? 32 : 16,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store
            if (widget.storeName != null) ...[
              _SectionCard(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Store',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.storeName!,
                              style: TextStyle(
                                fontSize: isTablet ? 15 : 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Order Summary
            _SectionLabel(label: 'Order Summary', isTablet: isTablet),
            const SizedBox(height: 8),
            _SectionCard(
              children: [
                ...widget.items.map(
                  (item) => _OrderItemRow(item: item, isTablet: isTablet),
                ),
                const Divider(height: 20, color: Color(0xFFEEEEEE)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'NPR ${widget.total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Pickup Details
            _SectionLabel(label: 'Pickup Details', isTablet: isTablet),
            const SizedBox(height: 8),
            _SectionCard(
              children: [
                _PickerRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Pickup Date',
                  value: _formattedDate,
                  hasValue: _pickupDate != null,
                  error: _dateError,
                  isTablet: isTablet,
                  onTap: _selectDate,
                ),
                const Divider(height: 20, color: Color(0xFFEEEEEE)),
                _PickerRow(
                  icon: Icons.access_time_rounded,
                  label: 'Pickup Time',
                  value: _formattedTime,
                  hasValue: _pickupTime != null,
                  error: _timeError,
                  isTablet: isTablet,
                  onTap: _selectTime,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Notes
            _SectionLabel(label: 'Order Notes (optional)', isTablet: isTablet),
            const SizedBox(height: 8),
            Container(
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
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 500,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Any special instructions...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: isTablet ? 14 : 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Payment info note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "After placing the order, you'll be asked to upload your payment receipt. Your order will be confirmed once payment is verified.",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helpers
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isTablet;
  const _SectionLabel({required this.label, required this.isTablet});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: isTablet ? 15 : 13,
      fontWeight: FontWeight.w700,
      color: Colors.black54,
      letterSpacing: 0.3,
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
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
      children: children,
    ),
  );
}

class _OrderItemRow extends StatelessWidget {
  final CartItemEntity item;
  final bool isTablet;
  const _OrderItemRow({required this.item, required this.isTablet});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            item.product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '×${item.quantity}',
          style: TextStyle(
            fontSize: isTablet ? 13 : 12,
            color: Colors.grey.shade500,
          ),
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

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool hasValue;
  final String? error;
  final bool isTablet;
  final VoidCallback onTap;

  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.hasValue,
    required this.error,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: error != null
                  ? Colors.red.shade400
                  : hasValue
                  ? AppColors.primary
                  : Colors.grey.shade400,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: hasValue ? Colors.black87 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
      if (error != null) ...[
        const SizedBox(height: 4),
        Text(
          error!,
          style: TextStyle(fontSize: 11, color: Colors.red.shade400),
        ),
      ],
    ],
  );
}
