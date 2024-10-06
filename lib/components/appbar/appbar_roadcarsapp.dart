import 'package:flutter/material.dart';

class MainAppBarRoadCars extends StatelessWidget
    implements PreferredSizeWidget {
  const MainAppBarRoadCars({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Image.network(
        'https://roadcars.com.br/static/photos/logo/brand.png',
        width: 100,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(56.0);
}
