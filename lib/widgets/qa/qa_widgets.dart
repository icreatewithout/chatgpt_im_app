import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatgpt_im/common/global.dart';
import 'package:chatgpt_im/common/time_ago_util.dart';
import 'package:chatgpt_im/models/user_vo.dart';
import 'package:chatgpt_im/routes/forum_deatil.dart';
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
import '../../models/forum/gpt_forum.dart';
import '../../models/result.dart';
import '../../states/LocaleModel.dart';
import 'create_forum_sheet.dart';
import 'grid_image.dart';

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
    setState(() {
      list.insert(0, forum);
    });
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
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
                        return buildSlider();
                      },
                      childCount: 1,
                    ),
                  ),
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
            buildUser(forum, index, localeModel),
            buildDes(forum, index),
            buildImage(forum, index, context, s),
            buildCL(forum, index, s),
          ],
        ),
      ),
    );
  }

  buildUser(GptForum forum, int index, LocaleModel localeModel) {
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
            child: SizedBox(
              child: Row(
                children: [
                  CommonUtils.avatar(forum.userVo!.avatarUrl, w: 25, h: 25),
                  const SizedBox(width: 5),
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

  buildCL(GptForum forum, int index, S s) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
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

  buildSlider() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12, left: 18, right: 18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      constraints: const BoxConstraints(maxHeight: 120),
      child: CarouselSlider(
        options: CarouselOptions(viewportFraction: 1.0, autoPlay: true),
        items: [
          buildSliderItem('欢迎来到OpenGPT社区', '在这里是匿名的、安全的，在使用过程中您的一切信息都会被加密！'),
          buildSliderItem('提示', '如果您在使用中，遇到问题请与我联系：agdhhjfhtdh585@gmail.com！'),
          buildSliderItem('注销账户与信息安全', '您在使用应用时只有社区功能会记录您的信息，您可以联系我们删除!'),
        ],
      ),
    );
  }

  buildSliderItem(String title, String des) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            des,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
