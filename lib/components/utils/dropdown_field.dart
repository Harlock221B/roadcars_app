import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const DropdownField({
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey, width: 2),
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
    );
  }
}
