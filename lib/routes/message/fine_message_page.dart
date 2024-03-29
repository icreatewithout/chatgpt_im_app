import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../states/LocaleModel.dart';

class FineMessage extends StatefulWidget {
  static const String path = "/gpt/fine";

  const FineMessage({super.key, required this.arguments});

  final Map arguments;

  @override
  State<FineMessage> createState() => _FineMessageState();
}

class _FineMessageState extends State<FineMessage> {

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
