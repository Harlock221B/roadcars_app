import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('../assets/images/brand/brand.png', height: 40),
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // Código para abrir o menu lateral ou drawer
              },
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Container de boas-vindas
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Bem-vindo à Road Cars Consulting',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sua solução personalizada para compra e venda de automóveis',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Explore Nossas Incríveis Opções
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Explore Nossas Incríveis Opções!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            // Card de carros esportivos
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/sports_car.jpg',
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carros Esportivos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Experimente a adrenalina da estrada com nossa seleção de carros esportivos de alta performance.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Seção "Por que Escolher a Road Cars Consulting?"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Por que Escolher a Road Cars Consulting?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'Por que Escolher a Road Cars Consulting?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Card de Variedade
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.directions_car,
                          color: Colors.blue, size: 40),
                      title: Text(
                        'Variedade',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Oferecemos uma vasta gama de veículos para atender a todas as suas necessidades e preferências.',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Card de Confiança
                  Card(
                    child: ListTile(
                      leading:
                          Icon(Icons.handshake, color: Colors.blue, size: 40),
                      title: Text(
                        'Confiança',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Nossos clientes confiam na nossa transparência e integridade em cada negociação.',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Card de Excelência
                  Card(
                    child: ListTile(
                      leading:
                          Icon(Icons.verified, color: Colors.blue, size: 40),
                      title: Text(
                        'Excelência',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Buscamos sempre superar as expectativas, oferecendo serviços de alta qualidade e veículos excepcionais.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'Como Trabalhamos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Entenda nosso processo e como garantimos a melhor experiência para nossos clientes.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Card de Pesquisa Personalizada
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.search, color: Colors.blue, size: 40),
                      title: Text(
                        'Pesquisa Personalizada',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Analisamos suas necessidades e preferências para encontrar o veículo perfeito para você.',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Card de Negociação Transparente
                  Card(
                    child: ListTile(
                      leading:
                          Icon(Icons.price_check, color: Colors.blue, size: 40),
                      title: Text(
                        'Negociação Transparente',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Oferecemos negociações justas e transparentes, garantindo que você obtenha o melhor valor.',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Card de Suporte Completo
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.build, color: Colors.blue, size: 40),
                      title: Text(
                        'Suporte Completo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Acompanhamos todo o processo, desde a escolha do carro até a finalização da compra.',
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
