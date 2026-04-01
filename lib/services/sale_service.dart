import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sale_model.dart';

class SaleService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _col => _db.collection('vendas');

  Future<void> registerSale({
    required String productId,
    required String productName,
    required double unitPrice,
    required int quantity,
  }) async {
    final total = unitPrice * quantity;
    await _col.add(
      SaleModel(
        id: '',
        productId: productId,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity,
        total: total,
        userId: _uid,
        date: DateTime.now(),
      ).toMap(),
    );
  }

  Stream<List<SaleModel>> salesStream() {
    return _col
        .where('userId', isEqualTo: _uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map(
                (d) =>
                    SaleModel.fromMap(d.data() as Map<String, dynamic>, d.id),
              )
              .toList(),
        );
  }

  // Vendas agrupadas por dia para gráfico
  Future<Map<DateTime, double>> getSalesByPeriod(int days) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final snap = await _col
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThan: Timestamp.fromDate(since))
        .get();

    final Map<DateTime, double> grouped = {};
    for (final doc in snap.docs) {
      final sale = SaleModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
      final day = DateTime(sale.date.year, sale.date.month, sale.date.day);
      grouped[day] = (grouped[day] ?? 0) + sale.total;
    }
    return grouped;
  }
}
