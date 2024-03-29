import 'package:chatgpt_im/common/api.dart';
import 'package:chatgpt_im/common/common_utils.dart';
import 'package:chatgpt_im/common/dio_util.dart';
import 'package:chatgpt_im/models/forum/gpt_forum.dart';
import 'package:chatgpt_im/models/result.dart';
import 'package:chatgpt_im/states/UserModel.dart';
import 'package:chatgpt_im/widgets/qa/comment_bottom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../common/time_ago_util.dart';
import '../generated/l10n.dart';
import '../states/LocaleModel.dart';
import '../widgets/qa/comment_list_widgets.dart';
import '../widgets/qa/grid_image.dart';
import '../widgets/ui/open_cn_button.dart';

class ForumDetail extends StatefulWidget {
  static const String path = "/forum/detail";

  const ForumDetail({super.key, required this.arguments});

  final Map arguments;

  @override
  State<ForumDetail> createState() => _ForumDetailState();
}

class _ForumDetailState extends State<ForumDetail> {
  late GptForum forum = GptForum();
  bool isDone = false;
  final ScrollController _scrollController = ScrollController();
  bool showAppbar = false;

  @override
  void initState() {
    _scrollController.addListener(() {
      ///监听滚动位置设置导航栏颜色
      setState(() {
        showAppbar = _scrollController.offset > 70 ? true : false;
      });
    });
    init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void init() async {
    try {
      Result result =
          await DioUtil().get(Api.forumDetail + widget.arguments['id']);
      if (result.code == 200) {
        setState(() {
          forum = GptForum.fromJson(result.data);
          isDone = true;
        });
      } else {
        CommonUtils.showToast(result.message);
      }
    } catch (e) {
      CommonUtils.showToast(e.toString(),
          tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
    }
  }

  void unFocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    // 键盘是否是弹起状态,弹出且输入完成时收起键盘
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    return Consumer2<LocaleModel, UserModel>(
      builder: (BuildContext context, LocaleModel localeModel,
          UserModel userModel, Widget? child) {
        return Scaffold(
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) =>
                _headerSliverBuilder(context, localeModel),
            body: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.shade100,
                  padding:
                      const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                  child: buildView(localeModel, userModel, context, s),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ForumCommentBottomBar(
                    key: bottomBarGlobalKey,
                    callBack: (prentId, vo) =>
                        commentGlobalKey.currentState?.update(prentId, vo),
                    id: forum.id ?? '',
                    forum: forum,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _headerSliverBuilder(
      BuildContext context, LocaleModel localeModel) {
    return [
      _buildSliverAppBar(context, localeModel),
    ];
  }

  ///导航部分渲染
  _buildSliverAppBar(BuildContext context, LocaleModel localeModel) {
    return SliverAppBar(
      //true固定顶部，false随着屏幕滑动
      pinned: true,
      //滚动是否拉伸图片
      stretch: false,
      expandedHeight: 0,
      //展开区域高度
      elevation: 0,
      toolbarHeight: kToolbarHeight,
      //当snap配置为true时，向下滑动页面，SliverAppBar（以及其中配置的flexibleSpace内容）会立即显示出来，
      // 反之当snap配置为false时，向下滑动时，只有当ListView的数据滑动到顶部时，SliverAppBar才会下拉显示出来。
      snap: false,
      leadingWidth: double.infinity,
      leading: buildAppBarUser(forum, localeModel),
    );
  }

  buildAppBarUser(GptForum forum, LocaleModel localeModel) {
    return Container(
      width: double.infinity,
      height: kToolbarHeight,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Row(
        children: [
          GestureDetector(
            child: const Icon(Icons.arrow_back_ios),
            onTap: () => Navigator.of(context).pop(),
          ),
          showAppbar
              ? Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CommonUtils.avatar(forum.userVo!.avatarUrl,
                              w: 30, h: 30, radius: 5),
                          const SizedBox(width: 8),
                          Text(forum.userVo!.nickName ?? 'error name.',
                              overflow: TextOverflow.ellipsis)
                        ],
                      ),
                      Text(
                        TimeAgoUtil(localeModel)
                            .format(int.tryParse(forum.time!)),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  buildView(
      LocaleModel localeModel, UserModel userModel, BuildContext context, S s) {
    return isDone
        ? SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      left: 15, right: 15, top: 10, bottom: 10),
                  margin: const EdgeInsets.only(
                      left: 15, right: 15, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildUser(forum, localeModel),
                      const SizedBox(height: 8),
                      buildText(forum),
                      const SizedBox(height: 8),
                      buildImage(forum, context, s),
                      buildCL(forum, s),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  margin: const EdgeInsets.only(
                      left: 15, right: 15, top: 10, bottom: 10),
                  child: ForumCommentList(
                    key: commentGlobalKey,
                    callBack: (id, name, uid) => bottomBarGlobalKey.currentState
                        ?.setId(id, name, uid, s),
                    id: forum.id ?? '',
                    forum: forum,
                    localeModel: localeModel,
                    userModel: userModel,
                  ),
                ),
              ],
            ),
          )
        : Center(
            child: LoadingAnimationWidget.discreteCircle(
                color: Colors.red, size: 30),
          );
  }

  buildUser(GptForum forum, LocaleModel localeModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            child: Row(
              children: [
                CommonUtils.avatar(forum.userVo!.avatarUrl,
                    w: 30, h: 30, radius: 5),
                const SizedBox(width: 8),
                Text(forum.userVo!.nickName ?? 'error name.',
                    overflow: TextOverflow.ellipsis)
              ],
            ),
          ),
        ),
        Text(
          TimeAgoUtil(localeModel).format(int.tryParse(forum.time!)),
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  buildText(GptForum forum) {
    return Text(forum.des!, style: const TextStyle(fontSize: 16));
  }

  buildImage(GptForum forum, BuildContext context, S s) {
    if (forum.pictures == null || forum.pictures!.isEmpty) {
      return const SizedBox();
    }
    return GridImage(forum.pictures!, s, context: context).showPicture();
  }

  buildCL(GptForum forum, S s) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${forum.like}${s.like}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Text('・', style: TextStyle(fontSize: 12, color: Colors.grey)),
          Text('${forum.comment}${s.comment}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
