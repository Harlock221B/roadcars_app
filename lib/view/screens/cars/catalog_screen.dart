import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar para autenticação
import 'package:roadcarsapp/components/appbar/appbar_roadcarsapp.dart';
import 'package:roadcarsapp/components/vehicle/vehicle_card.dart';
import 'add_car_screen.dart'; // Import da tela de adicionar carros

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String selectedFilter = 'Preço';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool vendor = false; // Inicialização da condição de vendedor

  @override
  void initState() {
    super.initState();
    _checkIfUserIsVendor();
  }

  Future<void> _checkIfUserIsVendor() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Verificar se o usuário existe no Firestore e obter o status de vendedor
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          vendor = userDoc['isVendor'] ??
              false; // Assume false se o campo não existir
        });
      }
    }
  }

  Stream<QuerySnapshot> _getVehicles() {
    return _firestore.collection('cars').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBarRoadCars(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum veículo encontrado'));
          }

          var vehicles = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                var vehicle = vehicles[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Material(
                      elevation: 8,
                      child: VehicleCard(
                        carId: vehicle.id,
                        vehicle: {
                          'brand': vehicle['brand'],
                          'model': vehicle['model'],
                          'year': vehicle['year'],
                          'price': vehicle['price'],
                          'description': vehicle['description'],
                          'imageUrls': vehicle['imageUrls'] as List<dynamic>,
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      // Floating Action Button para adicionar carros (somente se for vendedor)
      floatingActionButton: vendor
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCarScreen()),
                );
              },
              backgroundColor: const Color(0xFF607D8B), // Cinza azulado
              child: const Icon(Icons.add, color: Colors.white),
              elevation: 10,
              tooltip: 'Adicionar Veículo',
            )
          : null,
    );
  }
}
