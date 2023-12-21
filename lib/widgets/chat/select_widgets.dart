import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class SelectWidgets extends StatelessWidget {
  const SelectWidgets({
    super.key,
    required this.hint,
    this.value,
    required this.dropdownItems,
    this.onChanged,
    this.valid,
  });

  final String hint;
  final String? value;
  final String? valid;
  final List<String> dropdownItems;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      hint: Text(hint, style: const TextStyle(fontSize: 14)),
      items: dropdownItems
          .map((item) => DropdownItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14))))
          .toList(),
      value: value,
      validator: (value) {
        if (value == null) return valid;
        return null;
      },
      onChanged: onChanged,
      buttonStyleData:
          const ButtonStyleData(padding: EdgeInsets.only(right: 8)),
      iconStyleData: const IconStyleData(
          icon: Icon(Icons.arrow_drop_down, color: Colors.black45),
          iconSize: 24),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      ),
      menuItemStyleData: const MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16)),
    );
  }
}
