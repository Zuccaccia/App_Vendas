import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../models/sale_model.dart';
import 'package:app_vendas/services/sale_service.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const _months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  static const _days = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];
  static const _rankColors = [
    Color(0xFFFFD700),
    Color(0xFFC0C0C0),
    Color(0xFFCD7F32),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = (user?.email ?? 'usuário').split('@').first;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final svc = SaleService();
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            children: [
              // ── Cabeçalho ─────────────────────────────
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppTheme.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Olá,',
                        style: TextStyle(color: AppTheme.textSec, fontSize: 12),
                      ),
                      Text(
                        username,
                        style: const TextStyle(
                          color: AppTheme.textPrim,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _days[now.weekday - 1],
                        style: const TextStyle(
                          color: AppTheme.textSec,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(now),
                        style: const TextStyle(
                          color: AppTheme.textPrim,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Card receita mensal ────────────────────
              StreamBuilder<double>(
                stream: svc.monthlyRevenueStream(),
                builder: (context, snap) {
                  final revenue = snap.data ?? 0.0;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Receita de ${_months[now.month - 1]}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            snap.connectionState == ConnectionState.waiting
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currency.format(revenue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Total em vendas no mês',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // ── Mini cards ────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: svc.todaySalesStream(),
                      builder: (context, snap) => _miniCard(
                        icon: Icons.today_outlined,
                        label: 'Vendas hoje',
                        value: '${snap.data ?? 0}',
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StreamBuilder<List<SaleModel>>(
                      stream: svc.salesStream(),
                      builder: (context, snap) => _miniCard(
                        icon: Icons.receipt_long_outlined,
                        label: 'Total vendas',
                        value: '${snap.data?.length ?? 0}',
                        color: const Color(0xFF9B59B6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // ── Top produtos ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top produtos do mês',
                    style: TextStyle(
                      color: AppTheme.textPrim,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _months[now.month - 1],
                    style: const TextStyle(
                      color: AppTheme.textSec,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: svc.topProductsStream(),
                builder: (context, snap) {
                  final tops = snap.data ?? [];
                  if (tops.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Center(
                        child: Text(
                          'Nenhuma venda este mês',
                          style: TextStyle(color: AppTheme.textSec),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: tops.asMap().entries.map((e) {
                      final rank = e.key;
                      final item = e.value;
                      final rankColor = rank < 3
                          ? _rankColors[rank]
                          : AppTheme.textSec;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: rank == 0
                                ? AppTheme.accent.withValues(alpha: 0.25)
                                : AppTheme.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: rankColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '#${rank + 1}',
                                  style: TextStyle(
                                    color: rankColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['productName'] as String? ?? '',
                                    style: const TextStyle(
                                      color: AppTheme.textPrim,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item['quantity']} unidades',
                                    style: const TextStyle(
                                      color: AppTheme.textSec,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currency.format(item['total']),
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 26),

              // ── Últimas vendas ────────────────────────
              const Text(
                'Últimas vendas',
                style: TextStyle(
                  color: AppTheme.textPrim,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<SaleModel>>(
                stream: svc.salesStream(),
                builder: (context, snap) {
                  final sales = (snap.data ?? []).take(5).toList();
                  if (sales.isEmpty) {
                    return const Text(
                      'Nenhuma venda ainda.',
                      style: TextStyle(color: AppTheme.textSec),
                    );
                  }
                  return Column(
                    children: sales
                        .map(
                          (s) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: AppTheme.accent,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.productName,
                                        style: const TextStyle(
                                          color: AppTheme.textPrim,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${s.quantity}x  •  ${DateFormat('dd/MM  HH:mm').format(s.date)}',
                                        style: const TextStyle(
                                          color: AppTheme.textSec,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  currency.format(s.total),
                                  style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSec, fontSize: 11),
        ),
      ],
    ),
  );
}
