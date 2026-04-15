import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../models/sale_model.dart';
import '../../services/auth_service.dart';
import '../../services/sale_service.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vendas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => AuthService().logout(),
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.accent,
            indicatorWeight: 2,
            labelColor: AppTheme.accent,
            unselectedLabelColor: AppTheme.textSec,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.bar_chart_rounded, size: 18),
                text: 'Gráfico',
              ),
              Tab(
                icon: Icon(Icons.receipt_long_outlined, size: 18),
                text: 'Histórico',
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_ChartTab(), _HistoryTab()]),
      ),
    );
  }
}

// ── Aba Gráfico ───────────────────────────────────────────────────

class _ChartTab extends StatefulWidget {
  const _ChartTab();
  @override
  State<_ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<_ChartTab> {
  final _svc = SaleService();
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<DateTime, double>>(
      stream: _svc.chartStream(_days),
      builder: (context, snap) {
        final data = snap.data ?? {};
        final total = data.values.fold(0.0, (a, b) => a + b);
        final sorted = data.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Text(
                  'Período',
                  style: TextStyle(
                    color: AppTheme.textSec,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ...[7, 30, 90].map(
                  (d) => _chip(
                    d,
                    d == 7
                        ? '7d'
                        : d == 30
                        ? '30d'
                        : '90d',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _kpiCard(
                  'Total período',
                  _currency.format(total),
                  Icons.attach_money,
                  AppTheme.accent,
                ),
                const SizedBox(width: 12),
                _kpiCard(
                  'Dias c/ vendas',
                  '${data.length}',
                  Icons.calendar_today_outlined,
                  Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: data.isEmpty
                  ? const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'Nenhuma venda no período',
                          style: TextStyle(color: AppTheme.textSec),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: sorted
                              .asMap()
                              .entries
                              .map(
                                (e) => BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value.value,
                                      color: AppTheme.accent,
                                      width: 14,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) =>
                                FlLine(color: AppTheme.border, strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 64,
                                getTitlesWidget: (v, _) => Text(
                                  _currency.format(v),
                                  style: const TextStyle(
                                    color: AppTheme.textSec,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  final i = v.toInt();
                                  if (i >= sorted.length) {
                                    return const SizedBox();
                                  }
                                  return Text(
                                    DateFormat('dd/MM').format(sorted[i].key),
                                    style: const TextStyle(
                                      color: AppTheme.textSec,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => AppTheme.accent,
                              getTooltipItem: (_, _, rod, _) => BarTooltipItem(
                                _currency.format(rod.toY),
                                const TextStyle(
                                  color: AppTheme.bg,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _chip(int days, String label) {
    final sel = _days == days;
    return GestureDetector(
      onTap: () => setState(() => _days = days),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? AppTheme.accent : AppTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel ? AppTheme.bg : AppTheme.textSec,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
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
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
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
        ),
      );
}

// ── Aba Histórico ─────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final svc = SaleService();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return StreamBuilder<List<SaleModel>>(
      stream: svc.salesStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }
        final sales = snap.data ?? [];
        if (sales.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: AppTheme.textSec,
                  size: 56,
                ),
                SizedBox(height: 12),
                Text(
                  'Nenhuma venda registrada',
                  style: TextStyle(color: AppTheme.textSec),
                ),
              ],
            ),
          );
        }

        final total = sales.fold<double>(0, (a, b) => a + b.total);

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total geral',
                        style: TextStyle(color: AppTheme.textSec, fontSize: 12),
                      ),
                      Text(
                        currency.format(total),
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent..withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${sales.length} vendas',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sales.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final s = sales[i];
                  return Container(
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
                            color: AppTheme.accent.withValues(alpha: 0.1),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.productName,
                                style: const TextStyle(
                                  color: AppTheme.textPrim,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${s.quantity}x ${currency.format(s.unitPrice)}  •  ${DateFormat('dd/MM/yy  HH:mm').format(s.date)}',
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
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
