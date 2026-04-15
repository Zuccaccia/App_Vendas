import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sale_model.dart';

class SaleService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _col => _db.collection('vendas');

  // Registra venda e decrementa estoque em batch atômico
  Future<void> registerSale({
    required String productId,
    required String productName,
    required double unitPrice,
    required int quantity,
  }) async {
    final batch = _db.batch();
    final saleRef = _col.doc();

    batch.set(
      saleRef,
      SaleModel(
        id: '',
        productId: productId,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity,
        total: unitPrice * quantity,
        userId: _uid,
        date: DateTime.now(),
      ).toMap(),
    );

    batch.update(_db.collection('produtos').doc(productId), {
      'quantity': FieldValue.increment(-quantity),
    });

    await batch.commit();
  }

  // Todas as vendas do usuário, ordenadas por data
  Stream<List<SaleModel>> salesStream() => _col
      .where('userId', isEqualTo: _uid)
      .orderBy('date', descending: true)
      .snapshots()
      .map(
        (s) => s.docs
            .map(
              (d) => SaleModel.fromMap(d.data() as Map<String, dynamic>, d.id),
            )
            .toList(),
      );

  // Receita do mês
  Stream<double> monthlyRevenueStream() {
    final start = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return _col
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .snapshots()
        .map(
          (s) => s.docs.fold(
            0.0,
            (acc, d) => acc + ((d.data() as Map)['total'] ?? 0).toDouble(),
          ),
        );
  }

  Stream<int> todaySalesStream() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return _col
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .snapshots()
        .map((s) => s.docs.length);
  }

  // Top produtos do mês por quantidade vendida
  Stream<List<Map<String, dynamic>>> topProductsStream() {
    final start = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return _col
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .snapshots()
        .map((s) {
          final Map<String, Map<String, dynamic>> g = {};
          for (final doc in s.docs) {
            final d = doc.data() as Map<String, dynamic>;
            final pid = d['productId'] as String? ?? '';
            g.putIfAbsent(
              pid,
              () => {
                'productName': d['productName'] ?? '',
                'quantity': 0,
                'total': 0.0,
              },
            );
            g[pid]!['quantity'] =
                (g[pid]!['quantity'] as int) + (d['quantity'] as int? ?? 1);
            g[pid]!['total'] =
                (g[pid]!['total'] as double) + (d['total'] as double? ?? 0.0);
          }
          return (g.values.toList()..sort(
                (a, b) =>
                    (b['quantity'] as int).compareTo(a['quantity'] as int),
              ))
              .take(5)
              .toList();
        });
  }

  // Dados do gráfico por período — tempo real
  Stream<Map<DateTime, double>> chartStream(int days) {
    final since = DateTime.now().subtract(Duration(days: days));
    return _col
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThan: Timestamp.fromDate(since))
        .snapshots()
        .map((snap) {
          final Map<DateTime, double> grouped = {};
          for (final doc in snap.docs) {
            final sale = SaleModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
            final day = DateTime(
              sale.date.year,
              sale.date.month,
              sale.date.day,
            );
            grouped[day] = (grouped[day] ?? 0) + sale.total;
          }
          return grouped;
        });
  }
}
