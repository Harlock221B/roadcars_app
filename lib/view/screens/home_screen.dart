import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadcarsapp/components/vehicle/vehicle_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadcarsapp/view/screens/users/login_screen.dart';
import 'package:roadcarsapp/view/screens/users/profile_screen.dart';
import 'package:roadcarsapp/data/utils.dart';
import 'package:roadcarsapp/components/drawer/drawer_roadcarsapp.dart'; // Importação do drawer

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoadCars'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      drawer: const MainDrawerRoadCars(), // Adicionando o drawer
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return const LoggedInView();
          } else {
            return const LoggedOutView();
          }
        },
      ),
    );
  }
}

class LoggedInView extends StatefulWidget {
  const LoggedInView({super.key});

  @override
  _LoggedInViewState createState() => _LoggedInViewState();
}

class _LoggedInViewState extends State<LoggedInView> {
  String selectedStatus = 'Todos'; // Opção de filtro por status

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bem-vindo de volta!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: selectedStatus,
            items: ['Todos', 'Disponível', 'Vendido'].map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedStatus = newValue!;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                const Text(
                  'Seus Carros Adicionados',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StreamBuilder(
                  stream: selectedStatus == 'Todos'
                      ? FirebaseFirestore.instance
                          .collection('cars')
                          .where('userId',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('cars')
                          .where('userId',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .where('status', isEqualTo: selectedStatus)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Você não adicionou nenhum carro.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                    final cars = snapshot.data?.docs ?? [];
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        final car = cars[index].data();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: VehicleCard(
                              carId: cars[index].id,
                              vehicle: {
                                'brand': car['brand'],
                                'model': car['model'],
                                'year': car['year'],
                                'price': car['price'],
                                'description': car['description'],
                                'km': car['km'],
                                'fuel': car['fuel'],
                                'transmission': car['transmission'],
                                'imageUrls': car['imageUrls'] as List<dynamic>,
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Seus Carros Favoritados',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('favorites')
                      .where('userId',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Você não tem nenhum carro favoritado.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                    final favorites = snapshot.data?.docs ?? [];
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final favorite = favorites[index].data();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: VehicleCard(
                              carId: favorite['carId'],
                              vehicle: {
                                'brand': favorite['brand'],
                                'model': favorite['model'],
                                'year': favorite['year'],
                                'price': favorite['price'],
                                'description': favorite['description'],
                                'km': favorite['km'],
                                'fuel': favorite['fuel'],
                                'transmission': favorite['transmission'],
                                'imageUrls':
                                    favorite['imageUrls'] as List<dynamic>,
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoggedOutView extends StatelessWidget {
  const LoggedOutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Bem-vindo ao RoadCars!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Faça login para acessar seus carros adicionados e favoritados.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
