import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderEntity order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Success icon
              Container(
                width: isTablet ? 100 : 84,
                height: isTablet ? 100 : 84,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green.shade500,
                  size: isTablet ? 56 : 48,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Order Placed!',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Your receipt has been submitted.\nWe\'ll confirm your order once payment is verified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              // Order details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // Pickup code
                    Text(
                      'Pickup Code',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: order.pickupCode),
                        );
                        SnackbarUtils.showSuccess(
                          context,
                          'Pickup code copied to clipboard',
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            order.pickupCode,
                            style: TextStyle(
                              fontSize: isTablet ? 26 : 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ),

                    _ConfirmRow(
                      label: 'Amount',
                      value: 'NPR ${order.totalAmount.toStringAsFixed(0)}',
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 10),
                    _ConfirmRow(
                      label: 'Pickup Date',
                      value: _formatDate(order.pickupDate),
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 10),
                    _ConfirmRow(
                      label: 'Pickup Time',
                      value: order.pickupTime,
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 10),
                    _ConfirmRow(
                      label: 'Status',
                      value: 'Awaiting verification',
                      isTablet: isTablet,
                      valueColor: Colors.orange.shade600,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info note
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Show this pickup code at the store when collecting your order.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // Done button
              SizedBox(
                width: double.infinity,
                height: isTablet ? 54 : 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTablet;
  final Color? valueColor;

  const _ConfirmRow({
    required this.label,
    required this.value,
    required this.isTablet,
    this.valueColor,
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
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
