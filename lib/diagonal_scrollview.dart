import 'package:flutter/material.dart';

/// A [Widget] that enables the scroll in both directions, horizontal and vertical.
/// Also allows the zooming. The width and height match those of the parent.
class DiagonalScrollView extends StatefulWidget {
  /// Enable or disable the zoom animation.
  final bool enableZoom;

  /// Enable or disable the fling animation.
  final bool enableFling;

  /// The signature for callbacks that report that the position has changed.
  /// The value received is the position of the top left corner of the child's [RenderBox] (0, 0).
  ///
  /// The movement is constrained so that the (0, 0) point will not be visible.
  /// Therefore, the values emitted will be always negative or zero.
  final ValueChanged<Offset> onScroll;

  /// The signature for callbacks that report that the scale has changed.
  /// The value received is the scale by which the child is displayed on the [RenderBox].
  final ValueChanged<double> onScaleChanged;

  /// The minimum allowed scale.
  final double minScale;

  /// The maximum allowed scale.
  final double maxScale;

  /// The maximum scroll alongside the 'x' axis.
  final double maxWidth;

  /// The maximum scroll alongside the 'y' axis.
  final double maxHeight;

  /// The percentage of the animation's velocity used as the actual velocity.
  final double flingVelocityReduction;

  /// The child of this [Widget].
  final Widget child;

  DiagonalScrollView({
    Key key,
    this.enableZoom: false,
    this.enableFling: true,
    this.onScroll,
    this.onScaleChanged,
    this.minScale: 0.3,
    this.maxScale: 3.0,
    this.maxWidth: double.infinity,
    this.maxHeight: double.infinity,
    this.flingVelocityReduction: 0.02,
    @required this.child,
  }) : super(key: key);

  @override
  _DiagonalScrollViewState createState() => _DiagonalScrollViewState();
}

class _DiagonalScrollViewState extends State<DiagonalScrollView>
    with SingleTickerProviderStateMixin {
  _DiagonalScrollViewState();

  double _scale = 1.0;
  double _tmpScale = 1.0;
  Offset _position = Offset(0, 0);
  Offset _boxZoomOffset = Offset(0, 0);
  Offset _lastFocalPoint = Offset(0, 0);
  AnimationController _controller;
  Animation<Offset> _animation;
  GlobalKey _positionedKey = GlobalKey();

  RenderBox get renderBox {
    return context.findRenderObject() as RenderBox;
  }

  double get containerWidth {
    return renderBox?.size?.width ?? 0;
  }

  double get containerHeight {
    return renderBox?.size?.height ?? 0;
  }

  RenderBox get positionedRenderBox {
    return _positionedKey.currentContext?.findRenderObject() as RenderBox;
  }

  double get positionedWidth {
    return positionedRenderBox?.size?.width ?? 0;
  }

  double get positionedHeight {
    return positionedRenderBox?.size?.height ?? 0;
  }

  /// Returns the correct new scale of the child.
  double _getNewScale(double currentScale) {
    double newScale = 1.0;

    if (widget.enableZoom) {
      newScale = _tmpScale * currentScale;

      if (newScale < widget.minScale) {
        newScale = widget.minScale;
      } else if (newScale > widget.maxScale) {
        newScale = widget.maxScale;
      }
    }

    return newScale;
  }

  /// Returns the [Offset] applied to the child when zooming.
  Offset _getZoomFocusOffset(double scale) {
    Offset boxCenter = Offset(containerWidth, containerHeight) / 2;
    Offset focusOffset = ((boxCenter / scale) - boxCenter) * scale;

    return focusOffset;
  }

  /// Returns the constrained position of the child relative to the [RenderBox].
  Offset _rectifyChildPosition(
      {double scale, Offset position, Offset offset: const Offset(0, 0)}) {
    Offset containerScaled = Offset(containerWidth, containerHeight) / scale;
    double x = position.dx;
    double y = position.dy;

    if (x + offset.dx < containerScaled.dx - widget.maxWidth)
      x = containerScaled.dx - widget.maxWidth - offset.dx;
    if (y + offset.dy < containerScaled.dy - widget.maxHeight)
      y = containerScaled.dy - widget.maxHeight - offset.dy;

    if (x + offset.dx > 0.0) x = -offset.dx;
    if (y + offset.dy > 0.0) y = -offset.dy;

    return Offset(x, y);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _tmpScale = _scale;
    _lastFocalPoint = renderBox.globalToLocal(details.focalPoint);
    _controller.value = 0.0;
    _boxZoomOffset = _getZoomFocusOffset(_scale);
    _position -= _boxZoomOffset / _scale;

    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    double newScale = _getNewScale(details.scale);
    bool scaleChanged = _scale != newScale;
    Offset focalPoint = renderBox.globalToLocal(details.focalPoint);
    Offset newBoxZoomOffset = _getZoomFocusOffset(newScale);
    Offset delta = focalPoint - _lastFocalPoint;
    Offset deltaScaled = delta / newScale;
    Offset newPosition = _rectifyChildPosition(
      scale: newScale,
      position: _position + deltaScaled,
      offset: newBoxZoomOffset / newScale,
    );

    setState(() {
      _scale = newScale;
      _lastFocalPoint = focalPoint;
      _position = newPosition;
      _boxZoomOffset = newBoxZoomOffset;
    });

    widget.onScroll?.call(_position);
    if (scaleChanged) {
      widget.onScaleChanged?.call(_scale);
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _position += _boxZoomOffset / _scale;
    _boxZoomOffset = Offset(0, 0);

    Offset velocity = details.velocity.pixelsPerSecond;
    if (widget.enableFling && velocity.distance > 0.0) {
      velocity *= widget.flingVelocityReduction / _scale;

      _animation = Tween<Offset>(
        begin: velocity,
        end: Offset(0.0, 0.0),
      ).animate(_controller);

      _controller.fling(velocity: 1.0);
    }
  }

  void _handleFlingAnimation() {
    if (_controller.isAnimating && _animation.value.distance > 0.0) {
      Offset newPosition = _rectifyChildPosition(
        scale: _scale,
        position: _position + _animation.value,
      );

      setState(() {
        _position = newPosition;
      });

      widget.onScroll?.call(_position);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }

  @override
  Widget build(BuildContext context) {
    Offset origin = Offset(positionedWidth, positionedHeight) / -2;
    Offset position = _position * _scale + _boxZoomOffset;

    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Positioned(
              key: _positionedKey,
              left: position.dx,
              top: position.dy,
              child: Transform.scale(
                origin: origin,
                scale: _scale,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
