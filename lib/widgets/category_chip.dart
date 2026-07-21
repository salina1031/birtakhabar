import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: chipColor,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        shape: StadiumBorder(side: BorderSide(color: chipColor.withOpacity(0.4))),
      ),
    );
  }
}
