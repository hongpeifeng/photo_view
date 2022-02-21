import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import 'package:photo_view/photo_view.dart'
    show
        PhotoViewHeroAttributes,
        PhotoViewImageScaleEndCallback,
        PhotoViewImageScaleStartCallback,
        PhotoViewImageScaleUpdateCallback,
        PhotoViewImageTapDownCallback,
        PhotoViewImageTapUpCallback,
        PhotoViewScaleState,
        ScaleStateCycle;
import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/controller/photo_view_controller_delegate.dart';
import 'package:photo_view/src/controller/photo_view_scalestate_controller.dart';
import 'package:photo_view/src/utils/photo_view_utils.dart';
import 'package:photo_view/src/core/photo_view_gesture_detector.dart';
import 'package:photo_view/src/core/photo_view_hit_corners.dart';

const _defaultDecoration = const BoxDecoration(
  color: const Color.fromRGBO(0, 0, 0, 0.0),
);

/// Internal widget in which controls all animations lifecycle, core responses
/// to user gestures, updates to  the controller state and mounts the entire PhotoView Layout
class PhotoViewCore extends StatefulWidget {
  const PhotoViewCore({
    Key key,
    @required this.imageProvider,
    @required this.backgroundDecoration,
    @required this.gaplessPlayback,
    @required this.heroAttributes,
    @required this.enableRotation,
    @required this.onTapUp,
    @required this.onTapDown,
    @required this.onScaleUpdate,
    @required this.onScaleStart,
    @required this.onScaleEnd,
    @required this.gestureDetectorBehavior,
    @required this.controller,
    @required this.scaleBoundaries,
    @required this.scaleStateCycle,
    @required this.scaleStateController,
    @required this.basePosition,
    @required this.tightMode,
    @required this.filterQuality,
    this.canScale = true,
    this.isVerticalLongPhoto = false,
  })  : customChild = null,
        super(key: key);

  const PhotoViewCore.customChild({
    Key key,
    @required this.customChild,
    @required this.backgroundDecoration,
    @required this.heroAttributes,
    @required this.enableRotation,
    @required this.onTapUp,
    @required this.onTapDown,
    @required this.onScaleUpdate,
    @required this.onScaleStart,
    @required this.onScaleEnd,
    @required this.gestureDetectorBehavior,
    @required this.controller,
    @required this.scaleBoundaries,
    @required this.scaleStateCycle,
    @required this.scaleStateController,
    @required this.basePosition,
    @required this.tightMode,
    @required this.filterQuality,
    this.canScale = true,
    this.isVerticalLongPhoto = false,
  })  : imageProvider = null,
        gaplessPlayback = false,
        super(key: key);

  final Decoration backgroundDecoration;
  final ImageProvider imageProvider;
  final bool gaplessPlayback;
  final PhotoViewHeroAttributes heroAttributes;
  final bool enableRotation;
  final Widget customChild;

  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;
  final ScaleBoundaries scaleBoundaries;
  final ScaleStateCycle scaleStateCycle;
  final Alignment basePosition;

  final PhotoViewImageTapUpCallback onTapUp;
  final PhotoViewImageTapDownCallback onTapDown;
  final PhotoViewImageScaleStartCallback onScaleStart;
  final PhotoViewImageScaleUpdateCallback onScaleUpdate;
  final PhotoViewImageScaleEndCallback onScaleEnd;

  final HitTestBehavior gestureDetectorBehavior;
  final bool tightMode;

  final FilterQuality filterQuality;
  final bool canScale;
  final bool isVerticalLongPhoto;

  @override
  State<StatefulWidget> createState() {
    return PhotoViewCoreState();
  }

  bool get hasCustomChild => customChild != null;
}

