import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null
          ? null
          : (_) => onTap!(),
      selectedColor: Colors.green.shade100,
      labelStyle: TextStyle(
        color: selected
            ? Colors.green.shade800
            : Colors.grey.shade700,
        fontWeight:
        selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}