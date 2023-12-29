import 'package:flutter/material.dart';
import 'package:chatgpt_im/common/assets.dart';
import 'package:chatgpt_im/generated/l10n.dart';
import 'package:chatgpt_im/widgets/me/account_quit_logout.dart';
import 'package:chatgpt_im/widgets/me/setting_widgets.dart';
import 'package:chatgpt_im/widgets/me/user_logged_widgets.dart';
import 'package:chatgpt_im/widgets/me/user_not_logged_in_widgets.dart';
import 'package:provider/provider.dart';

import '../../states/UserModel.dart';

class MeWidgets extends StatefulWidget {
  const MeWidgets({super.key});

  @override
  State<MeWidgets> createState() => _MeWidgetsState();
}

class _MeWidgetsState extends State<MeWidgets> {
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
    var gm = S.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(gm.me, style: const TextStyle(fontSize: 16)),
      ),
      body: Consumer<UserModel>(
        builder: (BuildContext context, UserModel userModel, Widget? child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userModel.isLogin
                    ? const UserLogged()
                    : const UserNotLoggedIn(),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: const Text(
                    '设置',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Setting(),
                Visibility(
                  visible: userModel.isLogin,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: const Text(
                          '账户',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const AccountQuitOrLogout(),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
