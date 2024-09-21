import 'package:flutter/material.dart';
// Página Catálogo

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Catálogo de Carros',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}