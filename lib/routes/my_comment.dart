import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:chatgpt_im/common/assets.dart';
import 'package:chatgpt_im/models/forum/gpt_forum_comment_vo.dart';
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
import '../widgets/ui/open_cn_button.dart';
import 'forum_deatil.dart';

class MyComment extends StatefulWidget {
  static const String path = "/my/comment";

  const MyComment({super.key});

  @override
  State<MyComment> createState() => _MyCommentState();
}

class _MyCommentState extends State<MyComment> {
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
      Result result = await DioUtil().get(Api.myCommentList, data: map);
      if (result.code == 200) {
        List<dynamic> res = result.data!['content']
            .map((e) => GptForumCommentVo.fromJson(e))
            .toList();
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
        Result result = await DioUtil().delete(Api.delComment + id);
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
        title: Text(s.myComment, style: const TextStyle(fontSize: 16)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
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

  buildItem(GptForumCommentVo vo, int index, LocaleModel localeModel,
      BuildContext context, S s) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildUser(vo, index, localeModel, s),
          const SizedBox(height: 5),
          Text(vo.des!),
          const SizedBox(height: 5),
          buildReplayUser(vo, index, localeModel, s),
        ],
      ),
    );
  }

  buildUser(GptForumCommentVo vo, int index, LocaleModel localeModel, S s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CommonUtils.avatar(vo.user!.avatarUrl, w: 30, h: 30, radius: 5),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vo.user!.nickName ?? 'error name.',
                  overflow: TextOverflow.ellipsis),
              Text(
                TimeAgoUtil(localeModel).format(int.tryParse(vo.time!)),
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        GestureDetector(
            onTap: () => delete(vo.id!, s),
            child:
                const Icon(Icons.delete_forever, size: 19, color: Colors.red))
      ],
    );
  }

  buildReplayUser(
      GptForumCommentVo vo, int index, LocaleModel localeModel, S s) {
    if (vo.replayUser == null) {
      return const SizedBox();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(Assets.reply, width: 18, height: 18),
        const SizedBox(width: 6),
        Row(
          children: [
            CommonUtils.avatar(vo.replayUser!.avatarUrl,
                w: 16, h: 16, radius: 4),
            const SizedBox(width: 6),
            Text(vo.replayUser!.nickName ?? 'error name.',
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis),
          ],
        )
      ],
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
