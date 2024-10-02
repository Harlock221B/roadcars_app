
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleDetailPage extends StatelessWidget {
  final Map<String, String> vehicle;

  const VehicleDetailPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    const String sellerPhone = "19982032604";
    final String whatsappUrl =
        "https://wa.me/$sellerPhone?text=Olá!%20Estou%20interessado%20no%20${vehicle['name']}.";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          vehicle['name']!,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroImage(),
                    const SizedBox(height: 20),
                    Text(
                      vehicle['name']!,
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
                          vehicle['price']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Ano: ${vehicle['year']}',
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

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Hero(
        tag: vehicle['name']!,
        child: Image.network(
          vehicle['image']!,
          fit: BoxFit.cover,
          height: 400,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 400,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey, Colors.grey],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              height: 400,
              width: double.infinity,
              child: const Center(
                child: Icon(Icons.error, color: Colors.red, size: 60),
              ),
            );
          },
        ),
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
              vehicle['details']!,
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
        _buildDetailIcon(Icons.speed, 'Quilometragem: ${vehicle['mileage']}'),
        _buildDetailIcon(Icons.color_lens, 'Cor: ${vehicle['color']}'),
        _buildDetailIcon(Icons.local_gas_station, 'Combustível: ${vehicle['fuel']}'),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
