import 'package:flutter/material.dart';
import 'package:diagonal_scrollview/diagonal_scrollview.dart';

String _appTitle = 'Example App';

main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: _appTitle,
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp();

  final double _boxSize = 1000.0;
  final Color _boxColor = Colors.white70;

  List<Widget> _getChildren() {
    List<Widget> children = [];
    Color childColor = Colors.blueGrey;
    double childSize = 100.0;
    double childMargin = 20;
    double tmpNumChildrenRow = _boxSize / childSize;
    num numChildren = (_boxSize - tmpNumChildrenRow * childMargin) / childSize;

    for (num x = 0; x < numChildren; x++) {
      for (num y = 0; y < numChildren; y++) {
        Widget cube = Container(
          width: childSize,
          height: childSize,
          color: childColor,
        );

        children.add(Positioned(
          left: childMargin + (childMargin + childSize) * x,
          top: childMargin + (childMargin + childSize) * y,
          child: cube,
        ));
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appTitle),
      ),
      body: DiagonalScrollView(
        enableFling: true,
        enableZoom: true,
        maxHeight: _boxSize,
        maxWidth: _boxSize,
        child: Container(
          width: _boxSize,
          height: _boxSize,
          color: _boxColor,
          child: Stack(
            children: _getChildren(),
          ),
        ),
      ),
    );
  }
}
