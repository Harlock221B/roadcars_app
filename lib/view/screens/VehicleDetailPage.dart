import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleDetailPage extends StatelessWidget {
  final Map<String, String> vehicle;

  const VehicleDetailPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final String sellerPhone = "19982032604";
    final String whatsappUrl = "https://wa.me/$sellerPhone?text=Olá!%20Estou%20interessado%20no%20${vehicle['name']}.";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          vehicle['name']!,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        vehicle['image']!,
                        fit: BoxFit.cover,
                        height: 400,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      vehicle['name']!,
                      style: const TextStyle(
                        fontSize: 26,
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
                            color: Colors.black87,
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Ano: ${vehicle['year']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          backgroundColor: Colors.blue.shade50,
                        ),
                      ],
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailIcon(Icons.speed, 'Quilometragem: ${vehicle['mileage']}'),
                        _buildDetailIcon(Icons.color_lens, 'Cor: ${vehicle['color']}'),
                      ],
                    ),
                    const SizedBox(height: 80), // Deixe espaço para o botão fixo
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              child: ElevatedButton(
                onPressed: () {
                  launchUrl(Uri.parse(whatsappUrl));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Comprar Agora',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}
