import 'package:chatgpt_im/common/common_utils.dart';
import 'package:chatgpt_im/routes/login_page.dart';
import 'package:chatgpt_im/widgets/qa/select_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../common/api.dart';
import '../../common/dio_util.dart';
import '../../generated/l10n.dart';
import '../../models/forum/gpt_forum.dart';
import '../../models/result.dart';

typedef CallBack = void Function(GptForum forum);

class ForumSheet extends StatefulWidget {
  const ForumSheet({
    super.key,
    required this.callBack,
    required this.type,
  });

  final CallBack callBack;
  final String type;

  @override
  State<ForumSheet> createState() => _ForumSheetState();
}

class _ForumSheetState extends State<ForumSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<XFile> _images = List.of([], growable: true);
  late ImageHandler _imageHandler;
  bool _showBottomBtn = true;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ///删除图片
  void _delete(int i) {
    setState(() {
      _images.removeAt(i);
      if (_images.isEmpty) {
        _showBottomBtn = true;
      }
    });
  }

  Future<bool?> _selectPicture(S s) async {
    if (_showLoading) {
      return false;
    }
    if (_images.length >= 9) {
      return CommonUtils.showToast(s.limitSize, tg: ToastGravity.TOP);
    }
    XFile? file = await _imageHandler.selectPicture();
    if (file != null) {
      setState(() {
        _showBottomBtn = false;
        _images.insert(_images.length, file);
      });
    }
    return null;
  }

  void _save(BuildContext context, S s) async {
    if (_showLoading) {
      return;
    }

    if (_controller.text.isEmpty) {
      CommonUtils.showToast(s.inputContent, tg: ToastGravity.TOP);
      return;
    }

    setState(() {
      _showLoading = true;
    });

    try {
      if (_images.isNotEmpty) {
        Result result = await DioUtil().uploads(Api.forumUpload, _images);
        if (result.code == 200) {
          if (mounted) {
            _saveForum(context, urls: result.data['urls']);
          }
        } else {
          if (result.code == 401 && mounted) {
            Navigator.of(context).pushNamed(LoginPage.path);
          } else {
            CommonUtils.showToast(result.message,
                tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
          }
          closeLoading();
        }
      } else {
        _saveForum(context);
      }
    } catch (e) {
      CommonUtils.showToast(e.toString(),
          tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
      closeLoading();
    }
  }

  void _saveForum(BuildContext context, {List<dynamic>? urls}) async {
    Map<String, dynamic>? map = {
      'type': widget.type,
      'des': _controller.text,
    };

    if (urls != null) {
      map['pictures'] = urls.join(',');
    }

    try {
      Result result = await DioUtil().post(Api.forum, data: map);
      if (result.code == 200) {
        widget.callBack(GptForum.fromJson(result.data));
        if (mounted) {
          Navigator.of(context).pop();
          CommonUtils.showToast('success',
              tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
        }
      } else {
        CommonUtils.showToast(result.message,
            tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
      }
      closeLoading();
    } catch (e) {
      CommonUtils.showToast(e.toString(),
          tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
      closeLoading();
    }
  }

  void closeLoading() {
    setState(() {
      _showLoading = false;
    });
  }

  Widget _getTextFieldDes(S s) {
    return TextField(
      controller: _controller,
      maxLength: 1000,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        isDense: true,
        hintText: widget.type == '1' ? s.hintText : s.feedback,
        counterText: '',
        hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
      onEditingComplete: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
    );
  }

  void _cancel(BuildContext context) {
    if (mounted && !_showLoading) {
      Navigator.of(context).pop();
    }
  }

  void _init(S s) {
    _imageHandler =
        ImageHandler(del: (i) => _delete(i), select: () => _selectPicture(s));
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    _init(s);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: kToolbarHeight,
              bottom: kBottomNavigationBarHeight +
                  MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _getTextFieldDes(s),
                        _imageHandler.showPicture(_images),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Visibility(
            visible: _showBottomBtn,
            child: Positioned(
              bottom: kBottomNavigationBarHeight +
                  MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          left: 8, right: 12, bottom: 7, top: 7),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Colors.blue, size: 16),
                          GestureDetector(
                            onTap: () => _selectPicture(s),
                            child: Text(
                              s.addImage,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blue,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: kBottomNavigationBarHeight,
                padding: const EdgeInsets.only(left: 18, right: 18),
                decoration: const BoxDecoration(
                    border: BorderDirectional(
                        top: BorderSide(width: 0.1, color: Colors.grey))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _cancel(context),
                      child: Text(
                        s.cancel,
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _save(context, s),
                      child: _showLoading
                          ? LoadingAnimationWidget.fallingDot(
                              color: Colors.red, size: 30)
                          : Text(
                              s.save,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
