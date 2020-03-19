import 'package:flutter/material.dart';

/// An interface to programmatically control a [DiagonalScrollView].
abstract class DiagonalScrollViewController {
  /// Move the origin of the [DiagonalScrollView] to an absolute position.
  void moveTo({Offset location, double scale = 1.0, bool animate = false});

  /// Move the origin of the [DiagonalScrollView] taking into account the current position.
  void moveBy({Offset offset, double scale = 0.0, bool animate = false});

  /// Returns the current scale of the [DiagonalScrollView].
  double getScale();

  /// Returns the origin's current position of the [DiagonalScrollView].
  Offset getPosition();

  /// Returns the container size.
  Size getContainerSize();

  /// Returns the child size.
  Size getChildSize();
}
