import 'package:flutter/material.dart';
import 'package:roadcarsapp/view/screens/cars/car_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:roadcarsapp/components/favoriteicon/favorite.dart';
import 'package:intl/intl.dart'; // Importação do pacote intl
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final String carId;

  const VehicleCard({super.key, required this.vehicle, required this.carId});

  Future<void> _deleteCar(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('cars').doc(carId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carro excluído com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir carro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = vehicle['imageUrls'][0];
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final NumberFormat kmFormat = NumberFormat.decimalPattern('pt_BR');

    // Garantir que o valor de km seja um número
    final int km = vehicle['km'] != null ? vehicle['km'] as int : 0;

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isSeller =
        currentUser != null && currentUser.uid == vehicle['userId'];

    final bool isArmored = vehicle['armored'] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                VehicleDetailsPage(carId: carId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Aumentar o arredondamento
        ),
        margin: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 8), // Margens ajustadas
        elevation: 3, // Sombra reduzida
        shadowColor: Colors.black54, // Cor da sombra
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/fallback_image.jpg',
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200, // Altura ajustada
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12, // Ajuste na posição do ícone
                  right: 12,
                  child: Row(
                    children: [
                      if (currentUser != null) FavoriteIcon(carId: carId),
                      if (isSeller)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final bool? confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar Exclusão'),
                                content: const Text(
                                    'Você tem certeza que deseja excluir este carro?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmDelete == true) {
                              _deleteCar(context);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16), // Padding ajustado
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${vehicle['brand']} ${vehicle['model']}",
                    style: const TextStyle(
                      fontSize: 20, // Tamanho da fonte ajustado
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormat.format(vehicle['price'] ?? 0),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A8EAE), // Azul acinzentado
                        ),
                      ),
                      Text(
                        "Ano: ${vehicle['year'] ?? 'Ano Indefinido'}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700], // Ajustar a cor
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.local_gas_station,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${vehicle['fuel']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.drive_eta, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        vehicle['transmission'] ?? "Manual",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      if (isArmored) ...[
                        Icon(Icons.security, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          "Blindado",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "${kmFormat.format(km)} km",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
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
