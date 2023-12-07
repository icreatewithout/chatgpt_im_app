import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

GlobalKey<_SelectModelsState> modelsGlobalKey = GlobalKey();

class SelectModels extends StatefulWidget {
  const SelectModels({super.key});

  @override
  State<SelectModels> createState() => _SelectModelsState();
}

class _SelectModelsState extends State<SelectModels> {
  String? selectedValue;
  final _formKey = GlobalKey<FormState>();
  final List<String> _models = [
    'gpt-3.5-turbo-0613',
    'davinci-search-document',
    'curie-search-document',
    'babbage-code-search-code',
    'text-search-ada-query-001',
    'code-search-ada-text-001',
    'babbage-code-search-text',
    'gpt-3.5-turbo-0301',
    'code-search-babbage-code-001',
    'ada-search-query',
    'gpt-3.5-turbo',
    'ada-code-search-text',
    'tts-1-hd',
    'gpt-3.5-turbo-16k-0613',
    'text-search-curie-query-001',
    'gpt-3.5-turbo-1106',
    'text-davinci-002',
    'text-davinci-edit-001',
    'code-search-babbage-text-001',
    'ada',
    'text-ada-001',
    'ada-similarity',
    'code-search-ada-code-001',
    'text-similarity-ada-001',
    'gpt-3.5-turbo-16k',
    'text-search-curie-doc-001',
    'text-curie-001',
    'curie',
    'tts-1',
    'whisper-1',
    'davinci',
    'dall-e-2',
    'tts-1-1106',
    'tts-1-hd-1106',
    'dall-e-3'
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
            'Select Your Model',
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
              return 'Please select model.';
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
