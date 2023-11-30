import 'package:chatgpt_im/widgets/ui/open_cn_drag_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatgpt_im/common/assets.dart';
import 'package:chatgpt_im/common/global.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../states/UserModel.dart';

class FindWidgets extends StatefulWidget {
  const FindWidgets({super.key});

  @override
  State<FindWidgets> createState() => _FindWidgetsState();
}

class _FindWidgetsState extends State<FindWidgets> {
  @override
  void initState() {
    debugPrint('locale ==== > ${Global.profile.locale}');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(S.of(context).find),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.red,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        height: 500,
        width: double.infinity,
        child: DragMoveBox(
          child: Text('1'),
        ),
      ),
    );
  }
}
