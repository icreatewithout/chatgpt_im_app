import 'package:chatgpt_im/routes/create/create_assistant.dart';
import 'package:chatgpt_im/routes/create/create_audio.dart';
import 'package:chatgpt_im/routes/create/create_edits.dart';
import 'package:chatgpt_im/routes/create/create_fine.dart';
import 'package:chatgpt_im/routes/create/create_images.dart';
import 'package:chatgpt_im/routes/create/create_whisper.dart';
import 'package:chatgpt_im/routes/message/audio_message_page.dart';
import 'package:chatgpt_im/routes/message/chat_message_page.dart';
import 'package:chatgpt_im/routes/message/edits_message_page.dart';
import 'package:chatgpt_im/routes/message/fine_message_page.dart';
import 'package:chatgpt_im/routes/message/images_message_page.dart';
import 'package:chatgpt_im/routes/message/whisper_message_page.dart';
import 'package:chatgpt_im/routes/my_files.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class MenuWidgets extends StatefulWidget {
  const MenuWidgets({super.key});

  @override
  State<MenuWidgets> createState() => _MenuWidgetsState();
}

class _MenuWidgetsState extends State<MenuWidgets> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: const Icon(
          Icons.add_circle_outline,
          color: Colors.grey,
          size: 26,
        ),
        items: [
          ...MenuItems.firstItems.map(
            (item) => DropdownMenuItem<MenuItem>(
              value: item,
              child: MenuItems.buildItem(item),
            ),
          ),
          const DropdownMenuItem<Divider>(enabled: false, child: Divider()),
          ...MenuItems.secondItems.map(
            (item) => DropdownMenuItem<MenuItem>(
              value: item,
              child: MenuItems.buildItem(item),
            ),
          ),
        ],
        onChanged: (val) => MenuItems.onChanged(context, val as MenuItem),
        dropdownStyleData: DropdownStyleData(
          direction: DropdownDirection.left,
          width: 160,
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey,
          ),
          elevation: 8,
          offset: const Offset(0, 8),
        ),
        menuItemStyleData: MenuItemStyleData(
          customHeights: [
            ...List<double>.filled(MenuItems.firstItems.length, 48),
            8,
            ...List<double>.filled(MenuItems.secondItems.length, 48),
          ],
          padding: const EdgeInsets.only(left: 16, right: 16),
        ),
      ),
    );
  }
}

class MenuItem {
  final String text;
  final String path;
  final IconData icon;

  const MenuItem({
    required this.text,
    required this.path,
    required this.icon,
  });
}

class MenuItems {
  static const List<MenuItem> firstItems = [
    assistant,
    edits,
    images,
    whisper,
    audio,
    fine
  ];
  static const List<MenuItem> secondItems = [files];

  static const assistant =
      MenuItem(text: 'Chat', path: ChatMessage.path, icon: Icons.assistant);
  static const edits = MenuItem(
      text: 'Edits', path: EditsMessage.path, icon: Icons.edit_document);
  static const images =
      MenuItem(text: 'Images', path: ImagesMessage.path, icon: Icons.image);
  static const audio =
      MenuItem(text: 'Audio', path: AudioMessage.path, icon: Icons.audio_file);
  static const whisper = MenuItem(
      text: 'Whisper', path: WhisperMessage.path, icon: Icons.text_fields);
  static const fine =
      MenuItem(text: 'FineTunes', path: FineMessage.path, icon: Icons.settings);
  static const files =
      MenuItem(text: 'Files', path: MyFiles.path, icon: Icons.file_present);

  static IconData? getIcon(String? text) {
    IconData? iconData = Icons.telegram;
    switch (text) {
      case 'Chat':
        iconData = Icons.assistant;
        break;
      case 'Edits':
        iconData = Icons.edit;
        break;
      case 'Images':
        iconData = Icons.image;
        break;
      case 'Audio':
        iconData = Icons.text_fields;
        break;
      case 'Whisper':
        iconData = Icons.audio_file;
        break;
      case 'FineTunes':
        iconData = Icons.settings;
        break;
      case 'Files':
        iconData = Icons.file_present;
        break;
    }
    return iconData;
  }

  static MenuItem? getMenuItem(String? text) {
    switch (text) {
      case 'Chat':
        return assistant;
      case 'Edits':
        return edits;
      case 'Images':
        return images;
      case 'Audio':
        return audio;
      case 'Whisper':
        return whisper;
      case 'FineTunes':
        return fine;
      case 'Files':
        return files;
    }
    return null;
  }

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(
          width: 10,
        ),
        Text(
          item.text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static onChanged(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.assistant:
        Navigator.of(context).pushNamed(CreateAssistant.path);
        break;
      case MenuItems.edits:
        Navigator.of(context).pushNamed(CreateEdits.path);
        break;
      case MenuItems.images:
        Navigator.of(context).pushNamed(CreateImages.path);
        break;
      case MenuItems.whisper:
        Navigator.of(context).pushNamed(CreateWhisper.path);
        break;
      case MenuItems.audio:
        Navigator.of(context).pushNamed(CreateAudio.path);
        break;
      case MenuItems.fine:
        Navigator.of(context).pushNamed(CreateFine.path);
        break;
      case MenuItems.files:
        Navigator.of(context).pushNamed(MyFiles.path);
        break;
    }
  }
}