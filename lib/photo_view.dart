library photo_view;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/controller/photo_view_scalestate_controller.dart';
import 'package:photo_view/src/core/photo_view_core.dart';
import 'package:photo_view/src/photo_view_computed_scale.dart';
import 'package:photo_view/src/photo_view_default_widgets.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:photo_view/src/utils/photo_view_hero_attributes.dart';
import 'package:photo_view/src/utils/photo_view_utils.dart';

export 'src/controller/photo_view_controller.dart';
export 'src/controller/photo_view_scalestate_controller.dart';
export 'src/core/photo_view_gesture_detector.dart'
    show PhotoViewGestureDetectorScope;
export 'src/painting/cache_network_image.dart';
export 'src/photo_view_computed_scale.dart';
export 'src/photo_view_scale_state.dart';
export 'src/utils/photo_view_hero_attributes.dart';

/// A [StatefulWidget] that contains all the photo view rendering elements.
///
/// Sample code to use within an image:
///
/// ```
/// PhotoView(
///  imageProvider: imageProvider,
///  loadingBuilder: (context, progress) => Center(
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
///  backgroundDecoration: BoxDecoration(color: Colors.black),
///  gaplessPlayback: false,
///  customSize: MediaQuery.of(context).size,
///  heroAttributes: const HeroAttributes(
///   tag: "someTag",
///   transitionOnUserGestures: true,
///  ),
///  scaleStateChangedCallback: this.onScaleStateChanged,
///  enableRotation: true,
///  controller:  controller,
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: PhotoViewComputedScale.contained,
///  basePosition: Alignment.center,
///  scaleStateCycle: scaleStateCycle
/// );
/// ```
///
/// You can customize to show an custom child instead of an image:
///
/// ```
/// PhotoView.customChild(
///  child: Container(
///    width: 220.0,
///    height: 250.0,
///    child: const Text(
///      "Hello there, this is a text",
///    )
///  ),
///  childSize: const Size(220.0, 250.0),
///  backgroundDecoration: BoxDecoration(color: Colors.black),
///  gaplessPlayback: false,
///  customSize: MediaQuery.of(context).size,
///  heroAttributes: const HeroAttributes(
///   tag: "someTag",
///   transitionOnUserGestures: true,
///  ),
///  scaleStateChangedCallback: this.onScaleStateChanged,
///  enableRotation: true,
///  controller:  controller,
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: PhotoViewComputedScale.contained,
///  basePosition: Alignment.center,
///  scaleStateCycle: scaleStateCycle
/// );
/// ```
/// The [maxScale], [minScale] and [initialScale] options may be [double] or a [PhotoViewComputedScale] constant
///
/// Sample using [maxScale], [minScale] and [initialScale]
///
/// ```
/// PhotoView(
///  imageProvider: imageProvider,
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: PhotoViewComputedScale.contained * 1.1,
/// );
/// ```
///
/// [customSize] is used to define the viewPort size in which the image will be
/// scaled to. This argument is rarely used. By default is the size that this widget assumes.
///
/// The argument [gaplessPlayback] is used to continue showing the old image
/// (`true`), or briefly show nothing (`false`), when the [imageProvider]
/// changes.By default it's set to `false`.
///
/// To use within an hero animation, specify [heroAttributes]. When
/// [heroAttributes] is specified, the image provider retrieval process should
/// be sync.
///
/// Sample using hero animation:
/// ```
/// // screen1
///   ...
///   Hero(
///     tag: "someTag",
///     child: Image.asset(
///       "assets/large-image.jpg",
///       width: 150.0
///     ),
///   )
/// // screen2
/// ...
/// child: PhotoView(
///   imageProvider: AssetImage("assets/large-image.jpg"),
///   heroAttributes: const HeroAttributes(tag: "someTag"),
/// )
/// ```
///
/// **Note: If you don't want to the zoomed image do not overlaps the size of the container, use [ClipRect](https://docs.flutter.io/flutter/widgets/ClipRect-class.html)**
///
/// ## Controllers
///
/// Controllers, when specified to PhotoView widget, enables the author(you) to listen for state updates through a `Stream` and change those values externally.
///
/// While [PhotoViewScaleStateController] is only responsible for the `scaleState`, [PhotoViewController] is responsible for all fields os [PhotoViewControllerValue].
///
/// To use them, pass a instance of those items on [controller] or [scaleStateController];
///
/// Since those follows the standard controller pattern found in widgets like [PageView] and [ScrollView], whoever instantiates it, should [dispose] it afterwards.
///
/// Example of [controller] usage, only listening for state changes:
///
/// ```
/// class _ExampleWidgetState extends State<ExampleWidget> {
///
///   PhotoViewController controller;
///   double scaleCopy;
///
///   @override
///   void initState() {
///     super.initState();
///     controller = PhotoViewController()
///       ..outputStateStream.listen(listener);
///   }
///
///   @override
///   void dispose() {
///     controller.dispose();
///     super.dispose();
///   }
///
///   void listener(PhotoViewControllerValue value){
///     setState((){
///       scaleCopy = value.scale;
///     })
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: <Widget>[
///         Positioned.fill(
///             child: PhotoView(
///               imageProvider: AssetImage("assets/pudim.png"),
///               controller: controller,
///             );
///         ),
///         Text("Scale applied: $scaleCopy")
///       ],
///     );
///   }
/// }
/// ```
///
/// An example of [scaleStateController] with state changes:
/// ```
/// class _ExampleWidgetState extends State<ExampleWidget> {
///
///   PhotoViewScaleStateController scaleStateController;
///
///   @override
///   void initState() {
///     super.initState();
///     scaleStateController = PhotoViewScaleStateController();
///   }
///
///   @override
///   void dispose() {
///     scaleStateController.dispose();
///     super.dispose();
///   }
///
///   void goBack(){
///     scaleStateController.scaleState = PhotoViewScaleState.originalSize;
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: <Widget>[
///         Positioned.fill(
///             child: PhotoView(
///               imageProvider: AssetImage("assets/pudim.png"),
///               scaleStateController: scaleStateController,
///               );
///         ),
///         FlatButton(
///           child: Text("Go to original size"),
///           onPressed: goBack,
///         );
///       ],
///     );
///   }
/// }
/// ```
///
class PhotoView extends StatefulWidget {
  /// Creates a widget that displays a zoomable image.
  ///
  /// To show an image from the network or from an asset bundle, use their respective
  /// image providers, ie: [AssetImage] or [NetworkImage]
  ///
  /// Internally, the image is rendered within an [Image] widget.
  PhotoView({
    Key? key,
    required this.imageProvider,
    @Deprecated("Use loadingBuilder instead") this.loadingChild,
    this.loadingBuilder,
    this.loadFailedChild,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onScaleUpdate,
    this.onScaleStart,
    this.onScaleEnd,
    this.holderWiget,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.loadResultCallback,
  })  : child = null,
        childSize = null,
        super(key: key);

  /// Creates a widget that displays a zoomable child.
  ///
  /// It has been created to resemble [PhotoView] behavior within widgets that aren't an image, such as [Container], [Text] or a svg.
  ///
  /// Instead of a [imageProvider], this constructor will receive a [child] and a [childSize].
  ///
  PhotoView.customChild({
    Key? key,
    required this.child,
    this.childSize,
    this.backgroundDecoration,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onScaleUpdate,
    this.onScaleStart,
    this.onScaleEnd,
    this.holderWiget,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.loadResultCallback,
  })  : loadFailedChild = null,
        imageProvider = null,
        gaplessPlayback = false,
        loadingBuilder = null,
        loadingChild = null,
        super(key: key);

  /// Given a [imageProvider] it resolves into an zoomable image widget using. It
  /// is required
  final ImageProvider? imageProvider;

  /// You should now use loadingBuilder(context, progress) => widget
  final Widget? loadingChild;

  /// While [imageProvider] is not resolved, [loadingBuilder] is called by [PhotoView]
  /// into the screen, by default it is a centered [CircularProgressIndicator]
  final LoadingBuilder? loadingBuilder;

  /// Show loadFailedChild when the image failed to load
  final Widget? loadFailedChild;

  /// Changes the background behind image, defaults to `Colors.black`.
  final Decoration? backgroundDecoration;

  /// This is used to continue showing the old image (`true`), or briefly show
  /// nothing (`false`), when the `imageProvider` changes. By default it's set
  /// to `false`.
  final bool gaplessPlayback;

  /// Attributes that are going to be passed to [PhotoViewCore]'s
  /// [Hero]. Leave this property undefined if you don't want a hero animation.
  final PhotoViewHeroAttributes? heroAttributes;

  /// Defines the size of the scaling base of the image inside [PhotoView],
  /// by default it is `MediaQuery.of(context).size`.
  final Size? customSize;

  /// A [Function] to be called whenever the scaleState changes, this happens when the user double taps the content ou start to pinch-in.
  final ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback;

  /// A flag that enables the rotation gesture support
  final bool enableRotation;

  /// The specified custom child to be shown instead of a image
  final Widget? child;

  /// The size of the custom [child]. [PhotoView] uses this value to compute the relation between the child and the container's size to calculate the scale value.
  final Size? childSize;

  /// Defines the maximum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic maxScale;

  /// Defines the minimum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic minScale;

  /// Defines the initial size in which the image will be assume in the mounting of the component, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic initialScale;

  /// A way to control PhotoView transformation factors externally and listen to its updates
  final PhotoViewControllerBase? controller;

  /// A way to control PhotoViewScaleState value externally and listen to its updates
  final PhotoViewScaleStateController? scaleStateController;

  /// The alignment of the scale origin in relation to the widget size. Default is [Alignment.center]
  final Alignment? basePosition;

  /// Defines de next [PhotoViewScaleState] given the actual one. Default is [defaultScaleStateCycle]
  final ScaleStateCycle? scaleStateCycle;

  /// A pointer that will trigger a tap has stopped contacting the screen at a
  /// particular location.
  final PhotoViewImageTapUpCallback? onTapUp;

  /// A pointer that might cause a tap has contacted the screen at a particular
  /// location.
  final PhotoViewImageTapDownCallback? onTapDown;

  final PhotoViewImageScaleStartCallback? onScaleStart;

  final PhotoViewImageScaleUpdateCallback? onScaleUpdate;

  final PhotoViewImageScaleEndCallback? onScaleEnd;

//  final String imageHolderUrl;
  final Widget? holderWiget;

  /// [HitTestBehavior] to be passed to the internal gesture detector.
  final HitTestBehavior? gestureDetectorBehavior;

  /// Enables tight mode, making background container assume the size of the image/child.
  /// Useful when inside a [Dialog]
  final bool? tightMode;

  /// Quality levels for image filters.
  final FilterQuality? filterQuality;

  final Function(bool)? loadResultCallback;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewState();
  }
}

class _PhotoViewState extends State<PhotoView> {
  Size? _childSize;
  bool? _loading;
  bool? _loadFailed;
  ImageChunkEvent? _imageChunkEvent;

  late bool _controlledController;
  PhotoViewControllerBase? _controller;

  late bool _controlledScaleStateController;
  PhotoViewScaleStateController? _scaleStateController;

  Future<ImageInfo> _getImage() {
    final Completer completer = Completer<ImageInfo>();
    final ImageStream stream = widget.imageProvider!.resolve(
      const ImageConfiguration(),
    );
    final listener = ImageStreamListener((
      ImageInfo info,
      bool synchronousCall,
    ) {
      if (!completer.isCompleted) {
        completer.complete(info);
        if (mounted) {
          final setupCallback = () {
            _childSize = Size(
              info.image.width.toDouble(),
              info.image.height.toDouble(),
            );
            widget.loadResultCallback?.call(true);
            _loading = false;
            _imageChunkEvent = null;
          };
          synchronousCall ? setupCallback() : setState(setupCallback);
        }
      }
    }, onChunk: (event) {
      if (mounted) {
        setState(() => _imageChunkEvent = event);
      }
    }, onError: (exception, stackTrace) {
      widget.imageProvider!.evict();
      if (!mounted) {
        return;
      }
      setState(() {
        widget.loadResultCallback?.call(false);
        _loadFailed = true;
      });
      FlutterError.reportError(
        FlutterErrorDetails(exception: exception, stack: stackTrace),
      );
    });
    stream.addListener(listener);
    completer.future.then((_) {
      stream.removeListener(listener);
    });
    return completer.future.then((value) => value as ImageInfo);
  }

  @override
  void initState() {
    super.initState();
    if (widget.child == null) {
      _getImage();
    } else {
      _childSize = widget.childSize;
      _loading = false;
      _imageChunkEvent = null;
    }
    if (widget.controller == null) {
      _controlledController = true;
      _controller = PhotoViewController();
    } else {
      _controlledController = false;
      _controller = widget.controller;
    }

    if (widget.scaleStateController == null) {
      _controlledScaleStateController = true;
      _scaleStateController = PhotoViewScaleStateController();
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController;
    }

    _scaleStateController!.outputScaleStateStream.listen(scaleStateListener);
  }

  @override
  void didUpdateWidget(PhotoView oldWidget) {
    if (oldWidget.childSize != widget.childSize && widget.childSize != null) {
      setState(() {
        _childSize = widget.childSize;
      });
    }
    if (widget.controller == null) {
      if (!_controlledController) {
        _controlledController = true;
        _controller = PhotoViewController();
      }
    } else {
      _controlledController = false;
      _controller = widget.controller;
    }

    if (widget.scaleStateController == null) {
      if (!_controlledScaleStateController) {
        _controlledScaleStateController = true;
        _scaleStateController = PhotoViewScaleStateController();
      }
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_controlledController) {
      _controller!.dispose();
    }
    if (_controlledScaleStateController) {
      _scaleStateController!.dispose();
    }
    super.dispose();
  }

  void scaleStateListener(PhotoViewScaleState scaleState) {
    if (widget.scaleStateChangedCallback != null) {
      widget.scaleStateChangedCallback!(_scaleStateController!.scaleState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loadFailed == true
        ? _buildLoadFailed()
        : LayoutBuilder(
            builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              return widget.child == null
                  ? _buildImage(context, constraints)!
                  : _buildCustomChild(context, constraints);
            },
          );
  }

  Widget _buildCustomChild(BuildContext context, BoxConstraints constraints) {
//    widget.loadResultCallback(true);
    final _computedOuterSize = widget.customSize ?? constraints.biggest;

    final scaleBoundaries = ScaleBoundaries(
      widget.minScale ?? 0.0,
      widget.maxScale ?? double.infinity,
      widget.initialScale ?? PhotoViewComputedScale.contained,
      _computedOuterSize,
      _childSize ?? constraints.biggest,
    );
//    print('scaleBoundaries :${scaleBoundaries.minScale}, ${scaleBoundaries.maxScale} , ${scaleBoundaries.initialScale}, ${scaleBoundaries.outerSize}, ${scaleBoundaries.childSize}');
    return PhotoViewCore.customChild(
      customChild: widget.child,
      backgroundDecoration: widget.backgroundDecoration,
      enableRotation: widget.enableRotation,
      heroAttributes: widget.heroAttributes,
      controller: _controller,
      scaleStateController: _scaleStateController,
      scaleStateCycle: widget.scaleStateCycle ?? defaultScaleStateCycle,
      basePosition: widget.basePosition ?? Alignment.center,
      scaleBoundaries: scaleBoundaries,
      onTapUp: widget.onTapUp,
      onTapDown: widget.onTapDown,
      onScaleStart: widget.onScaleStart,
      onScaleUpdate: widget.onScaleUpdate,
      onScaleEnd: widget.onScaleEnd,
      gestureDetectorBehavior: widget.gestureDetectorBehavior,
      tightMode: widget.tightMode ?? false,
      filterQuality: widget.filterQuality ?? FilterQuality.none,
      canScale: false,
    );
  }

  Widget? _buildImage(BuildContext context, BoxConstraints constraints) {
    return widget.heroAttributes == null
        ? _buildAsync(context, constraints)
        : _buildSync(context, constraints);
  }

  Widget _buildAsync(BuildContext context, BoxConstraints constraints) {
    return FutureBuilder(
        future: _getImage(),
        builder: (BuildContext context, AsyncSnapshot<ImageInfo> info) {
          if (info.hasData) {
            return _buildWrapperImage(context, constraints);
          } else {
            return _buildLoading()!;
          }
        });
  }

  Widget? _buildSync(BuildContext context, BoxConstraints constraints) {
    if (_loading == null) {
      return _buildLoading();
    }
    return _buildWrapperImage(context, constraints);
  }

  Widget _buildWrapperImage(BuildContext context, BoxConstraints constraints) {
    final _computedOuterSize = widget.customSize ?? constraints.biggest;
    var minScale = widget.minScale ?? 0.0;
    var maxScale = widget.maxScale ?? double.infinity;

    /// 长度全屏逻辑判断
    var initialScale = widget.initialScale;
    final isVerticalLongPhoto = _childSize!.height / _childSize!.width > 2.5;
    if (isVerticalLongPhoto) {
      initialScale = PhotoViewComputedScale.covered;
      maxScale = widget.maxScale ?? PhotoViewComputedScale.covered;
      minScale = PhotoViewComputedScale.covered;
    }

    final scaleBoundaries = ScaleBoundaries(
      minScale,
      maxScale,
      initialScale ?? PhotoViewComputedScale.contained,
      _computedOuterSize,
      _childSize,
    );

    return PhotoViewCore(
      imageProvider: widget.imageProvider,
      backgroundDecoration: widget.backgroundDecoration,
      gaplessPlayback: widget.gaplessPlayback,
      enableRotation: widget.enableRotation,
      heroAttributes: widget.heroAttributes,
      basePosition: widget.basePosition ??
          (isVerticalLongPhoto ? Alignment.topCenter : Alignment.center),
      controller: _controller,
      scaleStateController: _scaleStateController,
      scaleStateCycle: widget.scaleStateCycle ?? defaultScaleStateCycle,
      scaleBoundaries: scaleBoundaries,
      onTapUp: widget.onTapUp,
      onTapDown: widget.onTapDown,
      onScaleStart: widget.onScaleStart,
      onScaleUpdate: widget.onScaleUpdate,
      onScaleEnd: widget.onScaleEnd,
      gestureDetectorBehavior: widget.gestureDetectorBehavior,
      tightMode: widget.tightMode ?? false,
      filterQuality: widget.filterQuality ?? FilterQuality.none,
    );
  }

  Widget? _buildLoading() {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context, _imageChunkEvent);
    }

    if (widget.loadingChild != null) {
      return widget.loadingChild;
    }

    return GestureDetector(
      onTapUp: (details) => widget.onTapUp!(context, details, null),
      onScaleUpdate: (details) {
        widget.onScaleUpdate!(
            context,
            details,
            null,
            const PhotoViewControllerValue(
                position: Offset.zero,
                rotationFocusPoint: null,
                rotation: null,
                scale: null));
      },
      onScaleStart: (details) {
        widget.onScaleStart!(
            context,
            details,
            null,
            const PhotoViewControllerValue(
                position: Offset.zero,
                rotation: null,
                scale: null,
                rotationFocusPoint: null));
      },
      onScaleEnd: (details) {
        widget.onScaleEnd!(
            context,
            details,
            null,
            const PhotoViewControllerValue(
                position: Offset.zero,
                rotation: null,
                rotationFocusPoint: null,
                scale: null));
      },
      child: PhotoViewDefaultLoading(
        event: _imageChunkEvent,
        holderWiget: widget.holderWiget,
      ),
    );
  }

  Widget _buildLoadFailed() {
    return GestureDetector(
      onTapUp: (details) => widget.onTapUp!(context, details, null),
      onScaleUpdate: (details) {
        widget.onScaleUpdate!(
            context,
            details,
            null,
            const PhotoViewControllerValue(
                position: Offset.zero,
                rotation: null,
                scale: null,
                rotationFocusPoint: null));
      },
      onScaleStart: (details) {
        widget.onScaleStart!(
            context,
            details,
            null,
            const PhotoViewControllerValue(
                position: Offset.zero,
                rotationFocusPoint: null,
                scale: null,
                rotation: null));
      },
      onScaleEnd: (details) {
        widget.onScaleEnd!(
            context,
            details,
            null,
            const PhotoViewControllerValue(
                position: Offset.zero,
                rotation: null,
                scale: null,
                rotationFocusPoint: null));
      },
      child: widget.loadFailedChild ??
          PhotoViewDefaultError(
              holderWiget: widget.holderWiget, onFailReload: resetLoadFailed),
    );
  }

  ///加载失败后，重置状态，重新加载图片
  void resetLoadFailed() {
    setState(() {
      _loadFailed = false;
    });
  }
}

