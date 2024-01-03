import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:chatgpt_im/common/calculate_image.dart';
import 'package:chatgpt_im/common/common_utils.dart';
import 'package:chatgpt_im/common/dio_util.dart';
import 'package:chatgpt_im/db/chat_table.dart';
import 'package:chatgpt_im/routes/create/create_images.dart';
import 'package:chatgpt_im/widgets/chat/chat_util.dart';
import 'package:chatgpt_im/widgets/chat/edit_image.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../common/assets.dart';
import '../../db/message_table.dart';
import '../../generated/l10n.dart';
import '../../models/gpt/chat.dart';
import '../../models/gpt/message.dart';
import '../../states/ChatModel.dart';
import '../../states/LocaleModel.dart';

class ImagesMessage extends StatefulWidget {
  static const String path = "/gpt/images";

  const ImagesMessage({super.key, required this.arguments});

  final Map arguments;

  @override
  State<ImagesMessage> createState() => _ImagesMessageState();
}

class _ImagesMessageState extends State<ImagesMessage> {
  final _listenable = IndicatorStateListenable();
  bool _shrinkWrap = false;
  double? _viewportDimension;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isSending = false;
  late Chat _chat;
  late File? _image = null;
  late File? _mask = null;
  final List<dynamic> messages = List.of([], growable: true);

  int _offset = 1;
  int limit = 20;

  String _path = '';

  @override
  void initState() {
    super.initState();
    init();
    _listenable.addListener(_onHeaderChange);
    _focusNode.addListener(() => setState(() {}));
    _textController.addListener(() {
      setState(() {});
    });
  }

  void init() async {
    Chat? chat = await ChatProvider().get(widget.arguments['id']);
    if (chat != null) {
      setState(() {
        _chat = chat;
        _path = '/image/${chat.id}/';
      });
      await findPage(chat.id!, limit, _offset);
    }
  }

  void updateChatInfo() async {
    Chat? chat = await ChatProvider().get(widget.arguments['id']);
    if (chat != null) {
      setState(() {
        _chat = chat;
      });
      OpenAI.apiKey = chat.apiKey ?? '';
    }
  }

  Future<void> findPage(int chatId, int limit, int offset) async {
    List<Message> list =
        await MessageProvider().findPage(chatId, limit, offset);
    if (list.isNotEmpty) {
      setState(() {
        messages.addAll(list);
        _offset = _offset + 1;
      });
    }
  }

  void _onHeaderChange() {
    final state = _listenable.value;
    if (state != null) {
      final position = state.notifier.position;
      _viewportDimension ??= position.viewportDimension;
      final shrinkWrap = state.notifier.position.maxScrollExtent == 0;
      if (_shrinkWrap != shrinkWrap &&
          _viewportDimension == position.viewportDimension) {
        setState(() {
          _shrinkWrap = shrinkWrap;
        });
      }
    }
  }

