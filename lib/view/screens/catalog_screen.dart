import 'package:flutter/material.dart';
import '../widgets/VehicleCard.dart';
import 'package:roadcarsapp/data/vehicles.dart';

// Página Catálogo com lista de veículos
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String selectedFilter = 'Preço';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Catálogo de Veículos',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey, Color(0xFF292e49)],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
            ),
          ),
        ),
        actions: [
          // Menu de filtros
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onSelected: (String value) {
              setState(() {
          selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return {'Preço', 'Nome'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return VehicleCard(vehicle: vehicle);
            },
          ),
        ),
      ),
    );
  }
}
