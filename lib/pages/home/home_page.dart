import 'package:flutter/material.dart';
import '../products/products_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductsPage()),
            );
          },
          child: const Text('Ir para Produtos'),
        ),
      ),
    );
  }
}