  void openSelectImageBottom(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return EditImage(
          image: (XFile? file) {
            setState(() {
              _image = File(file!.path);
            });
          },
          mask: (XFile? file) {
            setState(() {
              _mask = File(file!.path);
            });
          },
          imageFile: _image,
          maskFile: _mask,
          delImage: () {
            setState(() {
              _image = null;
            });
          },
          delMask: () {
            setState(() {
              _mask = null;
            });
          },
        );
      },
    );
  }

  void send() async {
    if (_textController.text.isEmpty || isSending) {
      return;
    }
    setState(() {
      isSending = true;
    });
    try {
      OpenAI.apiKey = _chat.apiKey ?? '';
      //保存并显示发送的信息，发起openai请求，生成一条请求信息并显示请求中，接受返回的数据结果，保存返回结果并更新页面显示结果
      Message message = Message(null, _chat.id, '1', _textController.text, '',
          '200', DateTime.now().millisecondsSinceEpoch);

      String prompt = _textController.text;

      ///save sqlite
      Message? res = await MessageProvider().insert(message);
      setState(() {
        _textController.clear();
        _image = null;
        _mask = null;
        messages.insert(0, res);
        jump();

        ///创建临时消息，状态202
        message = Message(null, _chat.id, '2', '', '', '202',
            DateTime.now().millisecondsSinceEpoch);
        messages.insert(0, message);
      });

      late OpenAIImageModel image;

      if ((_image == null && _mask == null) ||
          (_image == null && _mask != null)) {
        image = await OpenAI.instance.image.create(
          model: _chat.model,
          prompt: prompt,
          n: int.tryParse(_chat.n ?? '1'),
          style: ChatUtil.getStyle(_chat.style ?? 'vivid'),
          size: ChatUtil.getSize(_chat.size ?? '1024x1024'),
          responseFormat:
              ChatUtil.getImageFormat(_chat.responseFormat ?? 'url'),
        );
      } else if (_image != null && _mask == null) {
        image = await OpenAI.instance.image.variation(
          model: _chat.model,
          image: _image!,
          n: int.tryParse(_chat.n ?? '1'),
          size: ChatUtil.getSize(_chat.size ?? '1024x1024'),
          responseFormat:
              ChatUtil.getImageFormat(_chat.responseFormat ?? 'url'),
        );
      } else if (_image != null && _mask != null) {
        image = await OpenAI.instance.image.edit(
          prompt: prompt,
          image: _image!,
          mask: _mask,
          n: int.tryParse(_chat.n ?? '1'),
          size: ChatUtil.getSize(_chat.size ?? '1024x1024'),
          responseFormat:
              ChatUtil.getImageFormat(_chat.responseFormat ?? 'url'),
        );
      }

      List<Map<String, dynamic>> images = List.of([], growable: true);

      /// 保存图片到本地在加载，从gpt获取的url带有超时
      for (OpenAIImageData data in image.data) {
        String path = '';
        if (data.haveUrl) {
          Uint8List? bytes = await DioUtil().getBytesByUrl(data.url!);
          if (bytes != null && bytes.isNotEmpty) {
            path = await ChatUtil.saveFile(
                _path, '${DateTime.now().millisecondsSinceEpoch}.png', bytes);
          }
          images.add(
            {
              'path': path,
              'url': data.url,
              'b64Json': data.b64Json,
              'haveUrl': data.haveUrl,
              'revisedPrompt': data.revisedPrompt
            },
          );
        } else if (data.haveB64Json) {
          Uint8List bytes = base64.decode(data.b64Json!);
          path = await ChatUtil.saveFile(
              _path, '${DateTime.now().millisecondsSinceEpoch}.png', bytes);
          images.add(
            {
              'path': path,
              'url': data.url,
              'b64Json': data.b64Json,
              'haveUrl': data.haveUrl,
              'revisedPrompt': data.revisedPrompt
            },
          );
        }

      }
      receive(images.isNotEmpty ? json.encode(images) : 'Empty message...',
          images.isNotEmpty ? '200' : '500');
    } on RequestFailedException catch (e) {
      receive(e.message, '${e.statusCode}');
    } catch (e) {
      receive(e.toString(), '500');
    }
  }

  void receive(String msg, String status) async {
    Message message;
    if (status == '200') {
      message = messages[0];
      message.createTime = DateTime.now().millisecondsSinceEpoch;
      message.message = msg;
      message.status = status;
    } else {
      // 出现错误时生成错误信息存储
      message = Message(null, _chat.id, '2', msg, '', status,
          DateTime.now().millisecondsSinceEpoch);
    }

    ///save sqlite
    Message? res = await MessageProvider().insert(message);
    setState(() {
      messages[0] = res;
      isSending = false;
      jump();
    });
  }

  void jump() {
    Future.delayed(const Duration(milliseconds: 100),
        () => PrimaryScrollController.of(context).jumpTo(0));
  }

  void unFocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    // 键盘是否是弹起状态,弹出且输入完成时收起键盘
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  void deleteChat(BuildContext context, MenuController controller, S s) async {
    controller.close();
    OkCancelResult result = await showOkCancelAlertDialog(
        context: context, title: s.hint, message: s.hintDelChat);
    if (result.name == 'ok') {
      ///删除会话，清除关联数据
      await ChatProvider().delete(_chat.id!);
      List<Chat> chats = await ChatProvider().findList();
      if (context.mounted) {
        Provider.of<ChatModel>(context, listen: false).setChats = chats;
        Navigator.of(context).pop();
      }
    }
  }

  void updateChat(BuildContext context, MenuController controller) async {
    controller.close();
    Navigator.of(context).pushNamed(CreateImages.path,
        arguments: {'id': _chat.id}).then((_) => updateChatInfo());
  }

  @override
  void dispose() {
    _textController.dispose();
    _listenable.removeListener(_onHeaderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.grey.shade100,
        ),
        centerTitle: true,
        title: Text(
          widget.arguments['title'],
          style: const TextStyle(fontSize: 16),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          buildMenuAnchor(s),
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => unFocus(context),
          child: Stack(
            children: [
              Consumer<LocaleModel>(
                builder: (BuildContext context, LocaleModel localeModel,
                    Widget? child) {
                  return EasyRefresh(
                    clipBehavior: Clip.none,
                    onRefresh: () {},
                    onLoad: () async {
                      return await findPage(
                          widget.arguments['id'], limit, _offset);
                    },
                    header: ListenerHeader(
                      listenable: _listenable,
                      triggerOffset: 100000,
                      clamping: false,
                    ),
                    footer: BuilderFooter(
                      triggerOffset: 40,
                      clamping: false,
                      position: IndicatorPosition.above,
                      infiniteOffset: null,
                      processedDuration: Duration.zero,
                      builder: (context, state) {
                        return Stack(
                          children: [
                            SizedBox(
                              height: state.offset,
                              width: double.infinity,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                child: LoadingAnimationWidget.stretchedDots(
                                    color: Colors.red, size: 30),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                    child: Container(
                      padding:
                          const EdgeInsets.only(bottom: 70, left: 8, right: 8),
                      child: CustomScrollView(
                        reverse: true,
                        shrinkWrap: _shrinkWrap,
                        clipBehavior: Clip.none,
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return buildChatMessage(messages[index], s);
                              },
                              childCount: messages.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              buildTextField(context, s),
            ],
          ),
        ),
      ),
    );
  }

  buildChatMessage(Message message, S s) {
    if (message.type == '1') {
      return userMessage(message);
    } else {
      return chatMessage(message, s);
    }
  }

  Widget userMessage(Message message) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(message.message!),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person),
          ),
        ],
      ),
    );
  }

  Widget chatMessage(Message message, S s) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(Assets.ic_launcher_72, width: 46),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: buildChatMessages(message, s),
            ),
          ),
        ],
      ),
    );
  }

  buildChatMessages(Message message, S s) {
    if (message.status != '200') {
      return Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6)),
        child: mdMessage(message.status!, message.message!),
      );
    }

    List<dynamic> images = json.decode(message.message ?? '{}');
    return Column(
      children: [
        ...images.map(
          (image) => Container(
            margin: const EdgeInsets.only(left: 8, bottom: 8),
            child: buildImage(image, s),
          ),
        )
      ],
    );
  }

  buildImage(Map<String, dynamic> data, S s) {
    File file = File(data['path']);
    return CalculateImage.file(file, fileBuilder: (context, snapshot, file) {
      double w = snapshot.data!.width.toDouble() / 5.0;
      double h = snapshot.data!.height.toDouble() / 5.0;
      return GestureDetector(
        onTap: () => ChatUtil.openBottomSheet(context, file, s),
        child: SizedBox(
          height: h,
          width: w,
          child: Image.file(file, width: w, height: h, fit: BoxFit.cover),
        ),
      );
    });
  }

  Widget mdMessage(String status, String? message) {
    if (status == '202') {
      return LoadingAnimationWidget.stretchedDots(color: Colors.red, size: 30);
    }
    return MarkdownBody(
      data: message ?? 'Empty message.',
      selectable: true,
      onTapText: () {},
      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
    );
  }

  buildTextField(BuildContext context, S s) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.grey.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildFileButton(context),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 42),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: ChatUtil.textField(_textController, _focusNode,
                            s.inputContent, () => send())),
                    InkWell(
                        onTap: () => send(),
                        child: Icon(Icons.send, color: Colors.blue.shade300)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildFileButton(BuildContext context) {
    return GestureDetector(
      onTap: () => openSelectImageBottom(context),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.image,
          color: Colors.grey,
          size: 26,
        ),
      ),
    );
  }

  buildMenuAnchor(S s) {
    late MenuController menuController;
    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        menuController = controller;
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_horiz),
        );
      },
      menuChildren: [
        GestureDetector(
          onTap: () => deleteChat(context, menuController, s),
          child: buildMenu(s.delChat, Icons.delete_forever),
        ),
        const PopupMenuDivider(),
        GestureDetector(
          onTap: () => updateChat(context, menuController),
          child: buildMenu(s.updateSetting, Icons.settings),
        ),
      ],
    );
  }

  buildMenu(String name, IconData iconData) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData, color: Colors.grey, size: 18),
          const SizedBox(
            width: 2,
          ),
          Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
