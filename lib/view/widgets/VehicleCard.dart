import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/VehicleDetailPage.dart';

class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    // Verifica se há URLs de imagem disponíveis e trata o caso onde o campo pode estar vazio ou nulo
    String imageUrl = (vehicle['imageUrls'] != null && vehicle['imageUrls'].isNotEmpty && vehicle['imageUrls'][0] != null)
        ? vehicle['imageUrls'][0] // Primeira imagem da lista
        : 'assets/images/fallback_image.jpg'; // Imagem de fallback

    return GestureDetector(
      onTap: () {
        // Navegar com animação para a tela de detalhes do veículo
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                VehicleDetailPage(
                    vehicle: vehicle
                        .map((key, value) => MapEntry(key, value.toString()))),
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
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(vertical: 15),
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Utilizando CachedNetworkImage para carregar a imagem do Firebase Storage
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(), // Exibe um indicador de carregamento enquanto a imagem é carregada
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/fallback_image.jpg', // Exibe a imagem de fallback caso ocorra algum erro
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
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
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: Colors.white.withOpacity(0.9),
                      size: 30,
                    ),
                    onPressed: () {
                      // Função para favoritar o veículo
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    "${vehicle['brand']} ${vehicle['model']}", // Exibe marca e modelo
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 5,
                          color: Colors.black54,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle['description'] ?? "Sem descrição",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700], // Um cinza mais claro para contraste
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "R\$ ${vehicle['price']}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent, // Um tom de azul mais suave
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleDetailPage(
                                  vehicle: vehicle.map((key, value) =>
                                      MapEntry(key, value.toString()))),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text(
                            'Ver Detalhes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ano: ${vehicle['year']}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
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
