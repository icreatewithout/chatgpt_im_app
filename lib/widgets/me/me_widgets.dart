import 'package:flutter/material.dart';
import 'package:chatgpt_im/common/assets.dart';
import 'package:chatgpt_im/generated/l10n.dart';
import 'package:chatgpt_im/widgets/me/account_quit_logout.dart';
import 'package:chatgpt_im/widgets/me/setting_widgets.dart';
import 'package:chatgpt_im/widgets/me/user_logged_widgets.dart';
import 'package:chatgpt_im/widgets/me/user_not_logged_in_widgets.dart';
import 'package:provider/provider.dart';

import '../../states/UserModel.dart';
import 'forum_comment.dart';

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
    var s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(s.me, style: const TextStyle(fontSize: 16)),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            color: Colors.grey.shade100,
            child: Consumer<UserModel>(
              builder:
                  (BuildContext context, UserModel userModel, Widget? child) {
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
                        child: Text(
                          '我的',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const ForumComment(),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: Text(
                          s.setting,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                              child: Text(
                                s.account,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            AccountQuitOrLogout(showLoading: () => {}),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
