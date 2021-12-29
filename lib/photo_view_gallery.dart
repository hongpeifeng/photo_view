library photo_view_gallery;

import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart'
    show
        LoadingBuilder,
        PhotoView,
        PhotoViewImageScaleEndCallback,
        PhotoViewImageScaleStartCallback,
        PhotoViewImageScaleUpdateCallback,
        PhotoViewImageTapDownCallback,
        PhotoViewImageTapUpCallback,
        ScaleStateCycle;
import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/controller/photo_view_scalestate_controller.dart';
import 'package:photo_view/src/core/photo_view_gesture_detector.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:photo_view/src/utils/photo_view_hero_attributes.dart';

/// A type definition for a [Function] that receives a index after a page change in [PhotoViewGallery]
typedef PhotoViewGalleryPageChangedCallback = void Function(int index);

/// A type definition for a [Function] that defines a page in [PhotoViewGallery.build]
typedef PhotoViewGalleryBuilder = PhotoViewGalleryPageOptions Function(
    BuildContext context, int index);

/// A [StatefulWidget] that shows multiple [PhotoView] widgets in a [PageView]
///
/// Some of [PhotoView] constructor options are passed direct to [PhotoViewGallery] cosntructor. Those options will affect the gallery in a whole.
///
/// Some of the options may be defined to each image individually, such as `initialScale` or `heroAttributes`. Those must be passed via each [PhotoViewGalleryPageOptions].
///
/// Example of usage as a list of options:
/// ```
/// PhotoViewGallery(
///   pageOptions: <PhotoViewGalleryPageOptions>[
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery1.jpg"),
///       heroAttributes: const HeroAttributes(tag: "tag1"),
///     ),
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery2.jpg"),
///       heroAttributes: const HeroAttributes(tag: "tag2"),
///       maxScale: PhotoViewComputedScale.contained * 0.3
///     ),
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery3.jpg"),
///       minScale: PhotoViewComputedScale.contained * 0.8,
///       maxScale: PhotoViewComputedScale.covered * 1.1,
///       heroAttributes: const HeroAttributes(tag: "tag3"),
///     ),
///   ],
///   loadingBuilder: (context, progress) => Center(
///            child: Container(
///              width: 20.0,
///              height: 20.0,
///              child: CircularProgressIndicator(
///                value: _progress == null
///                    ? null
///                    : _progress.cumulativeBytesLoaded /
///                        _progress.expectedTotalBytes,
///              ),
///            ),
///          ),
///   backgroundDecoration: widget.backgroundDecoration,
///   pageController: widget.pageController,
///   onPageChanged: onPageChanged,
/// )
/// ```
///
/// Example of usage with builder pattern:
/// ```
/// PhotoViewGallery.builder(
///   scrollPhysics: const BouncingScrollPhysics(),
///   builder: (BuildContext context, int index) {
///     return PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage(widget.galleryItems[index].image),
///       initialScale: PhotoViewComputedScale.contained * 0.8,
///       minScale: PhotoViewComputedScale.contained * 0.8,
///       maxScale: PhotoViewComputedScale.covered * 1.1,
///       heroAttributes: HeroAttributes(tag: galleryItems[index].id),
///     );
///   },
///   itemCount: galleryItems.length,
///   loadingBuilder: (context, progress) => Center(
///            child: Container(
///              width: 20.0,
///              height: 20.0,
///              child: CircularProgressIndicator(
///                value: _progress == null
///                    ? null
///                    : _progress.cumulativeBytesLoaded /
///                        _progress.expectedTotalBytes,
///              ),
///            ),
///          ),
///   backgroundDecoration: widget.backgroundDecoration,
///   pageController: widget.pageController,
///   onPageChanged: onPageChanged,
/// )
/// ```
class PhotoViewGallery extends StatefulWidget {
  /// Construct a gallery with static items through a list of [PhotoViewGalleryPageOptions].
  const PhotoViewGallery({
    Key? key,
    required List<PhotoViewGalleryPageOptions> this.pageOptions,
    @Deprecated("Use loadingBuilder instead") this.loadingChild,
    this.loadingBuilder,
    this.loadFailedChild,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.onScaleUpdate,
    this.onScaleStart,
    this.onScaleEnd,
    this.scrollDirection = Axis.horizontal,
    this.pageViewAllowImplicitScrolling = true,
    this.customSize,
  })  : _isBuilder = false,
        itemCount = null,
        builder = null,
        super(key: key);

