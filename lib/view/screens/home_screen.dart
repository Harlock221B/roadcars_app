import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<String> imgList = [
    '../../assets/coupe.jpg',
    '../../assets/sedan.jpeg',
    '../../assets/suv.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Road Cars'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Bem-vindo à Road Cars!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'A Road Cars é uma empresa líder no mercado de automóveis, oferecendo os melhores veículos com qualidade e segurança. Nosso compromisso é com a satisfação do cliente e a inovação constante.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            // Usando PageView em vez de CarouselSlider
            Container(
              height: 400.0,
              child: PageView.builder(
                itemCount: imgList.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Center(
                      child: Image.asset(
                        imgList[index],
                        fit: BoxFit.cover,
                        width: 1000,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
