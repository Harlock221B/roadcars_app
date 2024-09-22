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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF536976), Color(0xFF292e49)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        actions: [
          // Menu de filtros
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Color.fromARGB(255, 215, 215, 214)),
            onSelected: (String value) {
              setState(() {
                selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return {'Preço', 'Nome'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice, style: const TextStyle(color: Colors.black)),
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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    // Ação ao tocar no card do veículo
                  },
                  child: Material(
                    elevation: 8,
                    child: VehicleCard(vehicle: vehicle),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
