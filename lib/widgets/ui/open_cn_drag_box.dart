import 'package:flutter/material.dart';

class DragMoveBox extends StatefulWidget {
  final Widget child;
  const DragMoveBox({
    super.key,
    required this.child,
  });
  @override
  State<DragMoveBox> createState() => _DragMoveBoxState();
}

class _DragMoveBoxState extends State<DragMoveBox> {
  final GlobalKey _mykey = GlobalKey();
  //当前位移(有活动区域限制时，鼠标超过边界后当前位移不等于总位移，此时总位移可以确保回到边界内鼠标与控件的相对位置不变)
  final _offset = ValueNotifier<Offset>(Offset.zero);
  //总位移
  var _unlimtedOffset = Offset.zero;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _offset,
      builder:
      //采用transform变换实现拖动
          (context, offset, widget) => Transform.translate(
        key: _mykey,
        offset: offset,
        child: GestureDetector(
          child: this.widget.child,
          onPanUpdate: (detail) {
            var off = _unlimtedOffset = _unlimtedOffset + detail.delta;
            //拖动区域为父控件，去掉则不受限制，但拖出父控件会被遮挡无法点击。
            //获取父控件大小
            RenderBox? parentRenderBox = _mykey.currentContext
                ?.findAncestorRenderObjectOfType<RenderObject>() as RenderBox?;
            final screenSize = parentRenderBox?.size;
            //获取控件大小
            final mySize = _mykey.currentContext?.size;
            final renderBox =
            _mykey.currentContext?.findRenderObject() as RenderBox?;
            //获取控件当前位置
            var originOffset = renderBox?.localToGlobal(Offset.zero);
            if (originOffset != null) {
              originOffset = parentRenderBox?.globalToLocal(originOffset);
            }
            if (screenSize == null || mySize == null || originOffset == null) {
              return;
            }
            //计算不超出父控件区域
            if (off.dx < -originOffset.dx) {
              off = Offset(-originOffset.dx, off.dy);
            } else if (off.dx >
                screenSize.width - mySize.width - originOffset.dx) {
              off = Offset(
                screenSize.width - mySize.width - originOffset.dx,
                off.dy,
              );
            }
            if (off.dy < -originOffset.dy) {
              off = Offset(off.dx, -originOffset.dy);
            } else if (off.dy >
                screenSize.height - mySize.height - originOffset.dy) {
              off = Offset(
                off.dx,
                screenSize.height - mySize.height - originOffset.dy,
              );
            }
            //现在活动区域为父控件 --end
            _offset.value = off;
          },
        ),
      ),
    );
  }
}
