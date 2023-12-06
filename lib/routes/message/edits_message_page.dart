
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

class EditsMessage extends StatefulWidget {
  static const String path = "/gpt/edits";

  const EditsMessage({super.key, required this.arguments});

  final Map arguments;

  @override
  State<EditsMessage> createState() => _EditsMessageState();
}

class _EditsMessageState extends State<EditsMessage> {

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
        title: const Text('Create Chat Completion'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
    );
  }
  
}
