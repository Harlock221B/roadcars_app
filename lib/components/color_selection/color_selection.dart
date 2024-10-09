import 'package:flutter/material.dart';
import 'package:roadcarsapp/data/utils.dart';

class ColorSelection extends StatefulWidget {
  const ColorSelection({Key? key}) : super(key: key);

  @override
  _ColorSelectionState createState() => _ColorSelectionState();
}

class _ColorSelectionState extends State<ColorSelection> {
  String _selectedColor = 'black';

  @override
  Widget build(BuildContext context) {
    return _buildColorSelection();
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cor',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, // Espaçamento horizontal entre os círculos
          runSpacing: 12, // Espaçamento vertical entre os círculos
          children: colors.entries.map((entry) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = entry.key;
                });
              },
              child: Tooltip(
                message: entry.key, // Mostra o nome da cor ao passar o dedo
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(3), // Espaço para a borda
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == entry.key
                          ? Colors.blueAccent
                          : Colors.grey.shade300,
                      width: 2.0,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: entry.value,
                    radius: 22, // Tamanho dos círculos
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
