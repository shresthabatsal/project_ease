import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/features/dashboard/presentation/order_confirmation_screen.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/presentation/state/order_state.dart';
import 'package:project_ease/features/order/presentation/view_model/order_view_model.dart';

class ReceiptUploadScreen extends ConsumerStatefulWidget {
  final OrderEntity order;

  const ReceiptUploadScreen({super.key, required this.order});

  @override
  ConsumerState<ReceiptUploadScreen> createState() =>
      _ReceiptUploadScreenState();
}

class _ReceiptUploadScreenState extends ConsumerState<ReceiptUploadScreen> {
  File? _receiptImage;
  final _notesController = TextEditingController();
  String? _selectedPaymentMethod;
  String? _imageError;

  static const _paymentMethods = [
    'eSewa',
    'Khalti',
    'Bank Transfer',
    'Cash Deposit',
    'Other',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _receiptImage = File(picked.path);
        _imageError = null;
      });
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              title: const Text(
                'Take a photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReceipt() async {
    if (_receiptImage == null) {
      setState(() => _imageError = 'Please upload your payment receipt');
      return;
    }

    final success = await ref
        .read(orderViewModelProvider.notifier)
        .submitReceipt(
          orderId: widget.order.orderId,
          receiptImagePath: _receiptImage!.path,
          paymentMethod: _selectedPaymentMethod,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(order: widget.order),
        ),
      );
    } else {
      final error = ref.read(orderViewModelProvider).errorMessage;
      SnackbarUtils.showError(
        context,
        error ?? 'Failed to submit receipt. Please try again.',
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
        automaticallyImplyLeading: false,
        title: Text(
          'Submit Payment Receipt',
          style: TextStyle(
            fontSize: isTablet ? 20 : 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 32 : 16,
              12,
              isTablet ? 32 : 16,
              100 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order info card
                _InfoCard(order: widget.order, isTablet: isTablet),
                const SizedBox(height: 20),

                // Receipt image upload
                _SectionLabel(label: 'Payment Receipt', isTablet: isTablet),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    width: double.infinity,
                    height: isTablet ? 240 : 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _imageError != null
                            ? Colors.red.shade300
                            : _receiptImage != null
                            ? AppColors.primary.withOpacity(0.4)
                            : Colors.grey.shade200,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _receiptImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _receiptImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: _showImageSourceSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Change',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file_outlined,
                                size: 48,
                                color: _imageError != null
                                    ? Colors.red.shade300
                                    : Colors.grey.shade300,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tap to upload receipt',
                                style: TextStyle(
                                  fontSize: isTablet ? 15 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: _imageError != null
                                      ? Colors.red.shade400
                                      : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Photo or screenshot of payment',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_imageError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _imageError!,
                    style: TextStyle(fontSize: 12, color: Colors.red.shade400),
                  ),
                ],

                const SizedBox(height: 20),

                // Payment method
                _SectionLabel(
                  label: 'Payment Method (optional)',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _paymentMethods.map((method) {
                    final selected = _selectedPaymentMethod == method;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedPaymentMethod = selected ? null : method;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          method,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Notes
                _SectionLabel(
                  label: 'Payment Notes (optional)',
                  isTablet: isTablet,
                ),
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
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Transaction ID, sender name...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: isTablet ? 14 : 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Submit button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 32 : 16,
                14,
                isTablet ? 32 : 16,
                14 + MediaQuery.of(context).padding.bottom,
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
                  onPressed: isLoading ? null : _submitReceipt,
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
                          'Submit Receipt',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final OrderEntity order;
  final bool isTablet;
  const _InfoCard({required this.order, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          _InfoRow(
            label: 'Order ID',
            value: '#${order.otp}',
            isTablet: isTablet,
            valueColor: AppColors.primary,
          ),
          const Divider(height: 16, color: Color(0xFFEEEEEE)),
          _InfoRow(
            label: 'Amount to Pay',
            value: 'NPR ${order.totalAmount.toStringAsFixed(0)}',
            isTablet: isTablet,
            valueBold: true,
          ),
          const Divider(height: 16, color: Color(0xFFEEEEEE)),
          _InfoRow(
            label: 'Pickup',
            value: '${_formatDate(order.pickupDate)} at ${order.pickupTime}',
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTablet;
  final Color? valueColor;
  final bool valueBold;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isTablet,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isTablet;
  const _SectionLabel({required this.label, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: isTablet ? 15 : 13,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
        letterSpacing: 0.3,
      ),
    );
  }
}
