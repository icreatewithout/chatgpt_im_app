import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/assets.dart';
import '../../generated/l10n.dart';
import '../../states/UserModel.dart';
import '../ui/open_cn_button.dart';

class UserLogged extends StatefulWidget {
  const UserLogged({super.key});

  @override
  State<UserLogged> createState() => _UserLoggedState();
}

class _UserLoggedState extends State<UserLogged> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      Assets.ic_launcher,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    userModel.user!.nickName ?? 'error name.',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OpenCnButton(
                      title: s.editInfo,
                      radius: 20,
                      height: 36,
                      width: 150,
                      left: 10,
                      right: 10,
                      color: Colors.black,
                      bgColor: Colors.white,
                      size: 14,
                      fw: FontWeight.bold,
                      border:
                          Border.all(color: Colors.grey.shade400, width: 0.5),
                      callBack: () => {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OpenCnButton(
                      title: s.shareMe,
                      radius: 20,
                      height: 36,
                      color: Colors.black,
                      bgColor: Colors.white,
                      size: 14,
                      fw: FontWeight.bold,
                      border:
                          Border.all(color: Colors.grey.shade400, width: 0.5),
                      callBack: () => {},
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
