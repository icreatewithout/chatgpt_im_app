import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum CalculateImageType { file, memory, url, assets }

typedef AsyncAssetImageWidgetBuilder<T> = Widget Function(
    BuildContext context, AsyncSnapshot<T> snapshot, String path);

typedef AsyncNetworkImageWidgetBuilder<T> = Widget Function(
    BuildContext context, AsyncSnapshot<T> snapshot, String url);

typedef AsyncFileImageWidgetBuilder<T> = Widget Function(
    BuildContext context, AsyncSnapshot<T> snapshot, File file);

typedef AsyncMemoryImageWidgetBuilder<T> = Widget Function(
    BuildContext context, AsyncSnapshot<T> snapshot, Uint8List bytes);

class CalculateImage extends StatelessWidget {
  final String? path;
  final String? url;
  final File? file;
  final Uint8List? bytes;

  final AsyncAssetImageWidgetBuilder<ui.Image>? assetsBuilder;
  final AsyncNetworkImageWidgetBuilder<ui.Image>? networkBuilder;
  final AsyncFileImageWidgetBuilder<ui.Image>? fileBuilder;
  final AsyncMemoryImageWidgetBuilder<ui.Image>? memoryBuilder;

  final ImageProvider provider;
  final CalculateImageType calculateImageType;

  CalculateImage.network(
    this.url, {
    super.key,
    @required this.networkBuilder,
    this.path,
    this.file,
    this.bytes,
    this.assetsBuilder,
    this.fileBuilder,
    this.memoryBuilder,
  })  : provider = NetworkImage(url!),
        calculateImageType = CalculateImageType.url;

  CalculateImage.file(
    this.file, {
    super.key,
    @required this.fileBuilder,
    this.path,
    this.url,
    this.bytes,
    this.assetsBuilder,
    this.networkBuilder,
    this.memoryBuilder,
  })  : provider = FileImage(file!),
        calculateImageType = CalculateImageType.file;

  CalculateImage.asset(
    this.path, {
    super.key,
    @required this.assetsBuilder,
    this.url,
    this.file,
    this.bytes,
    this.networkBuilder,
    this.fileBuilder,
    this.memoryBuilder,
  })  : provider = AssetImage(path!),
        calculateImageType = CalculateImageType.assets;

  CalculateImage.memory(
    this.bytes, {
    super.key,
    required this.memoryBuilder,
    this.path,
    this.url,
    required this.file,
    this.assetsBuilder,
    this.networkBuilder,
    this.fileBuilder,
  })  : provider = MemoryImage(bytes!),
        calculateImageType = CalculateImageType.memory;

  late ImageStreamListener listener;
  @override
  Widget build(BuildContext context) {
    final ImageConfiguration config = createLocalImageConfiguration(context);
    final Completer<ui.Image> completer = Completer<ui.Image>();
    final ImageStream stream = provider.resolve(config);
    listener = ImageStreamListener(
      (ImageInfo image, bool sync) {
        completer.complete(image.image);
        stream.removeListener(listener);
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        stream.removeListener(listener);
        FlutterError.reportError(FlutterErrorDetails(
          context: ErrorDescription('image failed to precache'),
          library: 'image resource service',
          exception: exception,
          stack: stackTrace,
          silent: true,
        ));
      },
    );
    stream.addListener(listener);

    return FutureBuilder(
      future: completer.future,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (snapshot.hasData) {
          if (calculateImageType == CalculateImageType.file) {
            return fileBuilder!(context, snapshot, file!);
          } else if (calculateImageType == CalculateImageType.memory) {
            return memoryBuilder!(context, snapshot, bytes!);
          } else if (calculateImageType == CalculateImageType.assets) {
            return assetsBuilder!(context, snapshot, path!);
          } else {
            return networkBuilder!(context, snapshot, url!);
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
