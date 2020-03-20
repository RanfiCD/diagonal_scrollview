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

class MyApp extends StatefulWidget {
  MyApp();

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final double _boxSize = 1000.0;
  final Color _boxColor = Colors.white70;
  final double _minScale = .3;
  final double _maxScale = 3;
  final Size _controlPanelSize = Size(250, 200);
  final Size _controlPanelIconSize = Size(10, 10);

  DiagonalScrollViewController _controller;
  DiagonalScrollViewController _controlPanelController;
  double _currentScale = 1;

  Offset _rectifyControlPanelPosition(Offset position) {
    return Offset(
        position.dx + _controlPanelSize.width - _controlPanelIconSize.width,
        position.dy + _controlPanelSize.height - _controlPanelIconSize.height);
  }

  Offset _getControlPanelProgress(Offset position) {
    Offset boxSize = _controlPanelSize - _controlPanelIconSize;
    Offset rectifiedPosition = _rectifyControlPanelPosition(position);

    return Offset(
        rectifiedPosition.dx / boxSize.dx, rectifiedPosition.dy / boxSize.dy);
  }

  List<Widget> _getChildren() {
    List<Widget> children = [];
    Color childColor = Colors.blueGrey;
    double childSize = 100.0;
    double childMargin = 20;
    double tmpNumChildrenRow = _boxSize / childSize;
    num numChildren = (_boxSize - tmpNumChildrenRow * childMargin) / childSize;
    int cubeId = 1;

    for (num x = 0; x < numChildren; x++) {
      for (num y = 0; y < numChildren; y++) {
        Widget cube = Container(
          width: childSize,
          height: childSize,
          color: childColor,
          child: Center(
            child: Text(
              (cubeId++).toString(),
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
        );

        children.add(Positioned(
          left: childMargin + (childMargin + childSize) * y,
          top: childMargin + (childMargin + childSize) * x,
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
      body: Stack(
        children: <Widget>[
          DiagonalScrollView(
            enableFling: true,
            enableZoom: true,
            minScale: _minScale,
            maxScale: _maxScale,
            maxHeight: _boxSize,
            maxWidth: _boxSize,
            onCreated: (DiagonalScrollViewController controller) {
              _controller = controller;
            },
            onScaleChanged: (double scale) {
              setState(() {
                _currentScale = scale;
              });
            },
            child: Container(
              width: _boxSize,
              height: _boxSize,
              color: _boxColor,
              child: Stack(
                children: _getChildren(),
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              height: _controlPanelSize.height,
              width: _controlPanelSize.width,
              decoration: BoxDecoration(
                color: Colors.grey[400],
              ),
              child: DiagonalScrollView(
                minScale: 1,
                maxScale: 1,
                maxWidth:
                    _controlPanelSize.width * 2 - _controlPanelIconSize.width,
                maxHeight:
                    _controlPanelSize.height * 2 - _controlPanelIconSize.height,
                onCreated: (DiagonalScrollViewController controller) {
                  Offset offset = Offset(
                      _controlPanelSize.width - _controlPanelIconSize.width,
                      _controlPanelSize.height - _controlPanelIconSize.height);

                  _controlPanelController = controller;
                  _controlPanelController.moveTo(location: offset);
                },
                onScroll: (Offset offset) {
                  Offset progress = _getControlPanelProgress(offset);
                  Size childSize = _controller.getChildSize();

                  _controller.moveTo(
                      scale: _currentScale,
                      location: Offset(childSize.width * progress.dx,
                          childSize.height * progress.dy));
                },
                child: Container(
                    height: _controlPanelSize.height,
                    width: _controlPanelSize.width,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: _controlPanelIconSize.width,
                            height: _controlPanelIconSize.height,
                            decoration: BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
                height: 200,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black)),
                child: FittedBox(
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Slider(
                      min: _minScale,
                      max: _maxScale,
                      value: _currentScale,
                      onChanged: (double val) {
                        _controller.moveTo(
                          scale: val,
                          location: _controller.getPosition(),
                        );

                        setState(() {
                          _currentScale = val;
                        });
                      },
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }
}
