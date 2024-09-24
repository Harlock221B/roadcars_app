import 'package:flutter/material.dart';
import '../screens/VehicleDetailPage.dart';

class VehicleCard extends StatelessWidget {
  final Map<String, String> vehicle;

  const VehicleCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 15),
      color: Colors.white, // Fundo claro para o card
      elevation: 5, // Sombra leve para destacar o card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.network(
              vehicle['image']!,
              fit: BoxFit.cover,
              height: 350,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do veículo
                Text(
                  vehicle['name']!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Texto escuro sobre fundo claro
                  ),
                ),
                const SizedBox(height: 10),
                // Descrição do veículo
                Text(
                  vehicle['description']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800], // Texto cinza escuro
                  ),
                ),
                const SizedBox(height: 10),
                // Preço do veículo
                Text(
                  vehicle['price']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Destaque para o preço
                  ),
                ),
                const SizedBox(height: 15),
                // Botão para ver detalhes
                ElevatedButton(
                  onPressed: () {
                    // Navegar com animação para a tela de detalhes
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            VehicleDetailPage(vehicle: vehicle),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Botão com cor azul
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Text(
                      'Ver Detalhes',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Texto branco no botão
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
