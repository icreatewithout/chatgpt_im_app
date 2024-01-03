import 'package:chatgpt_im/common/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../common/assets.dart';
import '../generated/l10n.dart';
import '../widgets/login/email_login_widgets.dart';
import '../widgets/ui/open_cn_button.dart';
import 'about_us.dart';

class LoginPage extends StatefulWidget {
  static const String path = "/login";

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toEmailLoginPage(BuildContext context) {
    Navigator.of(context).pushNamed(EmailLoginPage.path);
  }

  void showEmailLoginSheet(BuildContext context, S s) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedPadding(
            padding: EdgeInsets.only(
              // 下面这一行是重点
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            duration: Duration.zero,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: EmailLoginPage(
                s: s,
                callBack: () => {
                  Navigator.of(context).pop(),
                },
              ),
            ));
      },
    );
  }

  void _toPrivacyPage(BuildContext context) {
    Navigator.of(context).pushNamed(AboutUsPage.path);
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.ic_launcher,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "OpenGPT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OpenCnButton(
                        title: s.emailLogin,
                        left: 50,
                        right: 50,
                        bottom: 10,
                        radius: 20,
                        bgColor: Colors.grey.shade600,
                        color: Colors.white,
                        fw: FontWeight.bold,
                        size: 15,
                        callBack: () => showEmailLoginSheet(context, s),
                      ),
                      OpenCnButton(
                        title: s.googleLogin,
                        left: 50,
                        right: 50,
                        bottom: 10,
                        radius: 20,
                        color: Colors.white,
                        fw: FontWeight.bold,
                        callBack: () => CommonUtils.showToast('disable'),
                        prefix: Image.asset(
                          Assets.google,
                          width: 20,
                        ),
                      ),
                      OpenCnButton(
                        title: s.xLogin,
                        left: 50,
                        right: 50,
                        bottom: 10,
                        radius: 20,
                        color: Colors.white,
                        fw: FontWeight.bold,
                        callBack: () => CommonUtils.showToast('disable'),
                        prefix: Image.asset(
                          Assets.twitter,
                          width: 20,
                        ),
                      ),
                      OpenCnButton(
                        title: s.facebookLogin,
                        left: 50,
                        right: 50,
                        bottom: 10,
                        radius: 20,
                        color: Colors.white,
                        fw: FontWeight.bold,
                        callBack: () => CommonUtils.showToast('disable'),
                        prefix: Image.asset(
                          Assets.facebook,
                          width: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(s.loginAnonymously),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 40,
              right: 40,
              bottom: kBottomNavigationBarHeight,
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: s.hintText1,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: '<<${s.hintText2}>>',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _toPrivacyPage(context),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
