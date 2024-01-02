import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:chatgpt_im/common/api.dart';
import 'package:chatgpt_im/common/common_utils.dart';
import 'package:chatgpt_im/common/dio_util.dart';
import 'package:chatgpt_im/common/global.dart';
import 'package:chatgpt_im/models/result.dart';
import 'package:chatgpt_im/models/user_vo.dart';
import 'package:chatgpt_im/states/UserModel.dart';
import 'package:chatgpt_im/widgets/ui/open_cn_button.dart';
import 'package:chatgpt_im/widgets/ui/open_cn_text_field.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';

typedef CallBack = void Function();

class EmailLoginPage extends StatefulWidget {
  static const String path = "/email/login";

  const EmailLoginPage({super.key, required this.callBack});

  final CallBack callBack;

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Timer? _timer = null;
  String _sendTxt = '';
  bool _isSending = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _codeController.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  void _countdown(S s) {
    if (_timer != null && _timer!.isActive) {
      return;
    }
    int i = 60;
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      i--;
      if (i == 0) {
        _timer!.cancel();
        setState(() {
          _sendTxt = s.sendCode;
          _isSending = false;
        });
      } else {
        setState(() {
          _sendTxt = '$i 秒';
        });
      }
    });
  }

  void _sendCode(S s) async {
    if (_isSending) {
      return;
    }

    if (_emailController.text.isEmpty) {
      CommonUtils.showToast(s.inputEmail);
      return;
    }

    if (!CommonUtils.regexEmail(_emailController.text)) {
      CommonUtils.showToast(s.emailErr);
      return;
    }

    setState(() {
      _loading = true;
      _isSending = true;
    });

    try {
      Result result =
          await DioUtil().post('${Api.sendCode}${_emailController.text}');
      if (result.code == 200) {
        _countdown(s);
        CommonUtils.showToast(s.sendDone);
      } else {
        CommonUtils.showToast(result.message);
      }
    } catch (_) {
      CommonUtils.showToast('error');
    } finally {
      setState(() {
        _loading = false;
        _isSending = false;
      });
    }
  }

  void _login(BuildContext context, S s) async {
    if (_emailController.text.isEmpty) {
      CommonUtils.showToast(s.inputEmail);
      return;
    }

    if (!CommonUtils.regexEmail(_emailController.text)) {
      CommonUtils.showToast(s.emailErr);
      return;
    }

    if (_codeController.text.isEmpty) {
      CommonUtils.showToast(s.inputCode);
      return;
    }

    setState(() {
      _loading = true;
    });
    Result result;
    try {
      result = await DioUtil()
          .post('${Api.login}${_emailController.text}/${_codeController.text}');
      if (result.code == 200) {
        String token = result.data?['token'];
        DioUtil.setToken(token);
        CommonUtils.showToast('success');
        if (context.mounted) {
          Provider.of<UserModel>(context, listen: false).setUser = result;
          Navigator.of(context).pop();
          widget.callBack();
        }
      } else {
        CommonUtils.showToast(result.message);
      }
    } catch (_) {
      CommonUtils.showToast('error');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _label(String title) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        text: title,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
        children: const <TextSpan>[
          TextSpan(
            text: ' *',
            style: TextStyle(fontSize: 14, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _setTxt(S s) {
    setState(() {
      _sendTxt = s.sendCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    _setTxt(s);
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  child: Text(
                    s.emailLogin,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: Text(s.emailHint),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(s.email),
                      const SizedBox(height: 8),
                      OpenCnTextField(
                        height: 50,
                        radius: 10,
                        maxLength: 45,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: s.inputEmail,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 40),
                      _label(s.code),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: OpenCnTextField(
                              height: 45,
                              bottom: 0,
                              radius: 10,
                              maxLength: 6,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              bgColor: Colors.grey.shade200,
                              hintText: s.inputCode,
                              controller: _codeController,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: OpenCnButton(
                              title: _sendTxt,
                              left: 10,
                              right: 0,
                              radius: 10,
                              color: Colors.white,
                              size: 14,
                              height: 45,
                              bgColor: Colors.grey.shade600,
                              callBack: () => _sendCode(s),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 180)
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight,
              child: OpenCnButton(
                title: s.verify,
                left: 50,
                right: 50,
                radius: 20,
                color: Colors.white,
                bgColor: Colors.grey.shade600,
                fw: FontWeight.bold,
                callBack: () => _login(context, s),
              ),
            ),
            Visibility(
              visible: _loading,
              child: Center(
                child: LoadingAnimationWidget.fallingDot(
                  color: Colors.grey,
                  size: 80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
