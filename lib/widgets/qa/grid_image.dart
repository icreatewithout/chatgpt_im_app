import 'dart:io';
import 'dart:typed_data';

import 'package:chatgpt_im/common/dio_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

import '../../common/calculate_image.dart';
import '../../common/common_utils.dart';

class GridImage {
  final List<String> images;
  BuildContext? context;

  GridImage(this.images, {this.context});

  showPicture() {
    switch (images.length) {
      case 1:
        return buildSingleImage(images[0]);
      case 2:
        return SizedBox(child: buildGridImage(2, 1, 5, 5), width: 205);
      case 3:
        return buildGridImage(3, 1, 5, 5);
      case 4:
        return SizedBox(child: buildGridImage(2, 1, 5, 5), width: 205);
      case 5:
        return buildGridImage(3, 1, 5, 5);
      case 6:
        return buildGridImage(3, 1, 5, 5);
      case 7:
        return buildGridImage(3, 1, 5, 5);
      case 8:
        return buildGridImage(3, 1, 5, 5);
      case 9:
        return buildGridImage(3, 1, 5, 5);
    }
  }

  buildSingleImage(String url) {
    return CalculateImage.network(
      url,
      networkBuilder: (context, snapshot, url) {
        double w = snapshot.data!.width.toDouble();
        double h = snapshot.data!.height.toDouble();
        if (w > 1000 || h > 1000) {
          w = w / 9;
          h = h / 9;
        }

        if (h > 400) {
          h = h / 2;
          w = w / 1.5;
        }

        if (w > 400) {
          h = h / 1.5;
          w = w / 2;
        }

        return GestureDetector(
          onTap: () => openBottomSheet(context, url),
          child: CommonUtils.image(url, h, w, 0,  BoxFit.cover),
        );
      },
    );
  }


  buildGridImage(int crossAxisCount, double ratio, double cs, double ms,
      {BoxFit? fit}) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, //横轴三个子widget
        childAspectRatio: ratio, //宽高比为1时，子widget
        crossAxisSpacing: cs,
        mainAxisSpacing: ms,
      ),
      children: [
        ...images.map(
          (url) => GestureDetector(
            onTap: () => openBottomSheet(context!, url),
            child: CommonUtils.image(url, 0, 0, 0,  BoxFit.cover),
          ),
        )
      ],
    );
  }

  static openBottomSheet(BuildContext context, String url) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return SafeArea(
            child: Stack(
              children: [
                PhotoViewGestureDetectorScope(
                  axis: Axis.vertical,
                  child: PhotoView(
                    backgroundDecoration:
                        BoxDecoration(color: Colors.black.withAlpha(240)),
                    imageProvider: NetworkImage(url),
                  ),
                ),
                Positioned(
                  right: 5,
                  top: kToolbarHeight,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: kBottomNavigationBarHeight,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.download,
                          color: Colors.white, size: 28),
                      onPressed: () => downloadImage(url, context),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

  static void downloadImage(String url, BuildContext context) async {
    Uint8List? list = await DioUtil().getBytesByUrl(url);
    if (list != null) {
      File file = File.fromUri(Uri.parse(url));
      bool photosStatus =
          await CommonUtils.requestScopePermission(Permission.photos);
      if (photosStatus) {
        final result = await ImageGallerySaver.saveImage(file.readAsBytesSync(),
            quality: 50);
        if (result['isSuccess']) {
          CommonUtils.showToast('已保存');
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        CommonUtils.showToast('相册未授权');
      }
    }
  }
}
