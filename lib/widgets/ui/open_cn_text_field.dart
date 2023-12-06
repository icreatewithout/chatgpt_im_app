import 'dart:async';

import 'package:flutter/material.dart';

typedef TextFieldCallBack = void Function();

class OpenCnTextField extends StatefulWidget {
  const OpenCnTextField({
    super.key,
    this.callBack,
    this.prefix,
    this.suffix,
    this.height,
    this.top,
    this.bottom,
    this.radius,
    this.fw,
    this.color,
    this.bgColor,
    this.size,
    this.width,
    this.fontSize,
    this.hintText,
    required this.controller,
    this.margin,
    this.padding,
    this.maxLength,
    this.onChanged,
    this.textColor,
    this.cursorColor,
  });

  final TextFieldCallBack? callBack;
  final Widget? prefix;
  final Widget? suffix;
  final FontWeight? fw;
  final Color? color;
  final Color? bgColor;
  final Color? textColor;
  final Color? cursorColor;
  final TextEditingController controller;

  final EdgeInsets? margin;
  final EdgeInsets? padding;

  final double? height;
  final double? top;
  final double? bottom;
  final double? radius;
  final double? size;
  final double? fontSize;
  final double? width;
  final int? maxLength;

  final String? hintText;

  final ValueChanged<String>? onChanged;

  @override
  State<OpenCnTextField> createState() => _OpenCnTextFieldState();
}

class _OpenCnTextFieldState extends State<OpenCnTextField> {
  final FocusNode _focusNode = FocusNode();
  TextEditingController? _controller;

  @override
  void initState() {
    _controller = widget.controller;
    // 焦点获取失去监听
    _focusNode.addListener(() => setState(() {}));
    // 文本输入监听
    _controller?.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          height: widget.height ?? 40,
          child: widget.prefix,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            height: widget.height ?? 40,
            margin: widget.margin ?? EdgeInsets.zero,
            padding: widget.padding ?? EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius ?? 10),
              color: widget.bgColor ?? Colors.blue.shade400,
            ),
            child: TextField(
              cursorColor: widget.cursorColor ?? Colors.grey,
              autofocus: false,
              focusNode: _focusNode,
              maxLength: widget.maxLength ?? 1000,
              controller: _controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: widget.hintText ?? '请输入内容',
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintStyle: TextStyle(
                  fontSize: widget.size ?? 14,
                  color: widget.color ?? Colors.grey,
                ),
              ),
              style: TextStyle(
                fontSize: widget.fontSize ?? 14,
                color: widget.textColor ?? Colors.black,
              ),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              onTap: () {},
              // 输入框内容改变回调
              onChanged: (val) => widget.onChanged!(val),
              onSubmitted: (val) {},
              onEditingComplete: () {
                FocusScopeNode currentFocus = FocusScope.of(context);

                /// 键盘是否是弹起状态,弹出且输入完成时收起键盘
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  FocusManager.instance.primaryFocus!.unfocus();
                }
              },
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          height: widget.height ?? 40,
          child: widget.suffix,
        )
      ],
    );
  }
}
