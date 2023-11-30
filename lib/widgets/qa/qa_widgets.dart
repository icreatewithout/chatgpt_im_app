import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatgpt_im/common/assets.dart';

import '../../generated/l10n.dart';

class QaWidgets extends StatefulWidget {

  const QaWidgets({super.key});

  @override
  State<QaWidgets> createState() => _QaWidgetsState();
}

class _QaWidgetsState extends State<QaWidgets> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _select = 0;

  void _oonTabMenu(index) {
    setState(() {
      _select = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(S.of(context).qa),
        leading:IconButton(
          icon: Image.asset(
            Assets.ic_launcher,
            width: 30,
            height: 30,
            fit: BoxFit.cover,
          ), onPressed: () {  },
        ),
      ),
      body: const Text("qa"),
      // drawer: const MyDrawer(),
      //drawer: DrawerPageWidget(), //抽屉页面
    );
  }
}
