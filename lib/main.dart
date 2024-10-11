import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadcarsapp/view/screens/cars/catalog_screen.dart';
import 'package:roadcarsapp/view/screens/users/login_screen.dart';
import 'package:roadcarsapp/view/screens/users/profile_screen.dart';
import 'package:roadcarsapp/view/screens/home_screen.dart';
import 'package:roadcarsapp/firebase_options.dart';

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
  final int _currentIndex = 0;
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
