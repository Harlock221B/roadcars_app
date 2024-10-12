import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadcarsapp/components/appbar/appbar_roadcarsapp.dart';
import 'package:roadcarsapp/components/vehicle/vehicle_card.dart';
import 'add_car_screen.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey para controlar o Scaffold
  bool vendor = false;
  String? selectedBrand;
  String? selectedModel;
  String? selectedMotor;
  String? selectedFuel;
  List<String> brands = [];
  List<String> models = [];
  List<String> motors = [];
  List<String> fuels = [];

  @override
  void initState() {
    super.initState();
    _checkIfUserIsVendor();
    _loadFilters();
  }

  Future<void> _checkIfUserIsVendor() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          vendor = userDoc['isVendor'] ?? false;
        });
      }
    }
  }

  Future<void> _loadFilters() async {
    QuerySnapshot carsSnapshot = await _firestore.collection('cars').get();

    setState(() {
      brands = carsSnapshot.docs
          .map((doc) => doc['brand'] as String)
          .toSet()
          .toList();
      models = carsSnapshot.docs
          .map((doc) => doc['model'] as String)
          .toSet()
          .toList();
      motors = carsSnapshot.docs
          .map((doc) => doc['motor'] as String)
          .toSet()
          .toList();
      fuels = carsSnapshot.docs
          .map((doc) => doc['fuel'] as String)
          .toSet()
          .toList();
    });
  }

  Stream<QuerySnapshot> _getFilteredVehicles() {
    Query query = _firestore.collection('cars');

    if (selectedBrand != null && selectedBrand!.isNotEmpty) {
      query = query.where('brand', isEqualTo: selectedBrand);
    }
    if (selectedModel != null && selectedModel!.isNotEmpty) {
      query = query.where('model', isEqualTo: selectedModel);
    }
    if (selectedMotor != null && selectedMotor!.isNotEmpty) {
      query = query.where('motor', isEqualTo: selectedMotor);
    }
    if (selectedFuel != null && selectedFuel!.isNotEmpty) {
      query = query.where('fuel', isEqualTo: selectedFuel);
    }

    return query.snapshots();
  }

  // Drawer para filtros
  Widget _buildFilterDrawer() {
    return Drawer(
      elevation: 16.0,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Filtros',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          const SizedBox(height: 10),
          _buildDropdownFilter('Marca', brands, selectedBrand, (value) {
            setState(() {
              selectedBrand = value;
            });
          }),
          const SizedBox(height: 10),
          _buildDropdownFilter('Modelo', models, selectedModel, (value) {
            setState(() {
              selectedModel = value;
            });
          }),
          const SizedBox(height: 10),
          _buildDropdownFilter('Motor', motors, selectedMotor, (value) {
            setState(() {
              selectedMotor = value;
            });
          }),
          const SizedBox(height: 10),
          _buildDropdownFilter('Combustível', fuels, selectedFuel, (value) {
            setState(() {
              selectedFuel = value;
            });
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o drawer
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                const Text('Aplicar Filtros', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                selectedBrand = null;
                selectedModel = null;
                selectedMotor = null;
                selectedFuel = null;
              });
              Navigator.pop(context); // Fecha o drawer após limpar
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Limpar Filtros', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String label, List<String> items,
      String? selectedItem, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      value: selectedItem,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Atribuindo a chave ao Scaffold
      appBar: AppBar(
        title: const Text('Catálogo de Veículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _scaffoldKey.currentState
                  ?.openEndDrawer(); // Abrindo o drawer lateral direito
            },
          ),
        ],
      ),
      endDrawer: _buildFilterDrawer(), // Menu lateral direito
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredVehicles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhum veículo encontrado'));
                }

                var vehicles = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    var vehicle = vehicles[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Material(
                        elevation: 8,
                        child: VehicleCard(
                          carId: vehicle.id,
                          vehicle: {
                            'brand': vehicle['brand'],
                            'model': vehicle['model'],
                            'year': vehicle['year'],
                            'price': vehicle['price'],
                            'km': vehicle['km'],
                            'fuel': vehicle['fuel'],
                            'motor': vehicle['motor'],
                            'transmission': vehicle['transmission'],
                            'description': vehicle['description'],
                            'imageUrls': vehicle['imageUrls'] as List<dynamic>,
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: vendor
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCarScreen()),
                );
              },
              backgroundColor: const Color(0xFF607D8B),
              elevation: 10,
              tooltip: 'Adicionar Veículo',
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
