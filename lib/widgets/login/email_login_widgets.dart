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
  late Timer? _timer = null;
  late String _sendTxt = '发送验证码';
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

  void _countdown() {
    if (_timer != null && _timer!.isActive) {
      return;
    }
    int i = 60;
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      i--;
      if (i == 0) {
        _timer!.cancel();
        setState(() {
          _sendTxt = '发送验证码';
        });
      } else {
        setState(() {
          _sendTxt = '$i 秒';
        });
      }
    });
  }

  void _sendCode() async {
    if (_emailController.text.isEmpty) {
      CommonUtils.showToast('请输入邮箱');
      return;
    }

    if (!CommonUtils.regexEmail(_emailController.text)) {
      CommonUtils.showToast('邮箱格式错误');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      Result result =
          await DioUtil().post('${Api.sendCode}${_emailController.text}');
      if (result.code == 200) {
        CommonUtils.showToast('验证码已发送');
        _countdown();
      } else {
        CommonUtils.showToast(result.message);
      }
    } catch (_) {
      CommonUtils.showToast('操作失败');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _login(BuildContext context) async {
    if (_emailController.text.isEmpty) {
      CommonUtils.showToast('请输入邮箱');
      return;
    }

    if (!CommonUtils.regexEmail(_emailController.text)) {
      CommonUtils.showToast('邮箱格式错误');
      return;
    }

    if (_codeController.text.isEmpty) {
      CommonUtils.showToast('请输入验证码');
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
        UserVo userVo = UserVo.fromJson(result.data?['user']);
        Global.profile.token = token;
        Global.profile.user = userVo;
        Global.profile.status = true;
        Global.saveProfile();
        DioUtil.setToken(token);
        CommonUtils.showToast('登录成功');
        if (context.mounted) {
          Provider.of<UserModel>(context, listen: false).user = userVo;
          Navigator.of(context).pop();
          widget.callBack();
        }
      } else {
        CommonUtils.showToast(result.message);
      }
    } catch (_) {
      CommonUtils.showToast('操作失败');
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

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(
                  height: 40,
                  child: Text(
                    '邮箱登录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                  child: Text('输入邮箱，接收并填入验证码'),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('邮箱'),
                      const SizedBox(height: 8),
                      OpenCnTextField(
                        height: 50,
                        left: 0,
                        right: 0,
                        radius: 10,
                        maxLength: 45,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        bgColor: Colors.grey.shade200,
                        hintText: '请输入邮箱',
                        controller: _emailController,
                      ),
                      const SizedBox(height: 40),
                      _label('验证码'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: OpenCnTextField(
                              height: 45,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              radius: 10,
                              maxLength: 6,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              bgColor: Colors.grey.shade200,
                              hintText: '请输入验证码',
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
                              callBack: () => _sendCode(),
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
                title: '验证',
                left: 50,
                right: 50,
                radius: 20,
                color: Colors.white,
                bgColor: Colors.grey.shade600,
                fw: FontWeight.bold,
                callBack: () => _login(context),
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
