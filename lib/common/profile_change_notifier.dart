import 'package:flutter/material.dart';
import '../models/profile.dart';
import './global.dart';

class ProfileChangeNotifier extends ChangeNotifier {
  Profile get profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile(); //保存profile变更
    super.notifyListeners(); //通知依赖的widget更新
  }
}
