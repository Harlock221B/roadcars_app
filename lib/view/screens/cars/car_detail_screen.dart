import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roadcarsapp/view/screens/cars/edit_car_screen.dart';
import 'package:roadcarsapp/components/favoriteicon/favorite.dart';

class VehicleDetailsPage extends StatelessWidget {
  final String carId; // O ID do carro no Firestore

  const VehicleDetailsPage({required this.carId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Detalhes do Veículo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          FavoriteIcon(carId: carId), // Ícone de Favoritar no AppBar
          // Botão de edição condicional
          FutureBuilder<User?>(
            future: FirebaseAuth.instance.userChanges().first,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData) {
                return const SizedBox
                    .shrink(); // Se não houver usuário logado, não exibe nada
              }

              final currentUserId = snapshot.data!.uid;

              // Carregar os dados do veículo
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('cars')
                    .doc(carId)
                    .get(),
                builder: (context, carSnapshot) {
                  if (carSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (!carSnapshot.hasData || carSnapshot.data == null) {
                    return const SizedBox.shrink();
                  }

                  var vehicle =
                      carSnapshot.data!.data() as Map<String, dynamic>;
                  final vehicleOwnerId = vehicle[
                      'userId']; // ID do usuário que adicionou o veículo

                  return vehicleOwnerId == currentUserId
                      ? IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black87),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCarScreen(
                                  carId: carId,
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox
                          .shrink(); // Se não for o proprietário, não exibe o botão
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('cars').doc(carId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Erro ao carregar os dados'));
          }

          var vehicle = snapshot.data!.data() as Map<String, dynamic>;
          List<String> imageUrls = List<String>.from(vehicle['imageUrls']);
          final String vehicleName = vehicle['model'] ?? 'Veículo Indefinido';
          final String whatsappUrl =
              "https://wa.me/19982032604?text=Olá!%20Estou%20interessado%20no%20$vehicleName.";

          return Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageCarousel(imageUrls), // Carrossel das imagens
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
                                color: Colors.blueGrey,
                              ),
                            ),
                            Chip(
                              label: Text(
                                'Ano: ${vehicle['year'] ?? 'Ano Indefinido'}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              backgroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDetailsCard(context, vehicle),
                        const SizedBox(height: 20),
                        _buildFeatureRow(vehicle),
                        const SizedBox(height: 20),
                        _buildExtraInfo(vehicle),
                        const SizedBox(height: 100), // Espaço para o botão fixo
                      ],
                    ),
                  ),
                ),
              ),
              _buildBuyButton(context, whatsappUrl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
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
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.error,
              color: Colors.red,
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 400,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
        autoPlay: true,
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, Map<String, dynamic> vehicle) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detalhes do Veículo",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  vehicle['description'] ?? 'Sem descrição disponível.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(Map<String, dynamic> vehicle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDetailIcon(Icons.speed, 'Quilometragem: ${vehicle['km']} km'),
        _buildDetailIcon(Icons.color_lens, 'Cor: ${vehicle['color']}'),
        _buildDetailIcon(
            Icons.local_gas_station, 'Combustível: ${vehicle['fuel']}'),
      ],
    );
  }

  Widget _buildExtraInfo(Map<String, dynamic> vehicle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow("Motor", vehicle['motor'] ?? "Indefinido"),
            const Divider(color: Colors.grey),
            _buildDetailRow(
                "Blindado", vehicle['armored'] == true ? "Sim" : "Não"),
            const Divider(color: Colors.grey),
            _buildDetailRow(
                "Transmissão", vehicle['transmission'] ?? "Indefinida"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
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
            backgroundColor: Colors.blueGrey,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            shadowColor: Colors.black45,
            elevation: 10,
          ),
          child: const Text(
            'Comprar Agora',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _launchWhatsApp(BuildContext context, String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao abrir WhatsApp')));
    }
  }

  Widget _buildDetailIcon(IconData iconData, String label) {
    return Column(
      children: [
        Icon(iconData, size: 28, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}
