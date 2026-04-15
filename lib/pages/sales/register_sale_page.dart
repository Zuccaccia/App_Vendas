import 'dart:async';
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
  final _svc = SaleService();
  final _db = FirebaseFirestore.instance;
  final _qtyCtrl = TextEditingController(text: '1');

  String? _selectedId;
  List<Map<String, dynamic>> _products = [];
  bool _loading = false;
  StreamSubscription<QuerySnapshot>? _sub;

  // Busca o Map completo a partir do ID selecionado
  Map<String, dynamic>? get _product {
    if (_selectedId == null) return null;
    final found = _products.where((p) => p['id'] == _selectedId);
    return found.isEmpty ? null : found.first;
  }

  @override
  void initState() {
    super.initState();
    // Stream em tempo real dos produtos
    _sub = _db.collection('produtos').snapshots().listen((snap) {
      if (!mounted) return;
      setState(() {
        _products = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        // Limpa seleção se produto foi deletado
        if (_selectedId != null &&
            !_products.any((p) => p['id'] == _selectedId)) {
          _selectedId = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sell() async {
    final p = _product;
    if (p == null) {
      _snack('Selecione um produto.');
      return;
    }
    final qty = int.tryParse(_qtyCtrl.text);
    if (qty == null || qty <= 0) {
      _snack('Quantidade inválida.');
      return;
    }
    final stock = p['quantity'] as int? ?? 0;
    if (qty > stock) {
      _snack('Estoque insuficiente. Disponível: $stock');
      return;
    }

    setState(() => _loading = true);
    try {
      await _svc.registerSale(
        productId: p['id'] as String,
        productName: p['name'] as String,
        unitPrice: (p['price'] as num).toDouble(),
        quantity: qty,
      );
      _snack('Venda registrada!', success: true);
      setState(() {
        _selectedId = null;
        _qtyCtrl.text = '1';
      });
    } catch (e) {
      _snack('Erro: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _snack(String msg, {bool success = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: success ? AppTheme.accent : AppTheme.accentRed,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = _product;
    final price = (p?['price'] as num?)?.toDouble() ?? 0.0;
    final stock = p?['quantity'] as int? ?? 0;
    final qty = int.tryParse(_qtyCtrl.text) ?? 1;
    final total = price * qty;

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Venda')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Produto',
            style: TextStyle(
              color: AppTheme.textSec,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedId != null
                    ? AppTheme.accent.withValues(alpha: 0.5)
                    : AppTheme.border,
              ),
            ),
            child: _products.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Nenhum produto cadastrado',
                      style: TextStyle(color: AppTheme.textSec),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedId,
                      isExpanded: true,
                      dropdownColor: AppTheme.card,
                      hint: const Text(
                        'Selecione um produto',
                        style: TextStyle(color: AppTheme.textSec),
                      ),
                      items: _products.map((p) {
                        final s = p['quantity'] as int? ?? 0;
                        return DropdownMenuItem<String>(
                          value: p['id'] as String,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                p['name'] as String? ?? '',
                                style: const TextStyle(
                                  color: AppTheme.textPrim,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      s > 0
                                            ? AppTheme.accent.withValues(
                                                alpha: 0.1,
                                              )
                                            : AppTheme.accentRed
                                        ..withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Estoque: $s',
                                  style: TextStyle(
                                    color: s > 0
                                        ? AppTheme.accent
                                        : AppTheme.accentRed,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (id) => setState(() {
                        _selectedId = id;
                        _qtyCtrl.text = '1';
                      }),
                    ),
                  ),
          ),
          if (p != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.sell_outlined,
                        color: AppTheme.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'R\$ ${price.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppTheme.textSec),
                      ),
                    ],
                  ),
                  Text(
                    'Estoque: $stock',
                    style: TextStyle(
                      color: stock > 0 ? AppTheme.accent : AppTheme.accentRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Quantidade',
            style: TextStyle(
              color: AppTheme.textSec,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
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
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              _qtyBtn(Icons.add, () {
                final v = int.tryParse(_qtyCtrl.text) ?? 1;
                setState(() => _qtyCtrl.text = '${v + 1}');
              }),
            ],
          ),
          if (p != null) ...[
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: AppTheme.textSec, fontSize: 15),
                  ),
                  Text(
                    'R\$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  )
                : ElevatedButton.icon(
                    onPressed: p != null ? _sell : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirmar Venda'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback fn) => GestureDetector(
    onTap: fn,
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
