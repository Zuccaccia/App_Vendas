import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../services/sale_service.dart';
import '../../services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _saleService = SaleService();
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  int _selectedPeriod = 7; // dias
  Map<DateTime, double> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _saleService.chartStream(_selectedPeriod).first;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  double get _totalPeriod => _data.values.fold(0, (a, b) => a + b);
  int get _totalDays => _data.keys.length;

  List<BarChartGroupData> get _bars {
    final sorted = _data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.value,
            color: AppTheme.accent,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => AuthService().logout(),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            )
          : RefreshIndicator(
              color: AppTheme.accent,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Cards de resumo
                  Row(
                    children: [
                      _summaryCard(
                        'Total no Período',
                        _currency.format(_totalPeriod),
                        Icons.attach_money,
                        AppTheme.accent,
                      ),
                      const SizedBox(width: 12),
                      _summaryCard(
                        'Dias com Vendas',
                        '$_totalDays dias',
                        Icons.calendar_today_outlined,
                        Colors.blueAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Seletor de período
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
                        (d) => _periodChip(
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

                  // Gráfico
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: _data.isEmpty
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
                                barGroups: _bars,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (_) => FlLine(
                                    color: AppTheme.border,
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 56,
                                      getTitlesWidget: (v, _) => Text(
                                        _currency.format(v),
                                        style: const TextStyle(
                                          color: AppTheme.textSec,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, _) {
                                        final sorted = _data.keys.toList()
                                          ..sort();
                                        if (v.toInt() >= sorted.length) {
                                          return const SizedBox();
                                        }
                                        return Text(
                                          DateFormat(
                                            'dd/MM',
                                          ).format(sorted[v.toInt()]),
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
                                    getTooltipItem: (group, _, rod, _) =>
                                        BarTooltipItem(
                                          _currency.format(rod.toY),
                                          const TextStyle(
                                            color: AppTheme.bg,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
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
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
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

  Widget _periodChip(int days, String label) {
    final selected = _selectedPeriod == days;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = days);
        _load();
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.bg : AppTheme.textSec,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
