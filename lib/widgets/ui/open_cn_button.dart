import 'package:flutter/material.dart';

typedef ButtonCallBack = void Function();

class OpenCnButton extends StatefulWidget {
  const OpenCnButton({
    super.key,
    this.callBack,
    this.title,
    this.height,
    this.left,
    this.right,
    this.top,
    this.bottom,
    this.radius,
    this.ls,
    this.fw,
    this.color,
    this.size,
    this.bgColor,
    this.prefix,
    this.suffix,
    this.width,
    this.border,
  });

  final ButtonCallBack? callBack;
  final String? title;
  final double? height;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double? radius;
  final double? ls;
  final double? size;
  final double? width;
  final FontWeight? fw;
  final Color? color;
  final Color? bgColor;

  final Widget? prefix;
  final Widget? suffix;
  final Border? border;

  @override
  State<OpenCnButton> createState() => _OpenCnButtonState();
}

class _OpenCnButtonState extends State<OpenCnButton> {
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
    return GestureDetector(
      onTap: () => widget.callBack!(),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            height: widget.height ?? 40,
            width: widget.width ?? double.infinity,
            margin: EdgeInsets.only(
              left: widget.left ?? 0,
              right: widget.right ?? 0,
              top: widget.top ?? 0,
              bottom: widget.bottom ?? 0,
            ),
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius ?? 10),
              color: widget.bgColor ?? Colors.blue.shade400,
              border: widget.border ??
                  Border.all(width: 0, color: Colors.transparent),
            ),
            child: Text(
              '${widget.title}',
              style: TextStyle(
                  fontSize: widget.size ?? 16,
                  color: widget.color ?? Colors.grey,
                  letterSpacing: widget.ls ?? 0,
                  fontWeight: widget.fw ?? FontWeight.w500,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          Positioned(
            left: widget.left == null ? 10 : widget.left! + 10.0,
            child: Container(
              alignment: Alignment.center,
              height: widget.height ?? 40,
              child: widget.prefix,
            ),
          ),
          Positioned(
            right: widget.right == null ? 10 : widget.right! + 10,
            child: Container(
              alignment: Alignment.center,
              height: widget.height ?? 40,
              child: widget.suffix,
            ),
          ),
        ],
      ),
    );
  }
}
