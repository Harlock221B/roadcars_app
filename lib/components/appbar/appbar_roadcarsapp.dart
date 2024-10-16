import 'package:flutter/material.dart';

class MainAppBarRoadCars extends StatelessWidget
    implements PreferredSizeWidget {
  const MainAppBarRoadCars({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Image.asset('assets/images/roadcars.png', width: 100),
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
