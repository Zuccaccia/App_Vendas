import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products');

  // CREATE
  Future<void> addProduct(Product product) async {
    await _productsCollection.add(product.toMap());
  }

  // READ (Stream para atualizar em tempo real)
  Stream<List<Product>> getProducts() {
    return _productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // UPDATE
  Future<void> updateProduct(Product product) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  // DELETE
  Future<void> deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }
}
