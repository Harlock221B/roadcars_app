import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<String> imgList = [
    'https://www.automaxfiat.com.br/wp-content/uploads/2021/09/carros-compactos-fiat-argo.jpg',
    'https://forbes.com.br/wp-content/uploads/2021/04/ForbesLife_Mustang_140421_Divulgac%CC%A7ao.jpg',
    'https://media-repository-mobiauto.storage.googleapis.com/production/images/editorial/magazine/1707509541867.hyundai-creta-platinum-2022-3x4-dianteira.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Road Cars Consulting'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção de boas-vindas
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  Text(
                    'Bem-vindo à Road Cars Consulting!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Oferecemos uma vasta gama de veículos para atender a todas as suas necessidades e preferências, com confiança e excelência.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Carrossel de imagens
            Container(
              height: 250.0,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              child: PageView.builder(
                itemCount: imgList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        imgList[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Cards com informações
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                alignment: WrapAlignment.center,
                children: [
                  _buildFeatureCard(Icons.directions_car, 'Variedade',
                      'Oferecemos uma vasta gama de veículos.'),
                  _buildFeatureCard(Icons.verified, 'Confiança',
                      'Transparência e integridade em cada negociação.'),
                  _buildFeatureCard(Icons.star, 'Excelência',
                      'Superamos expectativas com veículos excepcionais.'),
                ],
              ),
            ),

            // Seção de por que escolher a Road Cars
            _buildSectionTitle('Por que Escolher a Road Cars?'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildListItem('Pesquisa Personalizada',
                      'Analisamos suas necessidades para encontrar o veículo perfeito.'),
                  _buildListItem('Negociação Transparente',
                      'Negociações justas e transparentes.'),
                  _buildListItem('Suporte Completo',
                      'Acompanhamos o processo desde a escolha até a compra.'),
                ],
              ),
            ),

            // Gráfico simples - Número de clientes satisfeitos
            _buildSectionTitle('Clientes Satisfeitos'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatisticsCard('120+', 'Carros Vendidos'),
                  _buildStatisticsCard('98%', 'Satisfação dos Clientes'),
                  _buildStatisticsCard('50+', 'Anos de Experiência'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para criar cards de destaque
  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      width: 160.0,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5.0,
        shadowColor: Colors.blueAccent.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função para criar um título de seção
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Função para criar um item de lista
  Widget _buildListItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$title\n',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
                children: [
                  TextSpan(
                    text: description,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para criar os cartões de estatísticas
  Widget _buildStatisticsCard(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
