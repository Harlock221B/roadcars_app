import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roadcars',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(), // Substituímos a HomePage original
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<String> carImages = const [
    'assets/sedan.jpg',  // Certifique-se de ter essas imagens nos assets
    'assets/suv.jpg',
    'assets/coupe.jpg',
  ];

  final List<String> carTypes = const [
    'Sedans',
    'SUVs',
    'Coupés',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roadcars'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Seção de boas-vindas e sobre a empresa
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Bem-vindo à Roadcars!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Nós oferecemos uma vasta gama de carros de qualidade para venda e revenda. '
                'Com anos de experiência no mercado, ajudamos nossos clientes a encontrar o carro ideal para suas necessidades.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            
            const SizedBox(height: 20),

            // Carrossel de carros
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Confira nossos tipos de carros:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CarouselSlider.builder(
                    itemCount: carImages.length,
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    itemBuilder: (context, index, realIdx) {
                      return Column(
                        children: [
                          Image.asset(
                            carImages[index],
                            fit: BoxFit.cover,
                            height: 150,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            carTypes[index],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Seção de mais informações
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Por que escolher a Roadcars?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Qualidade garantida em todos os veículos\n'
                    '• Atendimento personalizado\n'
                    '• Facilidades de pagamento e financiamento\n'
                    '• Ampla variedade de marcas e modelos\n'
                    '• Serviço de pós-venda e suporte ao cliente',
                    style: TextStyle(fontSize: 16),
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
