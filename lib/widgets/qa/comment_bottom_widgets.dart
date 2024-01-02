import 'package:chatgpt_im/common/api.dart';
import 'package:chatgpt_im/common/assets.dart';
import 'package:chatgpt_im/common/common_utils.dart';
import 'package:chatgpt_im/common/dio_util.dart';
import 'package:chatgpt_im/models/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../generated/l10n.dart';
import '../../models/forum/gpt_forum.dart';
import '../../models/forum/gpt_forum_comment_vo.dart';
import '../../routes/login_page.dart';

GlobalKey<_ForumCommentBottomBarState> bottomBarGlobalKey = GlobalKey();

class ForumCommentBottomBar extends StatefulWidget {
  const ForumCommentBottomBar({
    super.key,
    required this.callBack,
    required this.id,
    required this.forum,
  });

  final Function callBack;
  final String id;
  final GptForum forum;

  @override
  State<ForumCommentBottomBar> createState() => _ForumCommentBottomBarState();
}

class _ForumCommentBottomBarState extends State<ForumCommentBottomBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String type = '1';
  String? _replayId = null;
  String? _prentId = null;
  String _name = '';
  bool isSub = false;

  bool get isTextEmpty => _controller.text.isEmpty; //输入框是否为空

  @override
  void initState() {
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  ///喜欢推荐
  void _thumbUp(BuildContext context) async {
    try {
      Result result = await DioUtil().post(Api.saveLike + widget.id);
      if (result.code == 200) {
        bool res = result.data;
        setState(() {
          widget.forum.thumb = res;
          widget.forum.like =
              res ? widget.forum.like! + 1 : widget.forum.like! - 1;
        });
      } else {
        if (result.code == 401 && mounted) {
          Navigator.of(context).pushNamed(LoginPage.path);
        } else {
          CommonUtils.showToast(result.message,
              tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
        }
      }
    } catch (e) {
      CommonUtils.showToast(e.toString(),
          tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
    }
  }

  ///提交评论
  void _sub(BuildContext context, S s) async {
    if (_controller.text.isEmpty) {
      CommonUtils.showToast(s.inputComment);
      return;
    }
    setState(() {
      isSub = true;
    });

    Map<String, Object> data = {
      'prentId': _prentId ?? 0,
      'replayUid': _replayId ?? 0,
      'ofId': widget.id,
      'des': _controller.text,
    };

    try {
      Result result = await DioUtil().post(Api.saveComment, data: data);
      if (result.code == 200 && mounted) {
        FocusScope.of(context).unfocus();
        widget.callBack(_prentId, GptForumCommentVo.fromJson(result.data));
        setState(() {
          type = '1';
          _controller.clear();
          _name = s.saveComment;
          _replayId = null;
          _prentId = null;
          widget.forum.comment = widget.forum.comment! + 1;
        });
      } else {
        if (result.code == 401 && mounted) {
          Navigator.of(context).pushNamed(LoginPage.path);
        } else {
          CommonUtils.showToast(result.message,
              tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
        }
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
      isSub = false;
    });
  }

  void setId(String prentId, String name, String replayId, S s) {
    setState(() {
      _prentId = prentId;
      _replayId = replayId;
      _name = '${s.replay}$name';
      _openKeyboard();
    });
  }

  void _openKeyboard() {
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    FocusScope.of(context).requestFocus(_focusNode);
    setState(() {
      type = '2';
    });
  }

  void _setName(S s) {
    setState(() {
      _name = s.saveComment;
    });
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    _setName(s);
    return SafeArea(
      child: Container(
        height: kBottomNavigationBarHeight,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 6),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTextField(context, s),
                    _buildSuffix(s),
                  ],
                ),
              ),
            ),
            _buildRightWidget(context, s),
          ],
        ),
      ),
    );
  }

  _buildTextField(BuildContext context, S s) {
    return Expanded(
      child: TextField(
        controller: _controller,
        maxLength: 1000,
        focusNode: _focusNode,
        keyboardType: TextInputType.multiline,
        maxLines: 10,
        decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            isDense: true,
            hintText: _name,
            counterText: '',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              overflow: TextOverflow.ellipsis,
            )),
        style: const TextStyle(fontSize: 14),
        textInputAction: TextInputAction.done,
        onTap: () => setState(() {
          type = '2';
        }),
        onEditingComplete: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus!.unfocus();
            setState(() {
              type = '1';
              _name = s.saveComment;
              _prentId = null;
              _replayId = null;
            });
          }
        },
      ),
    );
  }

  _buildRightWidget(BuildContext context, S s) {
    if (type == '1') {
      return Expanded(
        flex: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [_buildComment(), _buildLike(context)],
        ),
      );
    } else {
      return _buildSub(context, s);
    }
  }

  _buildComment() {
    return GestureDetector(
      onTap: () => _openKeyboard(),
      child: Row(
        children: [
          Image.asset(Assets.comment, width: 20, height: 20),
          const SizedBox(width: 2),
          Text('${widget.forum.comment ?? '0'}',
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  _buildLike(BuildContext context) {
    return GestureDetector(
      onTap: () => _thumbUp(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.forum.thumb == null || !widget.forum.thumb!
              ? Image.asset(Assets.like, width: 20, height: 20)
              : Image.asset(Assets.liked, width: 20, height: 20),
          const SizedBox(width: 2),
          Text('${widget.forum.like ?? '0'}',
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  _buildSub(BuildContext context, S s) {
    return !isSub
        ? InkWell(
            onTap: () => _sub(context, s),
            child: Container(
              padding: const EdgeInsets.only(left: 20),
              child: Text(s.save, style: const TextStyle(color: Colors.blue)),
            ),
          )
        : Container(
            padding: const EdgeInsets.only(left: 10),
            child: LoadingAnimationWidget.discreteCircle(
                color: Colors.red, size: 20),
          );
  }

  _buildSuffix(S s) {
    if (!isTextEmpty) {
      return SizedBox(
        child: InkWell(
          onTap: () => setState(() {
            type = '1';
            _name = s.saveComment;
            _prentId = null;
            _replayId = null;
            _controller.clear();
          }),
          child: const Icon(Icons.cancel_rounded, size: 18, color: Colors.grey),
        ),
      );
    }
    return const SizedBox();
  }
}
