import 'package:flutter/material.dart';
import 'package:chatgpt_im/common/assets.dart';
import 'package:chatgpt_im/generated/l10n.dart';
import 'package:chatgpt_im/widgets/me/account_quit_logout.dart';
import 'package:chatgpt_im/widgets/me/setting_widgets.dart';
import 'package:chatgpt_im/widgets/me/user_logged_widgets.dart';
import 'package:chatgpt_im/widgets/me/user_not_logged_in_widgets.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../common/global.dart';
import '../../routes/login_page.dart';
import '../../states/UserModel.dart';
import '../qa/create_forum_sheet.dart';
import 'forum_comment.dart';

class MeWidgets extends StatefulWidget {
  const MeWidgets({super.key});

  @override
  State<MeWidgets> createState() => _MeWidgetsState();
}

class _MeWidgetsState extends State<MeWidgets> {
  bool showLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openSheet(BuildContext context) {
    if (!Global.profile.status) {
      Navigator.of(context).pushNamed(LoginPage.path);
      return;
    }

    showModalBottomSheet(
      useSafeArea: false,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ForumSheet(
          type: '2',
          callBack: (val) => {},
        );
      },
    );
  }

  void show(bool b) {
    setState(() {
      showLoading = b;
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
        actions: [
          IconButton(
              onPressed: () => _openSheet(context),
              icon: const Icon(Icons.bug_report))
        ],
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
                          s.mine,
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
                            AccountQuitOrLogout(showLoading: (val) => show(val)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          showLoading
              ? Center(
                  child: LoadingAnimationWidget.fallingDot(
                      color: Colors.red, size: 30),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