/// The default [ScaleStateCycle]
PhotoViewScaleState defaultScaleStateCycle(PhotoViewScaleState actual) {
  switch (actual) {
    case PhotoViewScaleState.initial:
      return PhotoViewScaleState.covering;
    case PhotoViewScaleState.covering:
      return PhotoViewScaleState.originalSize;
    case PhotoViewScaleState.originalSize:
      return PhotoViewScaleState.initial;
    case PhotoViewScaleState.zoomedIn:
    case PhotoViewScaleState.zoomedOut:
      return PhotoViewScaleState.initial;
    default:
      return PhotoViewScaleState.initial;
  }
}

/// A type definition for a [Function] that receives the actual [PhotoViewScaleState] and returns the next one
/// It is used internally to walk in the "doubletap gesture cycle".
/// It is passed to [PhotoView.scaleStateCycle]
typedef ScaleStateCycle = PhotoViewScaleState Function(
  PhotoViewScaleState actual,
);

/// A type definition for a callback when the user taps up the photoview region
typedef PhotoViewImageTapUpCallback = Function(
  BuildContext context,
  TapUpDetails details,
  PhotoViewControllerValue? controllerValue,
);

/// A type definition for a callback when the user taps down the photoview region
typedef PhotoViewImageTapDownCallback = Function(
  BuildContext context,
  TapDownDetails details,
  PhotoViewControllerValue controllerValue,
);

typedef PhotoViewImageScaleUpdateCallback = Function(
  BuildContext context,
  ScaleUpdateDetails details,
  Offset? offset,
  PhotoViewControllerValue? controllerValue,
);

typedef PhotoViewImageScaleStartCallback = Function(
  BuildContext context,
  ScaleStartDetails details,
  Offset? offset,
  PhotoViewControllerValue? controllerValue,
);

typedef PhotoViewImageScaleEndCallback = Function(
  BuildContext context,
  ScaleEndDetails details,
  Offset? offset,
  PhotoViewControllerValue? controllerValue,
);

/// A type definition for a callback to show a widget while a image is loading, a [ImageChunkEvent] is passed to inform progress
typedef LoadingBuilder = Widget Function(
  BuildContext context,
  ImageChunkEvent? event,
);
