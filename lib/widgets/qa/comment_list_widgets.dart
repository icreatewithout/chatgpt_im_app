import 'package:chatgpt_im/common/api.dart';
import 'package:chatgpt_im/common/dio_util.dart';
import 'package:chatgpt_im/common/time_ago_util.dart';
import 'package:chatgpt_im/models/result.dart';
import 'package:chatgpt_im/states/LocaleModel.dart';
import 'package:chatgpt_im/states/UserModel.dart';
import 'package:flutter/material.dart';

import '../../common/common_utils.dart';
import '../../models/forum/gpt_forum.dart';
import '../../models/forum/gpt_forum_comment_vo.dart';
import '../../models/user_vo.dart';

GlobalKey<_ForumCommentListState> commentGlobalKey = GlobalKey();

class ForumCommentList extends StatefulWidget {
  const ForumCommentList({
    super.key,
    required this.callBack,
    required this.id,
    required this.forum,
    required this.localeModel,
    required this.userModel,
  });

  final Function callBack;
  final String id;
  final GptForum forum;
  final LocaleModel localeModel;
  final UserModel userModel;

  @override
  State<ForumCommentList> createState() => _ForumCommentListState();
}

class _ForumCommentListState extends State<ForumCommentList> {
  ///评论列表
  int pageNum = 1;
  int pageSize = 10;
  bool haveNext = true;

  ///喜欢列表
  int pageNum1 = 1;
  int pageSize1 = 10;
  bool haveNext1 = true;

  ///子评论列表
  int pageNum2 = 1;
  int pageSize2 = 10;
  bool haveNext2 = true;

  String id = '';

  final List<dynamic> _commentList = List.of([], growable: true);
  final List<dynamic> _likeList = [];

  int _select = 0;
  final Color _unSelectColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _findList();
    _findLikeList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _findLikeList() async {
    Map<String, Object> data = {
      'pageNum': pageNum1,
      'pageSize': pageSize1,
      'ofId': widget.id,
    };
    Result result = await DioUtil().get(Api.likeList, data: data);
    List<dynamic> res =
        result.data!['content'].map((e) => UserVo.fromJson(e)).toList();
    if (res.isNotEmpty && haveNext1) {
      setState(() {
        _likeList.addAll(res);
        pageNum1++;
        haveNext1 = result.data!['last'];
      });
    } else {
      setState(() {
        haveNext1 = false;
      });
    }
  }

