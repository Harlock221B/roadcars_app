import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadcarsapp/components/appbar/appbar_roadcarsapp.dart';
import 'package:roadcarsapp/components/vehicle/vehicle_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadcarsapp/view/screens/users/login_screen.dart';
import 'package:roadcarsapp/components/drawer/drawer_roadcarsapp.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBarRoadCars(),
      drawer: const MainDrawerRoadCars(),
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
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final cars = snapshot.data!.docs;
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
                                'armored': car['armored'],
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
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Erro ao carregar favoritos.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                        child: Text(
                          'Você não tem nenhum carro favoritado.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final List<dynamic> favoritedCars =
                        userData['favoritedCars'] ?? [];

                    if (favoritedCars.isEmpty) {
                      return const Center(
                        child: Text(
                          'Você não tem nenhum carro favoritado.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return FutureBuilder<List<DocumentSnapshot>>(
                      future: FirebaseFirestore.instance
                          .collection('cars')
                          .where(FieldPath.documentId, whereIn: favoritedCars)
                          .get()
                          .then((snapshot) => snapshot.docs),
                      builder: (context, carSnapshot) {
                        if (carSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (carSnapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Erro ao carregar carros favoritados.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          );
                        }
                        if (!carSnapshot.hasData || carSnapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              'Você não tem nenhum carro favoritado.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          );
                        }

                        final favoritedCarsData = carSnapshot.data!;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: favoritedCarsData.length,
                          itemBuilder: (context, index) {
                            final car = favoritedCarsData[index].data()
                                as Map<String, dynamic>;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                child: VehicleCard(
                                  carId: favoritedCarsData[index].id,
                                  vehicle: {
                                    'brand': car['brand'],
                                    'model': car['model'],
                                    'year': car['year'],
                                    'price': car['price'],
                                    'description': car['description'],
                                    'km': car['km'],
                                    'fuel': car['fuel'],
                                    'transmission': car['transmission'],
                                    'imageUrls':
                                        car['imageUrls'] as List<dynamic>,
                                  },
                                ),
                              ),
                            );
                          },
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
