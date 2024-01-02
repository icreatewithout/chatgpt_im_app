import 'package:flutter/material.dart';
import 'package:chatgpt_im/common/assets.dart';
import 'package:chatgpt_im/routes/login_page.dart';
import 'package:chatgpt_im/widgets/ui/open_cn_button.dart';

import '../../generated/l10n.dart';

class UserNotLoggedIn extends StatefulWidget {
  const UserNotLoggedIn({super.key});

  @override
  State<UserNotLoggedIn> createState() => _UserNotLoggedInState();
}

class _UserNotLoggedInState extends State<UserNotLoggedIn> {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  Assets.ic_launcher,
                  width: 50,
                  height: 50,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                s.loginTip,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OpenCnButton(
            title: s.login,
            radius: 20,
            color: Colors.black,
            bgColor: Colors.white,
            size: 14,
            fw: FontWeight.w500,
            border: Border.all(color: Colors.grey.shade400, width: 0.5),
            callBack: () => Navigator.of(context).pushNamed(LoginPage.path),
          ),
        ],
      ),
    );
  }
}
