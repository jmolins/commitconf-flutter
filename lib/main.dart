import 'package:commitconf/bidirectional_scrollview.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CommitConf app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'CommitConf'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
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
          ],
        ),
      ),
    );
  }
}