class PhotoViewCoreState extends State<PhotoViewCore>
    with
        TickerProviderStateMixin,
        PhotoViewControllerDelegate,
        HitCornersDetector {
  Offset _normalizedPosition;
  double _scaleBefore;
  double _rotationBefore;

  AnimationController _scaleAnimationController;
  Animation<double> _scaleAnimation;

  AnimationController _positionAnimationController;
  Animation<Offset> _positionAnimation;

  AnimationController _positionXAnimationController;
  AnimationController _positionYAnimationController;

  AnimationController _rotationAnimationController;
  Animation<double> _rotationAnimation;

  PhotoViewHeroAttributes get heroAttributes => widget.heroAttributes;

  ScaleBoundaries cachedScaleBoundaries;

  //onTapDown事件中如果已经停止过动画，那么onTapUp事件就不对外抛出。
  bool _stoppedAnimation = false;

  DateTime _lastScaleEndTime; //记录上次滑动结束时间
  bool _isLastMoveDown; //记录上次滑动方向
  double _lasta; //记录上次滑动 系数
  final _defA = 0.35;
  final _kDefTolerance = Tolerance(
    velocity: 1.0 /
        (0.050 *
            WidgetsBinding
                .instance.window.devicePixelRatio), // logical pixels per second
    distance: 1.0 / WidgetsBinding.instance.window.devicePixelRatio,
  );

  //mass = 0.5 stf=100 ratio=3.5 快了
  //mass = 1.0 stf=100 ratio=3.5 慢了，并且安卓有卡顿
  //mass = 0.8 stf=100 ratio=3.5 还是感觉慢了
  //mass = 0.55 stf=100 ratio=3.5 感觉不如 mass=0.5好 轻快
  final _spring = SpringDescription.withDampingRatio(
    mass: 0.5,
    stiffness: 100.0,
    ratio: 3.5,
  );
  final _shortSpring = SpringDescription.withDampingRatio(
    mass: 0.5,
    stiffness: 100,
    ratio: 1.8,
  );

  void handleScaleAnimation() {
    scale = _scaleAnimation.value;
  }

  void handlePositionXYAnimate() {
    controller.position = Offset(_positionXAnimationController.value,
        _positionYAnimationController.value);
  }

  void handlePositionAnimate() {
    controller.position = _positionAnimation.value;
  }

  void handleRotationAnimation() {
    controller.rotation = _rotationAnimation.value;
  }

  void onScaleStart(ScaleStartDetails details) {
    _rotationBefore = controller.rotation;
    _scaleBefore = scale;
    _normalizedPosition = details.focalPoint - controller.position;
    _scaleAnimationController.stop();
    _positionAnimationController?.stop();
    _positionXAnimationController?.stop();
    _positionYAnimationController?.stop();

    _rotationAnimationController.stop();

    widget.onScaleStart
        ?.call(context, details, _normalizedPosition, controller.value);
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _scaleBefore * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition;

    updateScaleStateFromNewScale(newScale);

    if (widget.canScale)
      updateMultiple(
        scale: newScale,
        position: clampPosition(position: delta * details.scale),
        rotation: _rotationBefore + details.rotation,
        rotationFocusPoint: details.focalPoint,
      );
    widget.onScaleUpdate?.call(context, details, delta, controller.value);
  }

  void onScaleEnd(ScaleEndDetails details) {
    final double _scale = scale;
    final Offset _position = controller.position;
    final double maxScale = scaleBoundaries.maxScale;
    final double minScale = scaleBoundaries.minScale;

    widget.onScaleEnd?.call(context, details, _position, controller.value);

    if (!widget.canScale) return;
    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_scale > maxScale) {
      final double scaleComebackRatio = maxScale / _scale;
      animateScale(_scale, maxScale);
      final Offset clampedPosition = clampPosition(
        position: _position * scaleComebackRatio,
        scale: maxScale,
      );
      animatePosition(_position, clampedPosition);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_scale < minScale) {
      final double scaleComebackRatio = minScale / _scale;
      animateScale(_scale, minScale);
      animatePosition(
        _position,
        clampPosition(
          position: _position * scaleComebackRatio,
          scale: minScale,
        ),
      );
      return;
    }
    // get magnitude from gesture velocity
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (_scaleBefore / _scale == 1.0 && magnitude >= 400.0) {
      //非长图
      if (!widget.isVerticalLongPhoto) {
        animatePosition(
            _position,
            clampPosition(
                position: _position + details.velocity.pixelsPerSecond * 0.5));
        return;
      }

      animatePositionXY(
          _position,
          clampPosition(
              position: _position + details.velocity.pixelsPerSecond * _defA),
          details.velocity);
    }
  }

  void onDoubleTap() {
    nextScaleState();
  }

  void animateScale(double from, double to) {
    _scaleAnimation = Tween<double>(
      begin: from,
      end: to,
    ).animate(_scaleAnimationController);
    _scaleAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animatePosition(Offset from, Offset to) {
    _positionAnimation = Tween<Offset>(begin: from, end: to).animate(
        CurvedAnimation(
            parent: _positionAnimationController,
            curve: Curves.easeOutCirc)); //Curves.easeOutCirc
    _positionAnimationController
      ..value = 0.0
      ..forward();
  }

  void animatePositionXY(Offset from, Offset to, Velocity velocity) {
    if ((to.dy - from.dy).abs() <= 0) return;

    final imgY = cornersY();
    bool _isShort = false;
    final imgHeight =
        imgY.max.abs() > imgY.min.abs() ? imgY.max.abs() : imgY.min.abs();
    if ((imgHeight - to.dy.abs()).abs() < 100 || to.dy.abs() < 100.0) {
      _positionYAnimationController.duration =
          const Duration(milliseconds: 500);
      _positionXAnimationController.duration =
          const Duration(milliseconds: 500);
      _isShort = true;
    } else {
      _positionYAnimationController.duration =
          const Duration(milliseconds: 2600);
      _positionXAnimationController.duration =
          const Duration(milliseconds: 2600);
    }

    final scrollSpringSimulationY = ScrollSpringSimulation(
        _isShort ? _shortSpring : _spring,
        from.dy,
        to.dy,
        velocity.pixelsPerSecond.dy * 0.95,
        tolerance: _kDefTolerance);
    final scrollSpringSimulationX = ScrollSpringSimulation(
        _isShort ? _shortSpring : _spring,
        from.dx,
        to.dx,
        velocity.pixelsPerSecond.dx * 0.95,
        tolerance: _kDefTolerance);
    _positionYAnimationController
      ..value = 0.0
      ..animateWith(scrollSpringSimulationY);
    _positionXAnimationController
      ..value = 0.0
      ..animateWith(scrollSpringSimulationX);
  }

  void animateRotation(double from, double to) {
    _rotationAnimation = Tween<double>(begin: from, end: to)
        .animate(_rotationAnimationController);
    _rotationAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      onAnimationStatusCompleted();
    }
  }

  /// Check if scale is equal to initial after scale animation update
  void onAnimationStatusCompleted() {
    if (scaleStateController.scaleState != PhotoViewScaleState.initial &&
        scale == scaleBoundaries.initialScale) {
      scaleStateController.setInvisibly(PhotoViewScaleState.initial);
    }
  }

  @override
  void initState() {
    super.initState();
    _scaleAnimationController = AnimationController(vsync: this)
      ..addListener(handleScaleAnimation);
    _scaleAnimationController.addStatusListener(onAnimationStatus);

    _positionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..addListener(handlePositionAnimate);

    _rotationAnimationController = AnimationController(vsync: this)
      ..addListener(handleRotationAnimation);
    startListeners();
    addAnimateOnScaleStateUpdate(animateOnScaleStateUpdate);

    cachedScaleBoundaries = widget.scaleBoundaries;

    if (widget.isVerticalLongPhoto) {
      _positionXAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2600),
        value: 0,
        lowerBound: double.negativeInfinity,
        upperBound: double.infinity,
      )..addListener(handlePositionXYAnimate);

      _positionYAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2600),
        value: 0,
        lowerBound: double.negativeInfinity,
        upperBound: double.infinity,
      )..addListener(handlePositionXYAnimate);
    }
    setState(() {});
  }

  void animateOnScaleStateUpdate(double prevScale, double nextScale) {
    animateScale(prevScale, nextScale);
    animatePosition(controller.position, Offset.zero);
    animateRotation(controller.rotation, 0.0);
  }

  @override
  void dispose() {
    _scaleAnimationController.removeStatusListener(onAnimationStatus);
    _scaleAnimationController.dispose();
    _positionAnimationController?.dispose();

    _positionYAnimationController?.removeListener(handlePositionXYAnimate);
    _positionXAnimationController?.removeListener(handlePositionXYAnimate);
    _positionXAnimationController?.dispose();
    _positionYAnimationController?.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }

  void onTapUp(TapUpDetails details) {
    if (!_stoppedAnimation)
      widget.onTapUp?.call(context, details, controller.value);
    _stoppedAnimation = false;
  }

  void onTapDown(TapDownDetails details) {
    if (_positionAnimating) {
      _positionAnimationController?.stop();
      _positionXAnimationController?.stop();
      _positionYAnimationController?.stop();
      _stoppedAnimation = true;
    } else {
      _stoppedAnimation = false;
    }
  }

  bool get _positionAnimating =>
      (_positionXAnimationController?.isAnimating ?? false) ||
      (_positionYAnimationController?.isAnimating ?? false) ||
      (_positionAnimationController?.isAnimating ?? false);

  bool _stopPositionXYAnimation() {
    _positionXAnimationController?.stop();
    _positionYAnimationController?.stop();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need a recalc on the scale
    if (widget.scaleBoundaries != cachedScaleBoundaries) {
      markNeedsScaleRecalc = true;
      cachedScaleBoundaries = widget.scaleBoundaries;
    }

    return StreamBuilder(
        stream: controller.outputStateStream,
        initialData: controller.prevValue,
        builder: (
          BuildContext context,
          AsyncSnapshot<PhotoViewControllerValue> snapshot,
        ) {
          if (snapshot.hasData) {
            final PhotoViewControllerValue value = snapshot.data;
            final useImageScale = widget.filterQuality != FilterQuality.none;
            final computedScale = useImageScale ? 1.0 : scale;

            final matrix = Matrix4.identity()
              ..translate(value.position.dx, value.position.dy)
              ..scale(computedScale);
            if (widget.enableRotation) {
              matrix..rotateZ(value.rotation);
            }
            // print(
            //     "matrix dx:${value.position.dx}-dy:${value.position.dy}--scale:${computedScale}--FocusPoint:${value.rotationFocusPoint}");
            // final xx = getScaleForScaleState(
            //     PhotoViewScaleState.initial, widget.scaleBoundaries);

            final Widget customChildLayout = CustomSingleChildLayout(
              delegate: _CenterWithOriginalSizeDelegate(
                scaleBoundaries.childSize,
                basePosition,
                useImageScale,
              ),
              child: _buildHero(),
            );
            return PhotoViewGestureDetector(
              child: Container(
                constraints: widget.tightMode
                    ? BoxConstraints.tight(scaleBoundaries.childSize * scale)
                    : null,
                child: Center(
                  child: Transform(
                    child: customChildLayout,
                    transform: matrix,
                    alignment: basePosition,
                  ),
                ),
                decoration: widget.backgroundDecoration ?? _defaultDecoration,
              ),
              onDoubleTap: nextScaleState,
              onScaleStart: onScaleStart,
              onScaleUpdate: onScaleUpdate,
              onScaleEnd: onScaleEnd,
              hitDetector: this,
              onTapUp: widget.onTapUp == null ? null : onTapUp,
              onTapDown: onTapDown,
            );
          } else {
            return Container();
          }
        });
  }

  Widget _buildHero() {
    return heroAttributes != null
        ? Hero(
            tag: heroAttributes.tag,
            createRectTween: heroAttributes.createRectTween,
            flightShuttleBuilder: heroAttributes.flightShuttleBuilder,
            placeholderBuilder: heroAttributes.placeholderBuilder,
            transitionOnUserGestures: heroAttributes.transitionOnUserGestures,
            child: _buildChild(),
          )
        : _buildChild();
  }

  Widget _buildChild() {
    return widget.hasCustomChild
        ? widget.customChild
        : Image(
            image: widget.imageProvider,
            gaplessPlayback: widget.gaplessPlayback ?? false,
            filterQuality: widget.filterQuality,
            width: scaleBoundaries.childSize.width * scale,
            fit: BoxFit.contain,
          );
  }
}

class _CenterWithOriginalSizeDelegate extends SingleChildLayoutDelegate {
  const _CenterWithOriginalSizeDelegate(
    this.subjectSize,
    this.basePosition,
    this.useImageScale,
  );

  final Size subjectSize;
  final Alignment basePosition;
  final bool useImageScale;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final childWidth = useImageScale ? childSize.width : subjectSize.width;
    final childHeight = useImageScale ? childSize.height : subjectSize.height;

    final halfWidth = (size.width - childWidth) / 2;
    final halfHeight = (size.height - childHeight) / 2;

    final double offsetX = halfWidth * (basePosition.x + 1);
    final double offsetY = halfHeight * (basePosition.y + 1);
    return Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return useImageScale
        ? const BoxConstraints()
        : BoxConstraints.tight(subjectSize);
  }

  @override
  bool shouldRelayout(_CenterWithOriginalSizeDelegate oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CenterWithOriginalSizeDelegate &&
          runtimeType == other.runtimeType &&
          subjectSize == other.subjectSize &&
          basePosition == other.basePosition &&
          useImageScale == other.useImageScale;

  @override
  int get hashCode =>
      subjectSize.hashCode ^ basePosition.hashCode ^ useImageScale.hashCode;
}