  void _findList() async {
    Map<String, Object> data = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'ofId': widget.id,
    };
    Result result = await DioUtil().get(Api.commentList, data: data);
    List<dynamic> res = result.data!['content']
        .map((e) => GptForumCommentVo.fromJson(e))
        .toList();
    if (res.isNotEmpty && haveNext) {
      setState(() {
        _commentList.addAll(res);
        pageNum = pageNum + 1;
        haveNext = result.data!['last'];
      });
    } else {
      setState(() {
        haveNext = false;
      });
    }
  }

  void _findChildren(String prentId, String ofId, int index) async {
    if (id != prentId) {
      setState(() {
        id = prentId;
        pageNum2 = 1;
      });
    }
    Map<String, Object> data = {
      'pageNum': pageNum2,
      'pageSize': pageSize2,
      'ofId': widget.id,
      'prentId': prentId,
    };
    Result result = await DioUtil().get(Api.commentList, data: data);
    List<dynamic> res = result.data!['content']
        .map((e) => GptForumCommentVo.fromJson(e))
        .toList();
    if (res.isNotEmpty && haveNext2) {
      GptForumCommentVo vo = _commentList[index];
      vo.children ??= [];
      setState(() {
        vo.children?.addAll(res);
        pageNum2++;
        haveNext2 = result.data!['last'];
      });
    } else {
      setState(() {
        haveNext2 = false;
      });
    }
  }

  void update(String? prentId, GptForumCommentVo commentVo) async {
    if (commentVo.prentId == '0') {
      setState(() {
        _commentList.insert(0, commentVo);
      });
    } else {
      for (GptForumCommentVo vo in _commentList) {
        if (vo.id == commentVo.prentId) {
          vo.children ??= [];
          setState(() {
            vo.child = vo.child! + 1;
            vo.children?.insert(0, commentVo);
          });
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTab(),
          _list(widget.localeModel),
        ],
      ),
    );
  }

  _buildTab() {
    return Container(
      decoration: const BoxDecoration(
        border: BorderDirectional(
            bottom: BorderSide(width: 0.2, color: Colors.grey)),
      ),
      margin: const EdgeInsets.only(bottom: 2),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _select = 0;
            }),
            child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    bottom: BorderSide(
                        width: 1,
                        color: _select == 0 ? Colors.blue : Colors.transparent),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '评论',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _select == 0 ? Colors.blue : _unSelectColor,
                          fontSize: 16),
                    ),
                  ],
                )),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => setState(() {
              _select = 1;
            }),
            child: Container(
              padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: BorderDirectional(
                  bottom: BorderSide(
                      width: 1,
                      color: _select == 1 ? Colors.blue : Colors.transparent),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '赞',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _select == 1 ? Colors.blue : _unSelectColor,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLikeList(BuildContext context, int index) {
    UserVo vo = _likeList[index];
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Row(
        children: [
          CommonUtils.avatar(vo.avatarUrl, w: 30, h: 30),
          const SizedBox(width: 8),
          Text(vo.nickName!, overflow: TextOverflow.ellipsis)
        ],
      ),
    );
  }

  _list(LocaleModel localeModel) {
    int len = 0;
    if (_select == 0) {
      len = _commentList.length;
    } else {
      len = _likeList.length;
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: len,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      itemBuilder: (BuildContext context, int index) {
        if (_select == 0) {
          if (index + 1 == _commentList.length && haveNext) {
            _findList();
          }
          return _getCommentList(context, index, localeModel);
        } else {
          if (index + 1 == _likeList.length && haveNext1) {
            _findLikeList();
          }
          return _getLikeList(context, index);
        }
      },
    );
  }

  List<Widget> _getChildren(
      List<dynamic> list, LocaleModel localeModel) {
    List<Widget> widgets = [];
    for (var vo in list) {
      widgets.add(
        Container(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonUtils.avatar(vo.user?.avatarUrl, w: 30, h: 30),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: _commentWidget(vo, localeModel)),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  _getCommentList(BuildContext context, int index, LocaleModel localeModel) {
    GptForumCommentVo vo = _commentList[index];
    return GestureDetector(
      onTap: () =>
          widget.callBack(vo.id!, vo.user!.nickName!, vo.user!.id ?? ''),
      child: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonUtils.avatar(vo.user?.avatarUrl, w: 30, h: 30),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _commentWidget(vo, localeModel),
                  Column(
                    children: _getChildren(vo.children ?? [], localeModel),
                  ),
                  _moreWidget(vo, index),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _commentWidget(GptForumCommentVo vo, LocaleModel localeModel) {
    return GestureDetector(
      onTap: () => widget.callBack(vo.prentId == '0' ? vo.id! : vo.prentId!,
          vo.user!.nickName ?? 'error name.', vo.user!.id ?? ''),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _replyWidget(vo),
          const SizedBox(height: 2),
          Text(
            vo.des!,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            TimeAgoUtil(localeModel).format(int.tryParse(vo.time ?? '0')),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  _replyWidget(GptForumCommentVo vo) {
    if (vo.replayUser?.nickName == null || vo.replayUser?.id == vo.user?.id) {
      return Text(
        vo.user!.nickName ?? 'error name.',
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
      );
    }
    return Row(
      children: [
        Text(
          vo.user!.nickName ?? 'error name.',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(
          child: Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 16),
        ),
        Text(
          '${vo.replayUser?.nickName}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  _moreWidget(GptForumCommentVo vo, int index) {
    String txt = '展开更多回复';
    if (vo.children == null || vo.children!.isEmpty) {
      txt = '展开${vo.child}条回复';
    }
    if (vo.child == 0 || vo.children?.length == vo.child) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () => _findChildren(vo.id!, vo.ofId!, index),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(height: 0.5, width: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Text(
            txt,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18)
        ],
      ),
    );
  }
}
