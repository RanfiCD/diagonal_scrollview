import 'package:flutter/material.dart';

/// A [Widget] that enables the scroll in both directions, horizontal and vertical.
class DiagonalScrollView extends StatefulWidget {
  final Widget child;

  /// The maximum scroll alongside the 'x' axis.
  final double maxWidth;

  /// The maximum scroll alongside the 'y' axis.
  final double maxHeight;

  /// The signature for callbacks that report that the position has changed.
  /// The value received is the position of the top left corner of the child's [RenderBox] (0, 0).
  ///
  /// The movement is constrained so that the (0, 0) point will not be visible.
  /// Therefore, the values emitted will be always negative or zero.
  final ValueChanged<Offset> onScroll;
  final bool enableFling;

  DiagonalScrollView({
    @required this.child,
    this.maxWidth: double.infinity,
    this.maxHeight: double.infinity,
    this.onScroll,
    this.enableFling: true,
  })  : assert(maxWidth > 0),
        assert(maxHeight > 0);

  @override
  _DiagonalScrollViewState createState() => _DiagonalScrollViewState();
}

class _DiagonalScrollViewState extends State<DiagonalScrollView>
    with SingleTickerProviderStateMixin {
  _DiagonalScrollViewState();

  double _posX = 0.0;
  double _posY = 0.0;
  double _tmpPosX = 0.0;
  double _tmpPosY = 0.0;
  double _flingVelocityReduction = 5.0;
  AnimationController _controller;
  Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
    _controller.addListener(_handleFlingAnimation);
  }

  void _emitScroll() {
    if (widget.onScroll != null) {
      widget?.onScroll(Offset(_posX, _posY));
    }
  }

  /// Returns the constrained position of the child relative to the [RenderBox].
  Offset _rectifyChildPosition(x, y) {
    RenderBox box = context.findRenderObject();
    double boxWidth = box.size.width;
    double boxHeight = box.size.height;

    if (x > 0.0) x = 0.0;
    if (y > 0.0) y = 0.0;

    if (x < boxWidth - widget.maxWidth) x = boxWidth - widget.maxWidth;
    if (y < boxHeight - widget.maxHeight) y = boxHeight - widget.maxHeight;

    return Offset(x, y);
  }

  void _handlePanDown(DragDownDetails details) {
    _controller.value = 0.0;
    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    Offset newPosition = _rectifyChildPosition(
      _posX + details.delta.dx,
      _posY + details.delta.dy,
    );

    setState(() {
      _posX = newPosition.dx;
      _posY = newPosition.dy;
    });

    _emitScroll();
  }

  void _handlePanEnd(DragEndDetails details) {
    Offset velocity = details.velocity.pixelsPerSecond;
    double distance = velocity.distance;

    if (widget.enableFling && distance > 0.0) {
      _tmpPosX = _posX;
      _tmpPosY = _posY;

      _animation = Tween<Offset>(
        begin: Offset(0.0, 0.0),
        end: velocity / _flingVelocityReduction,
      ).animate(_controller);

      _controller.fling(velocity: 0.5);
    }
  }

  void _handleFlingAnimation() {
    if (_animation != null && _animation.value.distance > 0.0) {
      Offset newPosition = _rectifyChildPosition(
          _tmpPosX + _animation.value.dx, _tmpPosY + _animation.value.dy);

      setState(() {
        _posX = newPosition.dx;
        _posY = newPosition.dy;
      });

      _emitScroll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: _handlePanDown,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: _posY,
            left: _posX,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
