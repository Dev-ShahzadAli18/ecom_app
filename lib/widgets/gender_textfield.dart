import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final double borderRadius;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = 'Select',
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? Color.fromARGB(255, 245, 183, 0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: bg,
          hint: Text(hint, style: const TextStyle(fontSize: 15)),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: iconColor ?? Color.fromARGB(255, 245, 183, 0),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
