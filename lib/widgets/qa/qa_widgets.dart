import 'package:chatgpt_im/common/global.dart';
import 'package:chatgpt_im/models/user_vo.dart';
import 'package:chatgpt_im/routes/login_page.dart';
import 'package:chatgpt_im/states/UserModel.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatgpt_im/common/assets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../common/api.dart';
import '../../common/common_utils.dart';
import '../../common/dio_util.dart';
import '../../generated/l10n.dart';
import '../../models/gpt_forum.dart';
import '../../models/result.dart';
import '../../states/LocaleModel.dart';
import 'create_forum_sheet.dart';

class QaWidgets extends StatefulWidget {
  const QaWidgets({super.key});

  @override
  State<QaWidgets> createState() => _QaWidgetsState();
}

class _QaWidgetsState extends State<QaWidgets> {
  final List<dynamic> list = List.of([], growable: true);
  late EasyRefreshController _controller;
  bool isLast = false;
  int pageNum = 1;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
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
      Result result = await DioUtil().get(Api.forumList, data: map);
      if (result.code == 200) {
        List<dynamic> res =
            result.data!['content'].map((e) => GptForum.fromJson(e)).toList();
        debugPrint('findPage ---------- ${res.length}');

        setState(() {
          list.addAll(res);
          pageNum++;
          isLast = result.data!['last'];
        });
      } else {
        CommonUtils.showToast(result.message,
            tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);
      }
    } catch (e) {
      debugPrint('异常信息 ---------- ${e.toString()}');
      CommonUtils.showToast(e.toString(),
          tg: ToastGravity.TOP, toast: Toast.LENGTH_LONG);

      ///异常信息上报
    } finally {
      _controller.finishLoad(
          isLast ? IndicatorResult.noMore : IndicatorResult.success);
    }
  }

  Future<void> onRefresh() async {
    setState(() {
      pageNum = 1;
      list.removeRange(0, list.length);
    });
    await findPage();
    _controller.finishRefresh();
    _controller.resetFooter();
  }

  void _openSheet(BuildContext context) {
    if (!Global.profile.status) {
      Navigator.of(context).pushNamed(LoginPage.path);
      return;
    }

    showModalBottomSheet(
      useSafeArea: false,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ForumSheet(
          callBack: (val) => _insertInfo(val),
        );
      },
    );
  }

  void _insertInfo(GptForum forum) {
    list.insert(0, forum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(S.of(context).qa, style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: Image.asset(Assets.ic_launcher,
              width: 30, height: 30, fit: BoxFit.cover),
          onPressed: () {},
        ),
        actions: [
          IconButton(
              onPressed: () => _openSheet(context),
              icon: const Icon(Icons.create_outlined,
                  color: Colors.grey, size: 20)),
        ],
      ),
      body: Consumer2<LocaleModel, UserModel>(
        builder: (BuildContext context, LocaleModel localeModel,
            UserModel userModel, Widget? child) {
          return EasyRefresh(
            controller: _controller,
            refreshOnStart: true,
            header: buildLoadHeaderWidget(),
            footer: buildLoadFooterWidget(),
            refreshOnStartHeader: buildLoadWidget(),
            onRefresh: () => onRefresh(),
            onLoad: () => findPage(),
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return buildItem(list[index], index);
                    },
                    childCount: list.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  buildItem(GptForum forum, int index) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
      decoration: BoxDecoration(
        border:
            Border(top: BorderSide(width: 0.3, color: Colors.grey.shade400)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildUser(forum, index),
        ],
      ),
    );
  }

  buildUser(GptForum forum, int index) {

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

  buildLoadHeaderWidget() {
    return MaterialHeader();
  }

  buildLoadFooterWidget() {
    return MaterialFooter();
  }

  buildLoadingAnimation() {
    return LoadingAnimationWidget.discreteCircle(color: Colors.red, size: 30);
  }
}
