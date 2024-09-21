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
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de boas-vindas
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.blueAccent,
              width: double.infinity,
              child: const Text(
                'Bem-vindo à Roadcars',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Descrição da empresa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Nós oferecemos uma vasta gama de carros novos e seminovos, '
                'com qualidade garantida e preços acessíveis. '
                'Encontre o veículo ideal para você com facilidade e segurança.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),

            // Tipos de carros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Tipos de Carros Disponíveis:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Cards com categorias de carros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildCarCategoryCard(
                    icon: Icons.directions_car_filled,
                    title: 'Carros Novos',
                    description:
                        'Últimos lançamentos do mercado, zero quilômetro.',
                  ),
                  const SizedBox(height: 10),
                  _buildCarCategoryCard(
                    icon: Icons.car_rental,
                    title: 'Carros Seminovos',
                    description:
                        'Veículos com baixa quilometragem e ótimo estado.',
                  ),
                  const SizedBox(height: 10),
                  _buildCarCategoryCard(
                    icon: Icons.electric_car,
                    title: 'Carros Elétricos',
                    description: 'Sustentabilidade e tecnologia de ponta.',
                  ),
                  const SizedBox(height: 10),
                  _buildCarCategoryCard(
                    icon: Icons.sports_motorsports,
                    title: 'Carros Esportivos',
                    description:
                        'Desempenho e estilo para os amantes da velocidade.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Seção final - informações adicionais
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.blueAccent.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Por que escolher a Roadcars?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Qualidade garantida em todos os veículos\n'
                    '• Atendimento personalizado\n'
                    '• Financiamento acessível\n'
                    '• Suporte ao cliente 24/7',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
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

  // Widget para criar cada card de categoria de carro
  Widget _buildCarCategoryCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
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
    );
  }
}
