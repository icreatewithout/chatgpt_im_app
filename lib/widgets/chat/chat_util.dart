
import 'package:flutter/material.dart';

class ChatUtil {
  static Widget textField(TextEditingController controller, FocusNode focusNode,
      String hintText, Function send) {
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
      onSubmitted: (val) => send(val),
      onEditingComplete: () {},
    );
  }

}
