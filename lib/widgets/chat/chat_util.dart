import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ChatUtil {
  static Widget textField(TextEditingController controller, FocusNode focusNode,
      String hintText, Function() send) {
    return TextField(
      cursorColor: Colors.grey,
      autofocus: false,
      focusNode: focusNode,
      maxLength: 2000,
      minLines: 1,
      maxLines: 6,
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        counterText: '',
        hintText: hintText,
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      style: const TextStyle(fontSize: 14),
      textInputAction: TextInputAction.send,
      keyboardType: TextInputType.multiline,
      onSubmitted: (val) => send(),
      onEditingComplete: () {},
    );
  }

  static Widget selectItem(
      List<String> items, String hint, String valid, Function(String? val) save,
      {String? value}) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      hint: Text(hint, style: const TextStyle(fontSize: 14)),
      items: items
          .map((item) => DropdownItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14))))
          .toList(),
      value: value,
      validator: (value) {
        if (value == null) return valid;
        return null;
      },
      onChanged: (value) => save(value),
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

  static final List<String> models = [
    'gpt-3.5-turbo-16k',
    'gpt-3.5-turbo-0301',
    'gpt-3.5-turbo',
    'gpt-3.5-turbo-0613',
    'gpt-3.5-turbo-1106',
    'gpt-4-0314	',
    'gpt-4-0613	',
    'gpt-4-32k	',
    'gpt-4-32k-0314	',
    'tts-1',
    'whisper-1',
    'davinci',
    'dall-e-2',
    'tts-1-1106',
    'tts-1-hd-1106',
    'dall-e-3',
    'davinci-search-document',
    'curie-search-document',
    'babbage-code-search-code',
    'text-search-ada-query-001',
    'code-search-ada-text-001',
    'babbage-code-search-text',
    'code-search-babbage-code-001',
    'ada-search-query',
    'ada-code-search-text',
    'tts-1-hd',
    'gpt-3.5-turbo-16k-0613',
    'text-search-curie-query-001',
    'text-davinci-002',
    'text-davinci-edit-001',
    'code-search-babbage-text-001',
    'ada',
    'text-ada-001',
    'ada-similarity',
    'code-search-ada-code-001',
    'text-similarity-ada-001',
    'text-search-curie-doc-001',
    'text-curie-001',
    'curie',
  ];

  static final List<String> size = [
    '256x256',
    '512x512',
    '1024x1024',
    '1792x1024(dall-e-3)',
    '1024x1792(dall-e-3)',
  ];

  static final List<String> audio = [
    'mp3',
    'opus',
    'aac',
    'flac',
  ];

  static final List<String> style = [
    'vivid',
    'natural',
  ];

  static final List<String> voice = [
    'alloy',
    'echo',
    'fable',
    'onyx',
    'nova',
    'shimmer'
  ];

  static final List<String> transcription = [
    'json',
    'text',
    'srt',
    'verbose_json',
    'vtt',
  ];

  static final List<String> format = [
    'text',
    'json_object',
  ];
}
