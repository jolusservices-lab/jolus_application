class PaymentReceiptModel {
  final String? id;
  final String orderId;
  final String userId;
  final double amount;
  final String receiptUrl;
  final DateTime paymentDate;
  final String status;

  PaymentReceiptModel({
    this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.receiptUrl,
    required this.paymentDate,
    this.status = 'pendiente',
  });

  factory PaymentReceiptModel.fromJson(Map<String, dynamic> json) {
    return PaymentReceiptModel(
      id: json['id']?.toString(),
      orderId: json['order_id'] ?? '',
      userId: json['user_id'] ?? '',
      amount: (json['monto'] ?? 0).toDouble(),
      receiptUrl: json['url_comprobante'] ?? '',
      paymentDate: json['fecha_pago'] != null 
          ? DateTime.parse(json['fecha_pago']) 
          : DateTime.now(),
      status: json['estado'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'user_id': userId,
      'monto': amount,
      'url_comprobante': receiptUrl,
      'fecha_pago': paymentDate.toIso8601String(),
      'estado': status,
    };
  }
}
