import 'package:flutter/material.dart';
import '../widgets/VehicleCard.dart';

// Página Catálogo com lista de veículos
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String selectedFilter = 'Preço';

  // Lista de veículos
  final List<Map<String, String>> vehicles = [
    {
      'image': 'https://upload.wikimedia.org/wikipedia/commons/8/8b/Ferrari_F8_Tributo_Genf_2019_1Y7A5665.jpg',
      'name': 'Ferrari F8',
      'description': 'Alta performance e design arrojado.',
      'price': 'R\$ 2,500,000',
      'details': 'O Ferrari F8 oferece uma experiência de direção de tirar o fôlego com seu motor V8 de 720 cv.'
    },
    {
      'image': 'images/carros/rr_valer-1.png',
      'name': 'Range Rover Velar',
      'description': 'Luxo e robustez em um único veículo.',
      'price': 'R\$ 750,000',
      'details': 'O Range Rover Velar combina o design contemporâneo com o luxo de um autêntico Land Rover.'
    },
    {
      'image': 'assets/sedan.jpg',
      'name': 'BMW Série 5',
      'description': 'Elegância e conforto em cada detalhe.',
      'price': 'R\$ 550,000',
      'details': 'A BMW Série 5 é a referência de luxo e tecnologia para quem busca uma condução refinada.'
    },
  ];

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
