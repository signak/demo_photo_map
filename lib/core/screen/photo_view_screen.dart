import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_view/photo_view.dart';

import '../../presentation/widget/loading_progress_indicator.dart';
import '../util/logger.dart';

class PhotoViewScreen extends HookConsumerWidget {
  const PhotoViewScreen({
    super.key,
    required this.recordId,
    required this.imageIndex,
    required this.imageName,
    required this.memoryImage,
    this.backgroundDecoration = const BoxDecoration(color: Colors.black),
  });

  final BoxDecoration? backgroundDecoration;
  final int recordId;
  final int imageIndex;
  final String imageName;
  final MemoryImage memoryImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.d('recordId=$recordId, imageIndex=$imageIndex, '
        'imageName=$imageName, image.length=${memoryImage.bytes.length}');

    void back() {
      GoRouter.of(context).pop();
    }

    return Scaffold(
      body: Container(
        padding: EdgeInsets.zero,
        decoration: backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: GestureDetector(
          onTap: () => back(),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              PhotoView(
                imageProvider: memoryImage,
                loadingBuilder: (context, event) =>
                    const LoadingProgressIndicator(),
                errorBuilder: (context, error, stackTrace) =>
                    _ErrorImageWidget(error, stackTrace),
                backgroundDecoration: backgroundDecoration,
                minScale: PhotoViewComputedScale.contained * 0.1,
                maxScale: PhotoViewComputedScale.covered * 4.1,
                heroAttributes: PhotoViewHeroAttributes(tag: imageName),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Colors.white.withAlpha(220))),
                    icon: const Icon(Icons.close),
                    iconSize: 36,
                    onPressed: () => back(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorImageWidget extends StatelessWidget {
  const _ErrorImageWidget(this.error, this.stackTrace);

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    logger.e('error image loading.', error, stackTrace);
    final Widget errImage = Image.asset('assets/image/no_image.jpg');
    return Center(
      child: errImage,
    );
  }
}
