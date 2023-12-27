import 'dart:io';
import 'dart:typed_data';

import 'package:chatgpt_im/common/common_utils.dart';
import 'package:chatgpt_im/widgets/ui/open_cn_button.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

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

  static openBottomSheet(BuildContext context, File file) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return SafeArea(
            child: Stack(
              children: [
                PhotoViewGestureDetectorScope(
                  axis: Axis.vertical,
                  child: PhotoView(
                    backgroundDecoration:
                        BoxDecoration(color: Colors.black.withAlpha(240)),
                    imageProvider: FileImage(file),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: kToolbarHeight,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: kBottomNavigationBarHeight,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.download,
                          color: Colors.white, size: 28),
                      onPressed: () => downloadImage(file),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

  static void downloadImage(File file) async {
    bool photosStatus =
        await CommonUtils.requestScopePermission(Permission.photosAddOnly);
    if (photosStatus) {
      final result = await ImageGallerySaver.saveImage(file.readAsBytesSync(),
          quality: 100);
      debugPrint(result);
    } else {
      CommonUtils.showToast('相册未授权');
    }
  }

  static void downloadAudio(File file) async {
    bool storageStatus =
    await CommonUtils.requestScopePermission(Permission.storage);
    if (storageStatus) {
      final result = await ImageGallerySaver.saveImage(file.readAsBytesSync(),
          quality: 100);
      debugPrint(result);
    } else {
      CommonUtils.showToast('存储未授权');
    }
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
    '1792x1024',
    '1024x1792',
  ];

  static getSize(String size) {
    switch (size) {
      case '256x256':
        return OpenAIImageSize.size256;
      case '512x512':
        return OpenAIImageSize.size512;
      case '1024x1024':
        return OpenAIImageSize.size1024;
      case '1792x1024':
        return OpenAIImageSize.size1792Horizontal;
      case '1024x1792':
        return OpenAIImageSize.size1792Vertical;
    }
  }

  static final List<String> audio = [
    'mp3',
    'opus',
    'aac',
    'flac',
  ];

  static getAudio(String rf) {
    switch (rf) {
      case 'mp3':
        return OpenAIAudioSpeechResponseFormat.mp3;
      case 'opus':
        return OpenAIAudioSpeechResponseFormat.opus;
      case 'aac':
        return OpenAIAudioSpeechResponseFormat.aac;
      case 'flac':
        return OpenAIAudioSpeechResponseFormat.flac;
    }
  }

  static final List<String> style = [
    'vivid',
    'natural',
  ];

  static getStyle(String style) {
    switch (style) {
      case 'vivid':
        return OpenAIImageStyle.vivid;
      case 'natural':
        return OpenAIImageStyle.natural;
    }
  }

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

  static final List<String> imageFormat = [
    'url',
    'b64_json',
  ];

  static getImageFormat(String imageFormat) {
    switch (imageFormat) {
      case 'url':
        return OpenAIImageResponseFormat.url;
      case 'b64_json':
        return OpenAIImageResponseFormat.b64Json;
    }
  }

  static Future<String> saveFile(
      String path, String fileName, Uint8List bytes) async {
    Directory directory = await CommonUtils.getAppDocumentsDir();
    path = '${directory.path}$path/';
    Directory newDir = Directory(path);
    if (!newDir.existsSync()) {
      newDir.createSync(recursive: true);
    }
    File file = File(path + fileName);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsBytes(bytes);

    return file.path;
  }
}
