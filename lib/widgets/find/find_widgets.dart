import 'package:chatgpt_im/states/LocaleModel.dart';
import 'package:chatgpt_im/widgets/find/menu_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/message.dart';
import '../../states/MessageModel.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class FindWidgets extends StatefulWidget {
  const FindWidgets({super.key});

  @override
  State<FindWidgets> createState() => _FindWidgetsState();
}

class _FindWidgetsState extends State<FindWidgets> {
  @override
  void initState() {
    timeAgo.setLocaleMessages('zh_CN', timeAgo.ZhCnMessages());
    timeAgo.setLocaleMessages('fr', timeAgo.FrShortMessages());
    timeAgo.setLocaleMessages('de', timeAgo.DeShortMessages());
    timeAgo.setLocaleMessages('it', timeAgo.ItShortMessages());
    timeAgo.setLocaleMessages('ja', timeAgo.JaMessages());
    timeAgo.setLocaleMessages('ko', timeAgo.KoMessages());
    timeAgo.setLocaleMessages('ru', timeAgo.RuShortMessages());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(S.of(context).find),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: MenuWidgets(),
          ),
        ],
      ),
      body: Consumer2<MessageModel, LocaleModel>(
        builder: (BuildContext context, MessageModel messageModel,
            LocaleModel localeModel, Widget? child) {
          return ListView(
            shrinkWrap: true,
            children: [
              ...messageModel.messages.map((e) => buildItem(e, localeModel)),
            ],
          );
        },
      ),
    );
  }

  buildItem(Message message, LocaleModel localeModel) {
    MenuItem? menuItem = MenuItems.getMenuItem(message.type);
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(menuItem!.path,
          arguments: {'id': message.id, 'title': message.name}),
      child: Container(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(width: 0.2, color: Colors.grey.shade400)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              menuItem?.icon,
              size: 40,
              color: Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        message.name ?? '...',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        timeAgo.format(
                          DateTime.fromMillisecondsSinceEpoch(
                              message.createTime ?? 0),
                          locale: localeModel.locale,
                          allowFromNow: true,
                        ),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.des ?? '...',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}