import 'package:chatgpt_im/states/LocaleModel.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class TimeAgoUtil {
  final LocaleModel localeModel;

  static init(){
    timeAgo.setLocaleMessages('zh_CN', timeAgo.ZhCnMessages());
    timeAgo.setLocaleMessages('fr', timeAgo.FrShortMessages());
    timeAgo.setLocaleMessages('de', timeAgo.DeShortMessages());
    timeAgo.setLocaleMessages('it', timeAgo.ItShortMessages());
    timeAgo.setLocaleMessages('ja', timeAgo.JaMessages());
    timeAgo.setLocaleMessages('ko', timeAgo.KoMessages());
    timeAgo.setLocaleMessages('ru', timeAgo.RuShortMessages());
    timeAgo.setLocaleMessages('en', timeAgo.EnShortMessages());
  }

  TimeAgoUtil(this.localeModel);

  String format(int? milliSec) {
    return timeAgo.format(
      DateTime.fromMillisecondsSinceEpoch(milliSec ?? 0),
      locale: localeModel.locale,
      allowFromNow: false,
    );
  }
}
