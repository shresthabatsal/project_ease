class PaymentEntity {
  final String paymentId;
  final String orderId;
  final String status; // PENDING | VERIFIED | FAILED
  final String? receiptUrl;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;

  const PaymentEntity({
    required this.paymentId,
    required this.orderId,
    required this.status,
    this.receiptUrl,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
  });
}
