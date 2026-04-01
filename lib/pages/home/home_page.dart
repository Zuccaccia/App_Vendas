import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_page.dart';
import '../products/products_page.dart';
import '../sales/register_sale_page.dart';
import '../sales/sales_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final _pages = const [
    DashboardPage(),
    ProductsPage(),
    RegisterSalePage(),
    SalesHistoryPage(),
  ];

  final _labels = ['Dashboard', 'Produtos', 'Vender', 'Histórico'];
  final _icons = [
    Icons.bar_chart_rounded,
    Icons.inventory_2_outlined,
    Icons.add_shopping_cart_rounded,
    Icons.receipt_long_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: List.generate(
            4,
            (i) => BottomNavigationBarItem(
              icon: Icon(_icons[i]),
              label: _labels[i],
            ),
          ),
        ),
      ),
    );
  }
}
