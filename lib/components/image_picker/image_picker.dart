import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:typed_data';

class ImagePickerComponent extends StatelessWidget {
  final List<Uint8List> carImages;
  final List<String> carImageUrls; // Para imagens existentes
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;
  final ValueChanged<int>
      onRemoveImageUrl; // Para remover URLs de imagens salvas

  const ImagePickerComponent({
    Key? key,
    required this.carImages,
    required this.carImageUrls,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.onRemoveImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Imagens do Carro',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          itemCount: (carImages.length + carImageUrls.length + 1) > 6
              ? carImages.length + carImageUrls.length
              : carImages.length + carImageUrls.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            if (index < carImageUrls.length) {
              // Exibindo imagens já salvas
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      carImageUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => onRemoveImageUrl(index),
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
            } else if (index < carImageUrls.length + carImages.length) {
              // Exibindo novas imagens carregadas
              final localImageIndex = index - carImageUrls.length;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      carImages[localImageIndex],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => onRemoveImage(localImageIndex),
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
            } else if (index == carImageUrls.length + carImages.length &&
                carImages.length + carImageUrls.length < 6) {
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
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}
