import 'package:flutter/material.dart';

class ColorSelection extends StatelessWidget {
  final String selectedColor;
  final Map<String, Color> colors;
  final ValueChanged<String> onColorSelected;

  const ColorSelection({
    required this.selectedColor,
    required this.colors,
    required this.onColorSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cor',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.entries.map((entry) {
            return GestureDetector(
              onTap: () => onColorSelected(entry.key),
              child: Tooltip(
                message: entry.key,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor == entry.key
                          ? Colors.blueAccent
                          : Colors.grey.shade300,
                      width: 2.0,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: entry.value,
                    radius: 22,
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
