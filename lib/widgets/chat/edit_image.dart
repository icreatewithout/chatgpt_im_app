import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/common_utils.dart';
import '../ui/open_cn_button.dart';

class EditImage extends StatefulWidget {
  const EditImage({
    super.key,
    required this.image,
    required this.mask,
    this.imageFile,
    this.maskFile,
    required this.delImage,
    required this.delMask,
  });

  final Function(XFile? file) image;
  final Function(XFile? file) mask;
  final File? imageFile;
  final File? maskFile;
  final Function delImage;
  final Function delMask;

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  late File? _image;
  late File? _mask;

  @override
  void initState() {
    setState(() {
      _image = widget.imageFile;
      _mask = widget.maskFile;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void delImage() {
    setState(() {
      _image = null;
    });
    widget.delImage();
  }

  void delMask() {
    setState(() {
      _mask = null;
    });
    widget.delMask();
  }

  void callBackImage(XFile? file) {
    setState(() {
      _image = File(file!.path);
    });
    widget.image(file);
  }

  void callBackMask(XFile? file) {
    setState(() {
      _mask = File(file!.path);
    });
    widget.mask(file);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.grey),
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            bottom: kMinInteractiveDimension,
            child: OpenCnButton(
              color: Colors.white,
              bgColor: Colors.grey.shade500,
              callBack: () => Navigator.pop(context),
              title: '完成',
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Column(
              children: [
                const Center(child: Text('创建编辑或变体')),
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30, top: 30),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: selectImage(
                          'Image',
                          callBackImage,
                          _image,
                          delImage,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 1,
                        child: selectImage(
                          'Mask',
                          callBackMask,
                          _mask,
                          delMask,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  selectImage(String title, Function(XFile? file) callBack, File? file,
      Function() delImage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        file == null
            ? Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade200,
                ),
                child: Center(
                  child: IconButton(
                      onPressed: () => CommonUtils.selectImage(callBack),
                      icon: const Icon(Icons.image)),
                ),
              )
            : Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey.shade200,
                    ),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                      height: 60,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => delImage(),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  )
                ],
              ),
      ],
    );
  }
}
