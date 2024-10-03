import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final String sellerPhone = "19982032604";
    final String vehicleName = vehicle['model'] ?? 'Veículo Indefinido';
    final String whatsappUrl =
        "https://wa.me/$sellerPhone?text=Olá!%20Estou%20interessado%20no%20$vehicleName.";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          vehicleName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(), // Carrossel das imagens
                    const SizedBox(height: 20),
                    Text(
                      vehicleName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R\$ ${vehicle['price'] ?? 'Preço Indefinido'}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Ano: ${vehicle['year'] ?? 'Ano Indefinido'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          backgroundColor: Colors.blue.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDetailsCard(),
                    const SizedBox(height: 20),
                    _buildFeatureRow(),
                    const SizedBox(height: 100), // Espaço para o botão fixo
                  ],
                ),
              ),
            ),
          ),
          _buildBuyButton(context, whatsappUrl),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    List<String> imageUrls = [];

    // Verifica e carrega as URLs de imagens
    if (vehicle['imageUrls'] != null) {
      if (vehicle['imageUrls'] is String) {
        // Se for uma string, divide pelas vírgulas e remove espaços em branco extras
        imageUrls = (vehicle['imageUrls'] as String)
            .split(',')
            .map((url) => url.trim()) // Remove espaços ao redor da URL
            .where((url) =>
                url.isNotEmpty &&
                Uri.tryParse(url)?.hasAbsolutePath ==
                    true) // Verifica se a URL é válida
            .toList();
      } else if (vehicle['imageUrls'] is List) {
        // Se já for uma lista, converte para List<String>
        imageUrls = List<String>.from(vehicle['imageUrls'])
            .map((url) => url.trim())
            .where((url) =>
                url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true)
            .toList();
      }
    }

    // Se a lista de URLs estiver vazia, exibe uma mensagem
    if (imageUrls.isEmpty) {
      return Container(
        height: 400,
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            'Nenhuma imagem disponível',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index, realIndex) {
        String imageUrl = imageUrls[index];

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      },
      options: CarouselOptions(
        height: 400,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detalhes do Veículo",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              vehicle['description'] ?? 'Descrição Indefinida',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDetailIcon(
            Icons.speed, 'Quilometragem: ${vehicle['mileage'] ?? '0 km'}'),
        _buildDetailIcon(
            Icons.color_lens, 'Cor: ${vehicle['color'] ?? 'Indefinido'}'),
        _buildDetailIcon(Icons.local_gas_station,
            'Combustível: ${vehicle['fuel'] ?? 'Indefinido'}'),
      ],
    );
  }

  Widget _buildBuyButton(BuildContext context, String whatsappUrl) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _launchWhatsApp(context, whatsappUrl),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green.shade600,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            shadowColor: Colors.black45,
            elevation: 10,
          ),
          child: const Text(
            'Comprar Agora',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context, String whatsappUrl) async {
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
      );
    }
  }

  Widget _buildDetailIcon(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 30),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}