  /// Construct a gallery with dynamic items.
  ///
  /// The builder must return a [PhotoViewGalleryPageOptions].
  const PhotoViewGallery.builder({
    Key? key,
    required int this.itemCount,
    required this.builder,
    @Deprecated("Use loadingBuilder instead") this.loadingChild,
    this.loadingBuilder,
    this.loadFailedChild,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.onScaleUpdate,
    this.onScaleStart,
    this.onScaleEnd,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.pageViewAllowImplicitScrolling = true,
    this.customSize,
  })  : _isBuilder = true,
        pageOptions = null,
        assert(builder != null),
        super(key: key);

  /// A list of options to describe the items in the gallery
  final List<PhotoViewGalleryPageOptions>? pageOptions;

  /// The count of items in the gallery, only used when constructed via [PhotoViewGallery.builder]
  final int? itemCount;

  /// Called to build items for the gallery when using [PhotoViewGallery.builder]
  final PhotoViewGalleryBuilder? builder;

  /// [ScrollPhysics] for the internal [PageView]
  final ScrollPhysics? scrollPhysics;

  /// Mirror to [PhotoView.loadingBuilder]
  final LoadingBuilder? loadingBuilder;

  /// Mirror to [PhotoView.loadingchild]
  final Widget? loadingChild;

  /// Mirror to [PhotoView.loadFailedChild]
  final Widget? loadFailedChild;

  /// Mirror to [PhotoView.backgroundDecoration]
  final Decoration? backgroundDecoration;

  /// Mirror to [PhotoView.gaplessPlayback]
  final bool gaplessPlayback;

  /// Mirror to [PageView.reverse]
  final bool reverse;

  /// An object that controls the [PageView] inside [PhotoViewGallery]
  final PageController? pageController;

  /// An callback to be called on a page change
  final PhotoViewGalleryPageChangedCallback? onPageChanged;

  /// Mirror to [PhotoView.scaleStateChangedCallback]
  final ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback;

  /// Mirror to [PhotoView.enableRotation]
  final bool enableRotation;

  /// Mirror to [PhotoView.customSize]
  final Size? customSize;

  /// The axis along which the [PageView] scrolls. Mirror to [PageView.scrollDirection]
  final Axis scrollDirection;

  final bool _isBuilder;

  final PhotoViewImageScaleStartCallback? onScaleStart;

  final PhotoViewImageScaleUpdateCallback? onScaleUpdate;

  final PhotoViewImageScaleEndCallback? onScaleEnd;

  /// With this flag set to true, when accessibility focus reaches the end of
  /// the current page and user attempts to move it to the next element, focus
  /// will traverse to the next page in the page view.
  final bool pageViewAllowImplicitScrolling;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewGalleryState();
  }
}

class _PhotoViewGalleryState extends State<PhotoViewGallery> {
  PageController? _controller;

  @override
  void initState() {
    _controller = widget.pageController ?? PageController();
    super.initState();
  }

  void scaleStateChangedCallback(PhotoViewScaleState scaleState) {
    if (widget.scaleStateChangedCallback != null) {
      widget.scaleStateChangedCallback!(scaleState);
    }
  }

  int get actualPage {
    return _controller!.hasClients ? _controller!.page!.floor() : 0;
  }

  int? get itemCount {
    if (widget._isBuilder) {
      return widget.itemCount;
    }
    return widget.pageOptions!.length;
  }

