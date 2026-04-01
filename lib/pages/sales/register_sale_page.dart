import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../../services/sale_service.dart';

class RegisterSalePage extends StatefulWidget {
  const RegisterSalePage({super.key});
  @override
  State<RegisterSalePage> createState() => _RegisterSalePageState();
}

class _RegisterSalePageState extends State<RegisterSalePage> {
  final _saleService = SaleService();
  final _db = FirebaseFirestore.instance;
  final _qtyCtrl = TextEditingController(text: '1');

  Map<String, dynamic>? _selectedProduct;
  List<Map<String, dynamic>> _products = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final snap = await _db.collection('produtos').get();
    setState(() {
      _products = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    });
  }

  Future<void> _sell() async {
    if (_selectedProduct == null) {
      _snack('Selecione um produto.');
      return;
    }
    final qty = int.tryParse(_qtyCtrl.text);
    if (qty == null || qty <= 0) {
      _snack('Quantidade inválida.');
      return;
    }

    setState(() => _loading = true);
    try {
      await _saleService.registerSale(
        productId: _selectedProduct!['id'],
        productName: _selectedProduct!['name'] ?? '',
        unitPrice: (_selectedProduct!['price'] ?? 0).toDouble(),
        quantity: qty,
      );
      _snack('Venda registrada!', success: true);
      setState(() {
        _selectedProduct = null;
        _qtyCtrl.text = '1';
      });
    } catch (e) {
      _snack('Erro ao registrar venda.');
    }
    setState(() => _loading = false);
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppTheme.accent : AppTheme.accentRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = (_selectedProduct?['price'] ?? 0).toDouble();
    final qty = int.tryParse(_qtyCtrl.text) ?? 1;
    final total = price * qty;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Venda')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Produto',
            style: TextStyle(color: AppTheme.textSec, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButton<Map<String, dynamic>>(
              value: _selectedProduct,
              isExpanded: true,
              dropdownColor: AppTheme.card,
              underline: const SizedBox(),
              hint: const Text(
                'Selecione o produto',
                style: TextStyle(color: AppTheme.textSec),
              ),
              items: _products
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        p['name'] ?? p['id'],
                        style: const TextStyle(color: AppTheme.textPrim),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (p) => setState(() => _selectedProduct = p),
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedProduct != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sell_outlined,
                    color: AppTheme.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Preço unitário: R\$ ${price.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppTheme.textSec),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'Quantidade',
            style: TextStyle(color: AppTheme.textSec, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _qtyBtn(Icons.remove, () {
                final v = int.tryParse(_qtyCtrl.text) ?? 1;
                if (v > 1) setState(() => _qtyCtrl.text = '${v - 1}');
              }),
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppTheme.textPrim,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(),
                ),
              ),
              _qtyBtn(Icons.add, () {
                final v = int.tryParse(_qtyCtrl.text) ?? 1;
                setState(() => _qtyCtrl.text = '${v + 1}');
              }),
            ],
          ),
          const SizedBox(height: 28),
          if (_selectedProduct != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: AppTheme.textSec, fontSize: 16),
                  ),
                  Text(
                    'R\$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  )
                : ElevatedButton.icon(
                    onPressed: _sell,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirmar Venda'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.accent),
      ),
    );
  }
}
