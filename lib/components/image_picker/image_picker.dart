import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';

class ImagePickerWidget extends StatelessWidget {
  final List<Uint8List> carImages;
  final Function(int) onRemoveImage;
  final Function() onPickImages;

  const ImagePickerWidget({
    required this.carImages,
    required this.onRemoveImage,
    required this.onPickImages,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Centraliza o conteúdo
      children: [
        const Text(
          'Imagens do Carro',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Cor de texto mais elegante
          ),
          textAlign: TextAlign.center, // Centraliza o texto
        ),
        const SizedBox(height: 16), // Mais espaço entre o título e o grid
        GridView.builder(
          shrinkWrap: true,
          itemCount: (carImages.length + 1) > 6
              ? carImages.length
              : carImages.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16, // Mais espaço entre os quadrados
            mainAxisSpacing: 16, // Mais espaço entre os quadrados
          ),
          itemBuilder: (context, index) {
            if (index < carImages.length) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12), // Bordas suavizadas
                    child: Image.memory(
                      carImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 6, // Ajuste fino na posição do ícone de remover
                    right: 6,
                    child: GestureDetector(
                      onTap: () => onRemoveImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (index == carImages.length && carImages.length < 6) {
              // Placeholder visual para adicionar mais imagens
              return GestureDetector(
                onTap: onPickImages,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  dashPattern: const [6, 3],
                  color: Colors.grey[400]!,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Adicionar mais fotos',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center, // Centraliza o texto
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox
                  .shrink(); // Se o número de imagens for superior a 6
            }
          },
        ),
      ],
    );
  }
}
