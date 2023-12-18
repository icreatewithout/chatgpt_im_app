import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

GlobalKey<_SelectSizeState> sizeGlobalKey = GlobalKey();

class SelectSize extends StatefulWidget {
  const SelectSize({super.key});

  @override
  State<SelectSize> createState() => _SelectSizeState();
}

class _SelectSizeState extends State<SelectSize> {
  String? selectedValue;
  final _formKey = GlobalKey<FormState>();
  final List<String> _models = [
    '256x256',
    '512x512',
    '1024x1024',
    '1792x1024(dall-e-3)',
    '1024x1792(dall-e-3)',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> validator() async {
    return _formKey.currentState!.validate();
  }

  void setVal(String val) {
    setState(() {
      selectedValue = val;
      _formKey.currentState!.deactivate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: DropdownButtonFormField2<String>(
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // Add more decoration..
          ),
          hint: const Text(
            'Select Image Size',
            style: TextStyle(fontSize: 14),
          ),
          items: _models
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
          validator: (value) {
            if (value == null) {
              return 'Please select size.';
            }
            return null;
          },
          onChanged: (value) {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
            }
          },
          onSaved: (value) {
            selectedValue = value.toString();
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.only(right: 8),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.black45,
            ),
            iconSize: 24,
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}
