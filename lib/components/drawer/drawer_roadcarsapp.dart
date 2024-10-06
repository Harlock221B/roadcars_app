import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roadcarsapp/view/screens/catalog_screen.dart';
import 'package:roadcarsapp/view/screens/home_screen.dart';
import 'package:roadcarsapp/view/screens/login_screen.dart';

class MainDrawerRoadCars extends StatefulWidget {
  const MainDrawerRoadCars({super.key});

  @override
  State<MainDrawerRoadCars> createState() => _MainDrawerRoadCarsState();
}

class _MainDrawerRoadCarsState extends State<MainDrawerRoadCars> {
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://roadcars.com.br/static/photos/logo/brand.png',
                  width: 100,
                ),
                const SizedBox(height: 25),
                Text(
                  'Seja bem-vindo(a) ao app da Road Cars Consulting',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
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
            trailing: const Icon(Icons.expand_more_outlined),
            shape: Border.all(style: BorderStyle.none),
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
                      onTap: () async {
                        Navigator.pop(context);
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
                // Logout
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
              // setState(() {
              //   isLoggedIn = !isLoggedIn;
              // });
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