  @override
  Widget build(BuildContext context) {
    // Enable corner hit test
    return GestureDetector(
      onScaleUpdate: (details) {
        widget.onScaleUpdate!(context, details, null,
            const PhotoViewControllerValue(position: Offset.zero, rotationFocusPoint: null, scale: null, rotation: null));
      },
      onScaleStart: (details) {
        widget.onScaleStart!(context, details, null,
            const PhotoViewControllerValue(position: Offset.zero, scale: null, rotation: null, rotationFocusPoint: null));
      },
      onScaleEnd: (details) {
        widget.onScaleEnd!(context, details, null,
            const PhotoViewControllerValue(position: Offset.zero, rotationFocusPoint: null, scale: null, rotation: null));
      },
      child: PhotoViewGestureDetectorScope(
        axis: widget.scrollDirection,
        child: PageView.builder(
          reverse: widget.reverse,
          controller: _controller,
          onPageChanged: widget.onPageChanged,
          itemCount: itemCount,
          itemBuilder: _buildItem,
          scrollDirection: widget.scrollDirection,
          physics: widget.scrollPhysics,
          allowImplicitScrolling: widget.pageViewAllowImplicitScrolling,
          pageSnapping: false,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final pageOption = _buildPageOption(context, index);
    final isCustomChild = pageOption.child != null;

    final PhotoView photoView = isCustomChild
        ? PhotoView.customChild(
            key: ObjectKey(index),
            child: pageOption.child,
            childSize: pageOption.childSize,
            backgroundDecoration:
                pageOption.backgroundDecoration ?? widget.backgroundDecoration,
            controller: pageOption.controller,
            scaleStateController: pageOption.scaleStateController,
            customSize: widget.customSize,
            heroAttributes: pageOption.heroAttributes,
            scaleStateChangedCallback: scaleStateChangedCallback,
            enableRotation: widget.enableRotation,
            initialScale: pageOption.initialScale,
            minScale: pageOption.minScale,
            maxScale: pageOption.maxScale,
            scaleStateCycle: pageOption.scaleStateCycle,
            onTapUp: pageOption.onTapUp,
            onTapDown: pageOption.onTapDown,
            onScaleStart: pageOption.onScaleStart,
            onScaleUpdate: pageOption.onScaleUpdate,
            onScaleEnd: pageOption.onScaleEnd,
            gestureDetectorBehavior: pageOption.gestureDetectorBehavior,
            tightMode: pageOption.tightMode,
            filterQuality: pageOption.filterQuality,
            basePosition: pageOption.basePosition,
            holderWiget: pageOption.holderWiget,
            loadResultCallback: pageOption.loadResultCallback,
          )
        : PhotoView(
            key: ObjectKey(index),
            imageProvider: pageOption.imageProvider,
            loadingBuilder: widget.loadingBuilder,
            loadingChild: widget.loadingChild,
            loadFailedChild: widget.loadFailedChild,
            backgroundDecoration:
                pageOption.backgroundDecoration ?? widget.backgroundDecoration,
            controller: pageOption.controller,
            scaleStateController: pageOption.scaleStateController,
            customSize: widget.customSize,
            gaplessPlayback: widget.gaplessPlayback,
            heroAttributes: pageOption.heroAttributes,
            scaleStateChangedCallback: scaleStateChangedCallback,
            enableRotation: widget.enableRotation,
            initialScale: pageOption.initialScale,
            minScale: pageOption.minScale,
            maxScale: pageOption.maxScale,
            scaleStateCycle: pageOption.scaleStateCycle,
            onTapUp: pageOption.onTapUp,
            onTapDown: pageOption.onTapDown,
            onScaleStart: pageOption.onScaleStart,
            onScaleUpdate: pageOption.onScaleUpdate,
            onScaleEnd: pageOption.onScaleEnd,
            gestureDetectorBehavior: pageOption.gestureDetectorBehavior,
            tightMode: pageOption.tightMode,
            filterQuality: pageOption.filterQuality,
            basePosition: pageOption.basePosition,
            holderWiget: pageOption.holderWiget,
            loadResultCallback: pageOption.loadResultCallback,
          );

    return ClipRect(
      child: photoView,
    );
  }

  PhotoViewGalleryPageOptions _buildPageOption(
      BuildContext context, int index) {
    if (widget._isBuilder) {
      return widget.builder!(context, index);
    }
    return widget.pageOptions![index];
  }
}

/// A helper class that wraps individual options of a page in [PhotoViewGallery]
///
/// The [maxScale], [minScale] and [initialScale] options may be [double] or a [PhotoViewComputedScale] constant
///
class PhotoViewGalleryPageOptions {
  PhotoViewGalleryPageOptions(
      {Key? key,
      required ImageProvider<Object> this.imageProvider,
      this.backgroundDecoration,
      this.heroAttributes,
      this.minScale,
      this.maxScale,
      this.initialScale,
      this.controller,
      this.scaleStateController,
      this.basePosition,
      this.scaleStateCycle,
      this.onTapUp,
      this.onTapDown,
      this.onScaleUpdate,
      this.onScaleStart,
      this.onScaleEnd,
      this.holderWiget,
      this.gestureDetectorBehavior,
      this.tightMode,
      this.filterQuality,
      this.loadResultCallback})
      : child = null,
        childSize = null;

  PhotoViewGalleryPageOptions.customChild(
      {required Widget this.child,
      this.backgroundDecoration,
      this.childSize,
      this.heroAttributes,
      this.minScale,
      this.maxScale,
      this.initialScale,
      this.controller,
      this.scaleStateController,
      this.basePosition,
      this.scaleStateCycle,
      this.onTapUp,
      this.onTapDown,
      this.onScaleUpdate,
      this.onScaleStart,
      this.onScaleEnd,
      this.holderWiget,
      this.gestureDetectorBehavior,
      this.tightMode,
      this.filterQuality,
      this.loadResultCallback})
      : imageProvider = null,
        assert(child != null);

  /// Mirror to [PhotoView.imageProvider]
  final ImageProvider? imageProvider;

  final BoxDecoration? backgroundDecoration;

  /// Mirror to [PhotoView.heroAttributes]
  final PhotoViewHeroAttributes? heroAttributes;

  /// Mirror to [PhotoView.minScale]
  final dynamic minScale;

  /// Mirror to [PhotoView.maxScale]
  final dynamic maxScale;

  /// Mirror to [PhotoView.initialScale]
  final dynamic initialScale;

  /// Mirror to [PhotoView.controller]
  final PhotoViewController? controller;

  /// Mirror to [PhotoView.scaleStateController]
  final PhotoViewScaleStateController? scaleStateController;

  /// Mirror to [PhotoView.basePosition]
  final Alignment? basePosition;

  /// Mirror to [PhotoView.child]
  final Widget? child;

  /// Mirror to [PhotoView.childSize]
  final Size? childSize;

  /// Mirror to [PhotoView.scaleStateCycle]
  final ScaleStateCycle? scaleStateCycle;

  /// Mirror to [PhotoView.onTapUp]
  final PhotoViewImageTapUpCallback? onTapUp;

  /// Mirror to [PhotoView.onTapDown]
  final PhotoViewImageTapDownCallback? onTapDown;

  final PhotoViewImageScaleStartCallback? onScaleStart;
  final PhotoViewImageScaleUpdateCallback? onScaleUpdate;
  final PhotoViewImageScaleEndCallback? onScaleEnd;

//  final String imageHolderUrl;
  final Widget? holderWiget;

  /// Mirror to [PhotoView.gestureDetectorBehavior]
  final HitTestBehavior? gestureDetectorBehavior;

  /// Mirror to [PhotoView.tightMode]
  final bool? tightMode;

  /// Quality levels for image filters.
  final FilterQuality? filterQuality;

  /// 加载结果
  final Function(bool)? loadResultCallback;
}
