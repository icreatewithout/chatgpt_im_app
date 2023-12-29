import 'package:chatgpt_im/common/common_utils.dart';
import 'package:chatgpt_im/widgets/qa/select_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../common/api.dart';
import '../../common/dio_util.dart';
import '../../models/gpt_forum.dart';
import '../../models/result.dart';

typedef CallBack = void Function(GptForum forum);

class ForumSheet extends StatefulWidget {
  const ForumSheet({
    super.key,
    required this.callBack,
  });

  final CallBack callBack;

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
    _imageHandler =
        ImageHandler(del: (i) => _delete(i), select: () => _selectPicture());
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

  Future<bool?> _selectPicture() async {
    if (_showLoading) {
      return false;
    }
    if (_images.length >= 9) {
      return CommonUtils.showToast('最多只能选9张', tg: ToastGravity.TOP);
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

  void _save(BuildContext context) async {
    if (_showLoading) {
      return;
    }

    if (_controller.text.isEmpty) {
      CommonUtils.showToast('请输入内容', tg: ToastGravity.TOP);
      return;
    }

    setState(() {
      _showLoading = true;
    });

    try {
      if (_images.isNotEmpty) {
        Result result = await DioUtil().uploads(Api.forumUpload, _images);
        debugPrint('uploads file result is $result');
        if (result.code == 200) {
          if (mounted) {
            _saveForum(context, urls: result.data['urls']);
          }
        } else {
          CommonUtils.showToast(result.message,
              tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
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
      'type': '1',
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

  Widget _getTextFieldDes() {
    return TextField(
      controller: _controller,
      maxLength: 1000,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        isDense: true,
        hintText: '写下你的想法...',
        counterText: '',
        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
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

  @override
  Widget build(BuildContext context) {
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
                        _getTextFieldDes(),
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
                            onTap: () => _selectPicture(),
                            child: const Text(
                              '添加图片',
                              style: TextStyle(
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
                      child: const Text(
                        '取消',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _save(context),
                      child: _showLoading
                          ? LoadingAnimationWidget.fallingDot(
                              color: Colors.red, size: 30)
                          : const Text(
                              '发表',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
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
