import 'package:chatgpt_im/models/user.dart';
import '../common/profile_change_notifier.dart';
import '../models/user_vo.dart';

class UserModel extends ProfileChangeNotifier {
  UserVo? get user => profile.user;

  //APP是否登录(如果有用户信息，则证明登录过)
  bool get isLogin => profile.status;

  set user(UserVo? user) {
    profile.status = true;
    profile.user = user;
    profile.token = null;
    notifyListeners();
  }

  set quit(UserVo? user) {
    profile.status = false;
    profile.token = null;
    profile.user = null;
    notifyListeners();
  }
}
