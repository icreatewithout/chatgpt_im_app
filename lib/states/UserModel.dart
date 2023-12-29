import 'package:chatgpt_im/models/profile.dart';
import 'package:chatgpt_im/models/user.dart';
import '../common/profile_change_notifier.dart';
import '../models/result.dart';
import '../models/user_vo.dart';

class UserModel extends ProfileChangeNotifier {
  UserVo? get user => profile.user;

  //APP是否登录(如果有用户信息，则证明登录过)
  bool get isLogin => profile.status;

  String? get token => profile.token;

  set setUser(Result result) {
    String token = result.data?['token'];
    UserVo userVo = UserVo.fromJson(result.data?['user']);
    profile.token = token;
    profile.user = userVo;
    profile.status = true;
    notifyListeners();
  }

  set quit(Result? result) {
    profile.status = false;
    profile.token = null;
    profile.user = null;
    notifyListeners();
  }
}
