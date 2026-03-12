class Product {
  final String? id;
  final String name;
  final double price;
  final int quantity;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  // Converter Product → Map (para enviar ao Firestore)
  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }

  // Converter Map → Product (quando vem do Firestore)
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }
}
