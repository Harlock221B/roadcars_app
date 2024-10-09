import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadcarsapp/view/screens/catalog_screen.dart';
import 'package:roadcarsapp/view/screens/home_screen.dart';
import 'package:roadcarsapp/view/screens/login_screen.dart';
import 'package:roadcarsapp/view/screens/profile_screen.dart';

class MainDrawerRoadCars extends StatefulWidget {
  const MainDrawerRoadCars({super.key});

  @override
  State<MainDrawerRoadCars> createState() => _MainDrawerRoadCarsState();
}

class _MainDrawerRoadCarsState extends State<MainDrawerRoadCars> {
  bool isLoggedIn = false;
  User? currentUser;
  String userName = 'Usuário';
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoggedIn = currentUser != null;
    });

    if (isLoggedIn && currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            userName = documentSnapshot['displayName'] ?? 'Usuário';
            profileImageUrl = documentSnapshot['profileImageUrl'];
          });
        }
      }).catchError((error) {
        print('Erro ao buscar o nome do usuário: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: GestureDetector(
              onTap: () {
                if (isLoggedIn) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Imagem da Road Cars
                      Image.network(
                        'https://roadcars.com.br/static/photos/logo/brand.png',
                        width: 80,
                      ),
                      const Spacer(),
                      // Avatar do usuário logado
                      if (isLoggedIn && currentUser != null)
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : null,
                          child: profileImageUrl == null
                              ? const Icon(Icons.person,
                                  size: 30, color: Colors.white)
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Mensagem abaixo do avatar e logo
                  if (isLoggedIn && currentUser != null) ...[
                    Text(
                      'Seja bem-vindo(a) ao app da Road Cars Consulting, $userName',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Seja bem-vindo(a) ao app da Road Cars Consulting',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/home.svg',
              color: Theme.of(context).colorScheme.primary,
              height: 22,
            ),
            title: const Text('Início'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
          ),
          ExpansionTile(
            leading: SvgPicture.asset(
              'assets/icons/car.svg',
              height: 28,
            ),
            title: const Text('Veículos'),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  children: [
                    ListTile(
                      leading: SvgPicture.asset(
                        'assets/icons/vehiclecatalog.svg',
                        height: 22,
                      ),
                      title: const Text('Catálogo de Veículos'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CatalogPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        'assets/icons/favorite.svg',
                        height: 22,
                      ),
                      title: const Text('Favoritos'),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          ListTile(
            leading: SvgPicture.asset(
              height: 25,
              isLoggedIn ? 'assets/icons/logout.svg' : 'assets/icons/login.svg',
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(isLoggedIn ? 'Logout' : 'Login'),
            onTap: () {
              if (isLoggedIn) {
                FirebaseAuth.instance.signOut();
                setState(() {
                  isLoggedIn = false;
                });
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
