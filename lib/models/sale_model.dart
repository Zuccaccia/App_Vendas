import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  final String id;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double total;
  final String userId;
  final DateTime date;

  SaleModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.total,
    required this.userId,
    required this.date,
  });

  factory SaleModel.fromMap(Map<String, dynamic> map, String id) {
    return SaleModel(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      total: (map['total'] ?? 0).toDouble(),
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'total': total,
    'userId': userId,
    'date': Timestamp.fromDate(date),
  };
}
