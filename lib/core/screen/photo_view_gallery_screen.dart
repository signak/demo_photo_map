import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_share_capp/presentation/service/map_marker_service.dart';
import 'package:photo_share_capp/presentation/widget/map/selected_marker_notifier_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../presentation/widget/loading_progress_indicator.dart';
import '../util/logger.dart';

final _currentItemIndexProvider = StateProvider.autoDispose.family<int, int>(
  (ref, initValue) => initValue,
);

class PhotoViewScreen extends HookConsumerWidget {
  PhotoViewScreen({
    super.key,
    this.loadingBuilder,
    this.backgroundDecoration = const BoxDecoration(color: Colors.black),
    this.initialIndex = 0,
    this.scrollDirection = Axis.horizontal,
  }) : pageController =
            PageController(initialPage: initialIndex, keepPage: true);

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final int initialIndex;
  final PageController pageController;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(mapMarkerServiceProvider);
    final currentIndex = ref.watch(_currentItemIndexProvider(initialIndex));
    final currentIndexNotifier =
        ref.read(_currentItemIndexProvider(currentIndex).notifier);
    final selectedMarker = ref.read(selectedMarkerStateProvider)!;

    return Scaffold(
      body: Container(
        decoration: backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: GestureDetector(
          onTap: () => GoRouter.of(context).pop(),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (context, index) {
                  final data = selectedMarker.attrs;
                  return _buildItem(context, service, index, data.recordId,
                      data.photos[index]);
                },
                itemCount: selectedMarker.attrs.photos.length,
                loadingBuilder: loadingBuilder,
                backgroundDecoration: backgroundDecoration,
                pageController: pageController,
                onPageChanged: (index) {
                  currentIndexNotifier.state = index;
                },
                scrollDirection: scrollDirection,
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "${currentIndex + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    decoration: null,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context,
      MapMarkerService service, int index, int recordId, String photoPath) {
    final cacheKey = MapMarkerService.getCacheName(photoPath);
    return PhotoViewGalleryPageOptions.customChild(
      child: FutureBuilder(
        future: service.getImage(recordId, photoPath),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
          } else if (snapshot.hasError) {
            return _ErrorImageWidget(snapshot.error!, null);
          }
          return const LoadingProgressIndicator();
        },
      ),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: cacheKey),
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
