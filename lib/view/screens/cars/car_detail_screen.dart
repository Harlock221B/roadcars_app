import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:roadcarsapp/view/screens/cars/edit_car_screen.dart';
import 'package:roadcarsapp/components/favoriteicon/favorite.dart';
import 'package:roadcarsapp/components/image_carousel/image_carousel.dart';

class VehicleDetailsPage extends StatefulWidget {
  final String carId; // O ID do carro no Firestore
  const VehicleDetailsPage({required this.carId, super.key});

  @override
  _VehicleDetailsPageState createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Detalhes do Veículo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          FavoriteIcon(carId: widget.carId), // Ícone de Favoritar no AppBar
          // Botão de edição e exclusão condicional
          FutureBuilder<User?>(
            future: FirebaseAuth.instance.userChanges().first,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final currentUserId = snapshot.data!.uid;

              // Carregar os dados do veículo
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('cars')
                    .doc(widget.carId)
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
                  final vehicleOwnerId = vehicle['userId'];

                  return vehicleOwnerId == currentUserId
                      ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditCarScreen(
                                      carId: widget.carId,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  setState(() {}); // Força o rebuild da página
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context),
                            ),
                          ],
                        )
                      : const SizedBox.shrink();
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('cars')
            .doc(widget.carId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Erro ao carregar os dados'));
          }

          var vehicle = snapshot.data!.data() as Map<String, dynamic>;
          List<String> imageUrls = List<String>.from(vehicle['imageUrls']);
          final String vehicleName = "${vehicle['brand']} ${vehicle['model']}";
          final double price =
              vehicle['price'] != null ? vehicle['price'].toDouble() : 0.0;
          final int km = vehicle['km'] != null ? vehicle['km'] as int : 0;

          final NumberFormat kmFormat = NumberFormat.decimalPattern('pt_BR');
          final NumberFormat currencyFormat =
              NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

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
                        ImageCarousel(imageUrls: imageUrls),
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
                              currencyFormat.format(price),
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
                        _buildFeatureRow(vehicle, kmFormat),
                        const SizedBox(height: 20),
                        _buildExtraInfo(vehicle),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBuyButton(
                  context, () => openWhatsAppWithSeller(context, vehicle)),
            ],
          );
        },
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
                Html(
                  data: vehicle['description'] ?? 'Sem descrição disponível.',
                  style: {
                    "body": Style(
                      fontSize: FontSize(16.0),
                      color: Colors.black54,
                      lineHeight: LineHeight(1.5),
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(Map<String, dynamic> vehicle, NumberFormat kmFormat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDetailIcon(
            Icons.speed, 'Quilometragem: ${kmFormat.format(vehicle['km'])} km'),
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

  Widget _buildBuyButton(BuildContext context, VoidCallback onPressed) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: onPressed,
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
        const SnackBar(content: Text('Erro ao abrir WhatsApp')),
      );
    }
  }

  Future<void> openWhatsAppWithSeller(
      BuildContext context, Map<String, dynamic> vehicle) async {
    final String vehicleName = vehicle['model'] ?? 'Veículo Indefinido';
    final String userId = vehicle['userId'];

    try {
      // Buscando o documento do vendedor no Firestore
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Verificando se o snapshot contém dados
      if (userSnapshot.exists) {
        final String phoneNumber = '5511986300771' ?? 'Número não disponível';

        // Montando a URL do WhatsApp
        final String whatsappUrl =
            "https://wa.me/$phoneNumber?text=Olá!%20Estou%20interessado%20no%20$vehicleName.";

        // Chamando a função para abrir o WhatsApp
        _launchWhatsApp(context, whatsappUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar dados do vendedor: $e')),
      );
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content:
              const Text('Você tem certeza que deseja excluir este veículo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteVehicle();
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVehicle() async {
    try {
      await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.carId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veículo excluído com sucesso')),
      );
      Navigator.of(context).pop(); // Volta para a tela anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir veículo: $e')),
      );
    }
  }
}
