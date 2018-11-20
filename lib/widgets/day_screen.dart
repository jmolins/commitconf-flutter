import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/widgets/bidirectional_scrollview.dart';
import 'package:flutter/material.dart';

class DayScreen extends StatefulWidget {
  final Day day;

  DayScreen(this.day) : assert(day != null);

  @override
  _DayScreenState createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  var _tracks = 15;
  var _slots = 20;

  var _headerHeight = 40.0;
  var _myTrackWidth = 120.0;
  var _cellWidth = 100.0;
  var _cellHeight = 60.0;

  var _headerScrollController = ScrollController();
  var _myTrackScrollController = ScrollController();

  // ValueNotifiers/ScrollController for the tracks matrix
  var _horizontalScrollController = DirectionalScrollController();
  var _verticalScrollController = DirectionalScrollController();

  ValueChanged<Offset> scrollListener;

  @override
  initState() {
    super.initState();
    scrollListener = (Offset offset) {
      _headerScrollController.jumpTo(offset.dx);
      _myTrackScrollController.jumpTo(offset.dy);
    };
  }

  List<Widget> _buildTracks() {
    List<Widget> list = new List();

    for (int i = 0; i < _slots; i++) {
      list.add(new Container(
        padding: new EdgeInsets.all(1.0),
        color: Colors.grey,
        height: _cellHeight,
        width: _cellWidth,
        child: new Container(
          color: Colors.white,
        ),
      ));
    }

    return List.generate(_tracks, (_) {
      return Column(
        children: list.map((widget) {
          return widget;
        }).toList(),
      );
    });
  }

  List<Widget> _buildTracksHeader() {
    return List.generate(_tracks, (i) {
      return Container(
        width: _cellWidth,
        color: i.isEven ? Colors.black45 : Colors.white,
      );
    });
  }

  List<Widget> _buildMyTrack() {
    return List.generate(_slots, (i) {
      return Container(
        width: _cellWidth,
        height: _cellHeight,
        color: i.isEven ? Colors.black45 : Colors.white,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: _myTrackWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: _headerHeight,
                color: Colors.black,
              ),
              Expanded(
                child: NotificationListener(
                  onNotification: (notification) {
                    if (notification.depth == 0 &&
                        notification is ScrollUpdateNotification) {
                      _verticalScrollController.value =
                          notification.metrics.pixels;
                    }
                  },
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    controller: _myTrackScrollController,
                    children: _buildMyTrack(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: _headerHeight,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.depth == 0 &&
                        notification is ScrollUpdateNotification) {
                      _horizontalScrollController.value =
                          notification.metrics.pixels;
                    }
                  },
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    controller: _headerScrollController,
                    children: _buildTracksHeader(),
                  ),
                ),
              ),
              Expanded(
                child: BidirectionalScrollView(
                  child: Row(
                    children: _buildTracks(),
                  ),
                  velocityFactor: 0.5,
                  scrollListener: scrollListener,
                  horizontalScrollController: _horizontalScrollController,
                  verticalScrollController: _verticalScrollController,
                ),
              ),
            ],
          ),
        ),
        //Expanded(child: _buildBody(context)),
      ],
    );
  }
}
