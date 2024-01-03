import 'package:chatgpt_im/models/user.dart';
import 'package:chatgpt_im/models/user_vo.dart';
import 'package:chatgpt_im/states/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../common/api.dart';
import '../common/common_utils.dart';
import '../common/dio_util.dart';
import '../common/global.dart';
import '../generated/l10n.dart';
import '../models/result.dart';
import '../states/LocaleModel.dart';
import '../widgets/qa/select_image_handler.dart';
import '../widgets/ui/open_cn_button.dart';

class MyInfo extends StatefulWidget {
  static const String path = "/my/info";

  const MyInfo({super.key});

  @override
  State<MyInfo> createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  bool _loading = false;
  late ImageHandler _imageHandler;
  UserVo? userVo = Global.profile.user;
  String? avatarUrl = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _imageHandler =
        ImageHandler(del: (i) => {}, select: () => _selectPicture());
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _selectPicture() async {
    XFile? file = await _imageHandler.selectPicture();
    if (file != null) {
      try {
        String? localPath = await _croppedFile(file);
        if (localPath != null) {
          setState(() {
            _loading = true;
          });
          Result result =
              await DioUtil().upload(Api.uploadAvatar, localPath, file.name);
          debugPrint('${result.code}');
          debugPrint('${result.data}');
          if (result.code == 200) {
            setState(() {
              userVo!.avatarUrl = result.data;
              avatarUrl = result.data;
            });
            CommonUtils.showToast('success');
          } else {
            CommonUtils.showToast(result.message,
                tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
          }
        }
      } catch (e) {
        CommonUtils.showToast(e.toString(),
            tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<String?> _croppedFile(XFile file) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressFormat: ImageCompressFormat.png,
      compressQuality: 100,
    );
    if (croppedFile != null) {
      return croppedFile.path;
    }
    return null;
  }

  void _updateInfo(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    try {
      var data = {
        'path': avatarUrl,
        'nickName': _controller.text,
      };
      Result result = await DioUtil().put(Api.updateInfo, data: data);
      if (result.code == 200) {
        userVo!.nickName = _controller.text;
        Global.saveProfile();
        CommonUtils.showToast('success');
        if (mounted) {
          Provider.of<UserModel>(context, listen: false).setUserVo = userVo!;
          Navigator.of(context).pop();
        }
      } else {
        CommonUtils.showToast(result.message,
            tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
      }
    } catch (e) {
      CommonUtils.showToast(e.toString(),
          tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    return Consumer2<LocaleModel, UserModel>(
      builder: (BuildContext context, LocaleModel localeModel,
          UserModel userModel, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Text(s.editInfo, style: const TextStyle(fontSize: 16)),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Container(
            color: Colors.grey.shade100,
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(18),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => _selectPicture(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s.avatar,
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500)),
                            CommonUtils.image(
                                userVo?.avatarUrl, 50, 50, 100, BoxFit.cover),
                          ],
                        ),
                      ),
                      buildLine(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(s.nickname,
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500)),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.end,
                              controller: _controller,
                              maxLength: 10,
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                isDense: true,
                                hintText: userModel.user?.nickName,
                                counterText: '',
                                hintStyle: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                              textInputAction: TextInputAction.done,
                              onEditingComplete: () {
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus &&
                                    currentFocus.focusedChild != null) {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: kBottomNavigationBarHeight,
                  left: 50,
                  right: 50,
                  child: OpenCnButton(
                    title: s.ok,
                    radius: 20,
                    color: Colors.white,
                    bgColor: Colors.grey.shade600,
                    fw: FontWeight.bold,
                    callBack: () => _updateInfo(context),
                  ),
                ),
                Visibility(
                  visible: _loading,
                  child: Center(
                    child: LoadingAnimationWidget.fallingDot(
                        color: Colors.grey, size: 80),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  buildLanguageItem(String lang, String value, LocaleModel localeModel) {
    return ListTile(
      title: Text(lang),
      trailing: localeModel.locale == value
          ? const Icon(Icons.done, color: Colors.grey)
          : null,
      onTap: () => localeModel.locale = value,
    );
  }

  buildLine() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(width: 0.3, color: Colors.grey))),
    );
  }
}
