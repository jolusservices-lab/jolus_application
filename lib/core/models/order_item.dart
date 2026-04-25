import 'cart_item.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'products': products.map((p) => p.toJson()).toList(),
    'dateTime': dateTime.toIso8601String(),
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    amount: json['amount'],
    products: (json['products'] as List).map((p) => CartItem.fromJson(p)).toList(),
    dateTime: DateTime.parse(json['dateTime']),
  );
}
