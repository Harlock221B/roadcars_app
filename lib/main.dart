import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'components/appbar/appbar_roadcarsapp.dart';
import 'firebase_options.dart';
import './view/screens/login_screen.dart';
import './view/screens/catalog_screen.dart';
import './view/screens/home_screen.dart';
import './view/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  bool _isLoading = true;

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        bool isLoggedIn = snapshot.data != null;

        final List<Widget> pages = [
          HomeScreen(),
          const CatalogPage(),
          isLoggedIn ? const ProfileScreen() : const LoginScreen(),
        ];

        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: pages[_currentIndex],
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const AddCarScreen()),
          //     );
          //   },
          //   backgroundColor: Colors.blue.shade800,
          //   elevation: 5,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: const Icon(
          //     Icons.add,
          //     size: 26,
          //     color: Colors.white,
          //   ),
          // ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          // bottomNavigationBar: BottomAppBar(
          //   shape: const CircularNotchedRectangle(),
          //   notchMargin: 4.0, // Diminuído para evitar overflow
          //   color: Colors.black,
          //   child: SizedBox(
          //     height: 56, // Diminuir a altura do BottomNavigationBar
          //     child: BottomNavigationBar(
          //       type: BottomNavigationBarType.fixed,
          //       currentIndex: _currentIndex,
          //       backgroundColor: Colors.black,
          //       selectedItemColor: Colors.blueAccent,
          //       unselectedItemColor: Colors.grey.shade400,
          //       showSelectedLabels: true,
          //       showUnselectedLabels: false,
          //       selectedLabelStyle: const TextStyle(
          //         fontWeight: FontWeight.w600,
          //         fontSize: 12,
          //       ),
          //       onTap: (index) {
          //         setState(() {
          //           _currentIndex = index;
          //         });
          //       },
          //       items: [
          //         BottomNavigationBarItem(
          //           icon: _customIcon(Icons.home, 0),
          //           label: 'Home',
          //         ),
          //         BottomNavigationBarItem(
          //           icon: _customIcon(Icons.car_rental, 1),
          //           label: 'Catálogo',
          //         ),
          //         BottomNavigationBarItem(
          //           icon: _customIcon(isLoggedIn ? Icons.person : Icons.login, 2),
          //           label: isLoggedIn ? 'Perfil' : 'Login',
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        );
      },
    );
  }

  Widget _customIcon(IconData icon, int index) {
    return Icon(
      icon,
      size: _currentIndex == index ? 27 : 24, // Reduzindo o tamanho do ícone
      color: _currentIndex == index ? Colors.blueAccent : Colors.grey.shade400,
    );
  }
}
