import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:chatgpt_im/common/dio_util.dart';
import 'package:chatgpt_im/common/global.dart';
import 'package:chatgpt_im/models/result.dart';
import 'package:chatgpt_im/states/UserModel.dart';
import 'package:provider/provider.dart';

import '../../common/api.dart';
import '../../common/common_utils.dart';
import '../../generated/l10n.dart';

class AccountQuitOrLogout extends StatefulWidget {
  const AccountQuitOrLogout({super.key});

  @override
  State<AccountQuitOrLogout> createState() => _AccountQuitOrLogoutState();
}

class _AccountQuitOrLogoutState extends State<AccountQuitOrLogout> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _quit(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    try {
      Result result = await DioUtil().get(Api.logout);
      if (result.code == 200) {
        Global.profile.token = null;
        Global.profile.status = false;
        Global.profile.user = null;
        Global.saveProfile();
        if (context.mounted) {
          Provider.of<UserModel>(context, listen: false).quit = null;
        }
        CommonUtils.showToast('success');
      } else {
        CommonUtils.showToast(result.message);
      }
    } catch (_) {
      CommonUtils.showToast('error');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    try {
      Result result = await DioUtil().delete(Api.delAccount);
      if (result.code == 200) {
        Global.profile.token = null;
        Global.profile.status = false;
        Global.profile.user = null;
        Global.saveProfile();
        if (context.mounted) {
          Provider.of<UserModel>(context, listen: false).quit = null;
        }
        CommonUtils.showToast('success');
      } else {
        CommonUtils.showToast(result.message);
      }
    } catch (_) {
      CommonUtils.showToast('error');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel userModel, Widget? child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _quit(context),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(s.logout),
                ),
              ),
              Container(
                height: 0,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.1))),
              ),
              GestureDetector(
                onTap: () => _logout(context),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    s.deleteAccount,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              Visibility(
                visible: _loading,
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: LoadingAnimationWidget.fallingDot(
                        color: Colors.grey, size: 80),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
