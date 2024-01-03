import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../common/api.dart';
import '../common/common_utils.dart';
import '../common/dio_util.dart';
import '../common/time_ago_util.dart';
import '../generated/l10n.dart';
import '../models/forum/gpt_forum.dart';
import '../models/result.dart';
import '../states/LocaleModel.dart';
import '../states/UserModel.dart';
import '../widgets/qa/grid_image.dart';
import '../widgets/ui/open_cn_button.dart';
import 'forum_deatil.dart';

class MyContent extends StatefulWidget {
  static const String path = "/my/content";

  const MyContent({super.key});

  @override
  State<MyContent> createState() => _MyContentState();
}

class _MyContentState extends State<MyContent> {
  final List<dynamic> list = List.of([], growable: true);
  late EasyRefreshController _controller;
  bool isLast = false;
  int pageNum = 1;
  final int pageSize = 10;

  @override
  void initState() {
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> findPage() async {
    Map<String, dynamic>? map = {
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    try {
      Result result = await DioUtil().get(Api.myForumList, data: map);
      if (result.code == 200) {
        List<dynamic> res =
            result.data!['content'].map((e) => GptForum.fromJson(e)).toList();
        if (mounted) {
          setState(() {
            list.addAll(res);
            pageNum++;
            isLast = result.data!['last'];
          });
        }
      } else {
        CommonUtils.showToast(result.message,
            tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
      }
    } catch (e) {
      CommonUtils.showToast(e.toString(),
          tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
    } finally {
      _controller.finishLoad(
          isLast ? IndicatorResult.noMore : IndicatorResult.success);
    }
  }

  Future<void> onRefresh() async {
    if (mounted) {
      setState(() {
        pageNum = 1;
        list.removeRange(0, list.length);
      });
    }
    await findPage();
    _controller.finishRefresh();
    _controller.resetFooter();
  }

  void delete(String id, S s) async {
    OkCancelResult result = await showOkCancelAlertDialog(
        context: context, title: s.hint, message: s.hintDelChat);
    if (result.name == 'ok') {
      try {
        Result result = await DioUtil().delete(Api.delForum + id);
        if (result.code == 200) {
          onRefresh();
        } else {
          CommonUtils.showToast(result.message,
              tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
        }
      } catch (e) {
        CommonUtils.showToast(e.toString(),
            tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(s.myContent, style: const TextStyle(fontSize: 16)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer2<LocaleModel, UserModel>(
        builder: (BuildContext context, LocaleModel localeModel,
            UserModel userModel, Widget? child) {
          return Container(
            height: double.infinity,
            color: Colors.grey.shade100,
            child: EasyRefresh(
              controller: _controller,
              refreshOnStart: true,
              refreshOnStartHeader: buildLoadWidget(),
              onRefresh: () => onRefresh(),
              onLoad: () => findPage(),
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return buildItem(
                            list[index], index, localeModel, context, s);
                      },
                      childCount: list.length,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  buildItem(GptForum forum, int index, LocaleModel localeModel,
      BuildContext context, S s) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .pushNamed(ForumDetail.path, arguments: {'id': forum.id}),
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildUser(forum, index, localeModel, s),
            buildDes(forum, index),
            buildImage(forum, index, context, s),
            buildCL(forum, index, s, localeModel),
          ],
        ),
      ),
    );
  }

  buildUser(GptForum forum, int index, LocaleModel localeModel, S s) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                CommonUtils.avatar(forum.userVo!.avatarUrl,
                    w: 30, h: 30, radius: 5),
                const SizedBox(width: 5),
                Text(forum.userVo!.nickName ?? 'error name.',
                    overflow: TextOverflow.ellipsis)
              ],
            ),
          ),
          GestureDetector(
              onTap: () => delete(forum.id!, s),
              child:
                  const Icon(Icons.delete_forever, size: 19, color: Colors.red))
        ],
      ),
    );
  }

  buildDes(GptForum forum, int index) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(forum.des ?? 'empty text...',
          maxLines: 3, overflow: TextOverflow.ellipsis),
    );
  }

  buildImage(GptForum forum, int index, BuildContext context, S s) {
    if (forum.pictures == null || forum.pictures!.isEmpty) {
      return const SizedBox();
    }
    return GridImage(forum.pictures!, s, context: context).showPicture();
  }

  buildCL(GptForum forum, int index, S s, LocaleModel localeModel) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Text('${forum.like}${s.like}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Text('・',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('${forum.comment}${s.comment}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            TimeAgoUtil(localeModel).format(int.tryParse(forum.time!)),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  buildLoadWidget() {
    return BuilderHeader(
      triggerOffset: 70,
      clamping: true,
      position: IndicatorPosition.above,
      processedDuration: Duration.zero,
      builder: (ctx, state) {
        if (state.mode == IndicatorMode.inactive ||
            state.mode == IndicatorMode.done) {
          return const SizedBox();
        }
        return Container(
          padding: const EdgeInsets.only(bottom: 100),
          width: double.infinity,
          height: state.viewportDimension,
          alignment: Alignment.center,
          child: buildLoadingAnimation(),
        );
      },
    );
  }

  buildLoadingAnimation() {
    return Center(
      child: LoadingAnimationWidget.discreteCircle(color: Colors.red, size: 30),
    );
  }
}
