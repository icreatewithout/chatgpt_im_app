import 'package:chatgpt_im/db/message_table.dart';
import 'package:chatgpt_im/states/MessageModel.dart';
import 'package:chatgpt_im/widgets/find/menu_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/message.dart';
import '../../states/LocaleModel.dart';
import '../../widgets/find/select_models_widgets.dart';
import '../../widgets/ui/open_cn_button.dart';
import '../../widgets/ui/open_cn_text_field.dart';

class ChatMessage extends StatefulWidget {
  static const String path = "/gpt/chat";

  const ChatMessage({
    super.key,
    required this.arguments,
  });

  final Map arguments;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
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
    var gm = S.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.arguments['title'],style: const TextStyle(fontSize: 16),),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.settings))
        ],
      ),
      body: Consumer<LocaleModel>(
        builder:
            (BuildContext context, LocaleModel localeModel, Widget? child) {
          return SizedBox(
            height: double.infinity,
            child: Text('1'),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(18),
        color: Colors.white,
        child: Text('w'),
      ),
    );
  }
}
