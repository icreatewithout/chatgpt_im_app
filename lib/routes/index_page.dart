import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../widgets/find/find_widgets.dart';
import '../widgets/me/me_widgets.dart';
import '../widgets/qa/qa_widgets.dart';


class IndexPage extends StatefulWidget {
  static const String path = "/home";

  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _select = 0;
  final List<Widget> _list = const [
    FindWidgets(),
    QaWidgets(),
    MeWidgets()
  ];

  final List<String> _label = const [];

  void _oonTabMenu(index) {
    setState(() {
      _select = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _list[_select],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        fixedColor: Colors.red,
        currentIndex: _select,
        elevation: 2,
        onTap: (index) => _oonTabMenu(index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.lightbulb_circle_rounded),
              label: S.of(context).find),
          BottomNavigationBarItem(
              icon: const Icon(Icons.article), label: S.of(context).qa),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person), label: S.of(context).me)
        ],
      ),
      // drawer: const MyDrawer(),
      //drawer: DrawerPageWidget(), //抽屉页面
    );
  }
}
