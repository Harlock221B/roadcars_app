import 'package:flutter/material.dart';
import './view/screens/login_screen.dart'; // Importando a tela de login
import './view/screens/catalog_screen.dart'; // Importando a tela de catálogo
import './view/screens/home_screen.dart'; // Importando a tela home

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roadcars',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Colors.black,
          secondary: Colors.white,
          surface: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Lista de páginas
  final List<Widget> _pages = [
    HomeScreen(),
    const CatalogPage(),
    LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Roadcars',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: _pages[_currentIndex], // Exibe a página com base no índice selecionado
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          ),
        ],
      ),
    );
  }
}
