import 'package:chatgpt_im/routes/login_page.dart';
import 'package:chatgpt_im/routes/my_comment.dart';
import 'package:chatgpt_im/routes/my_content.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:chatgpt_im/common/dio_util.dart';
import 'package:chatgpt_im/common/global.dart';
import 'package:chatgpt_im/models/result.dart';
import 'package:chatgpt_im/states/UserModel.dart';
import 'package:provider/provider.dart';

import '../../common/api.dart';
import '../../common/common_utils.dart';
import '../../generated/l10n.dart';

class ForumComment extends StatefulWidget {
  const ForumComment({super.key});

  @override
  State<ForumComment> createState() => _ForumCommentState();
}

class _ForumCommentState extends State<ForumComment> {
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
    var s = S.of(context);
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel userModel, Widget? child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                    userModel.isLogin ? MyContent.path : LoginPage.path),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(s.myContent),
                ),
              ),
              Container(
                height: 0,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.1))),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                    userModel.isLogin ? MyComment.path : LoginPage.path),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(s.myComment),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
