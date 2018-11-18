/// BidirectionalScrollView source modified from
/// flutter-bidirectional_scrollview_plugin by Toufik Zitouni
///
/// https://github.com/toufikzitouni/flutter-bidirectional_scrollview_plugin

import 'package:flutter/material.dart';

class BidirectionalScrollView extends StatefulWidget {
  BidirectionalScrollView({
    @required this.child,
    this.velocityFactor,
    this.scrollListener,
    this.horizontalScrollController,
    this.verticalScrollController,
  });

  final Widget child;
  final double velocityFactor;
  final ValueChanged<Offset> scrollListener;
  final DirectionalScrollController horizontalScrollController;
  final DirectionalScrollController verticalScrollController;

  @override
  State<StatefulWidget> createState() => _BidirectionalScrollViewState();
}

class _BidirectionalScrollViewState extends State<BidirectionalScrollView>
    with SingleTickerProviderStateMixin {
  final GlobalKey _containerKey = new GlobalKey();
  final GlobalKey _positionedKey = new GlobalKey();

  double xPos = 0.0;
  double yPos = 0.0;
  double xViewPos = 0.0;
  double yViewPos = 0.0;

  AnimationController _controller;
  Animation<Offset> _flingAnimation;

  bool _enableFling = false;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
    widget.horizontalScrollController.addListener(() {
      setState(() {
        xViewPos = -widget.horizontalScrollController.value;
      });
    });
    widget.verticalScrollController.addListener(() {
      setState(() {
        yViewPos = -widget.verticalScrollController.value;
      });
    });
  }

  set offset(Offset offset) {
    setState(() {
      xViewPos = -offset.dx;
      yViewPos = -offset.dy;
    });
  }

  double get x {
    return -xViewPos;
  }

  double get y {
    return -yViewPos;
  }

  double get height {
    RenderBox renderBox = _positionedKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  double get width {
    RenderBox renderBox = _positionedKey.currentContext.findRenderObject();
    return renderBox.size.width;
  }

  double get containerHeight {
    RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    return containerBox.size.height;
  }

  double get containerWidth {
    RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    return containerBox.size.width;
  }

  void _handleFlingAnimation() {
    if (!_enableFling ||
        _flingAnimation.value.dx.isNaN ||
        _flingAnimation.value.dy.isNaN) {
      return;
    }

    double newXPosition = xPos + _flingAnimation.value.dx;
    double newYPosition = yPos + _flingAnimation.value.dy;

    if (newXPosition > 0.0 || width < containerWidth) {
      newXPosition = 0.0;
    } else if (-newXPosition + containerWidth > width) {
      newXPosition = containerWidth - width;
    }

    if (newYPosition > 0.0 || height < containerHeight) {
      newYPosition = 0.0;
    } else if (-newYPosition + containerHeight > height) {
      newYPosition = containerHeight - height;
    }

    setState(() {
      xViewPos = newXPosition;
      yViewPos = newYPosition;
    });

    _sendScrollValues();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox referenceBox = context.findRenderObject();
    Offset position = referenceBox.globalToLocal(details.globalPosition);

    double newXPosition = xViewPos + (position.dx - xPos);
    double newYPosition = yViewPos + (position.dy - yPos);

    RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    double containerWidth = containerBox.size.width;
    double containerHeight = containerBox.size.height;

    if (newXPosition > 0.0 || width < containerWidth) {
      newXPosition = 0.0;
    } else if (-newXPosition + containerWidth > width) {
      newXPosition = containerWidth - width;
    }

    if (newYPosition > 0.0 || height < containerHeight) {
      newYPosition = 0.0;
    } else if (-newYPosition + containerHeight > height) {
      newYPosition = containerHeight - height;
    }

    setState(() {
      xViewPos = newXPosition;
      yViewPos = newYPosition;
    });

    xPos = position.dx;
    yPos = position.dy;

    _sendScrollValues();
  }

  void _handlePanDown(DragDownDetails details) {
    _enableFling = false;
    final RenderBox referenceBox = context.findRenderObject();
    Offset position = referenceBox.globalToLocal(details.globalPosition);

    xPos = position.dx;
    yPos = position.dy;
  }

  void _handlePanEnd(DragEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    final double velocity = magnitude / 1000;

    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;

    xPos = xViewPos;
    yPos = yViewPos;

    _enableFling = true;
    _flingAnimation = new Tween<Offset>(
            begin: new Offset(0.0, 0.0),
            end: direction * distance * widget.velocityFactor)
        .animate(_controller);
    _controller
      ..value = 0.0
      ..fling(velocity: velocity);
  }

  _sendScrollValues() {
    if (widget.scrollListener != null) {
      widget.scrollListener(new Offset(-xViewPos, -yViewPos));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onPanDown: _handlePanDown,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: new Container(
          key: _containerKey,
          child: new Stack(
            overflow: Overflow.clip,
            children: <Widget>[
              new Positioned(
                  key: _positionedKey,
                  top: yViewPos,
                  left: xViewPos,
                  child: widget.child),
            ],
          )),
    );
  }
}

class DirectionalScrollController extends ValueNotifier<double> {
  DirectionalScrollController({
    double initialOffset = 0.0,
  })  : assert(initialOffset != null),
        _initialOffset = initialOffset,
        super(initialOffset);

  double get initialOffset => _initialOffset;
  final double _initialOffset;

  double get offset => value;

  void jumpTo(double offset) {
    value = offset;
    notifyListeners();
  }
}
