import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/services/conference_bloc.dart';
import 'package:commitconf/services/conference_bloc_provider.dart';
import 'package:commitconf/widgets/bidirectional_scrollview.dart';
import 'package:commitconf/widgets/my_schedule_view.dart';
import 'package:commitconf/widgets/tracks_grid.dart';
import 'package:flutter/material.dart';

class DayScreen extends StatefulWidget {
  final Day day;
  final int dayIndex;
  final ConferenceBloc bloc;

  DayScreen({key, this.day, this.dayIndex = 0, this.bloc})
      : assert(day != null),
        assert(bloc != null),
        super(key: key);

  @override
  _DayScreenState createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen>
    with SingleTickerProviderStateMixin<DayScreen> {
  var _headerHeight = 40.0;
  var _myTrackWidth = 200.0;
  var _timesWidth = 60.0;

  var _cellWidth = 190.0;
  var _cellHeight = 140.0;

  var _headerScrollController = ScrollController();
  var _myTrackScrollController = ScrollController();

  // ValueNotifiers/ScrollController for the tracks matrix
  var _horizontalScrollController = DirectionalScrollController();
  var _verticalScrollController = DirectionalScrollController();

  ValueChanged<Offset> scrollListener;

  AnimationController animationController;
  Animation _myTrackWidthAnimation;
  Animation _scaleTransition;

  @override
  initState() {
    super.initState();
    scrollListener = (Offset offset) {
      _headerScrollController.jumpTo(offset.dx);
      _myTrackScrollController.jumpTo(offset.dy);
    };
    animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _myTrackWidthAnimation = Tween(begin: _timesWidth, end: _myTrackWidth)
        .animate(animationController)
          ..addListener(() {
            setState(() {});
          });
    _scaleTransition = Tween(begin: 1.0, end: 0.0).animate(animationController)
      ..addListener(() {
        setState(() {});
      });
    if (widget.bloc.myTrackIsShown) {
      animationController.value = _myTrackWidth;
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  List<Widget> _buildTracksHeader() {
    return widget.day.tracks.map((track) {
      return Container(
        width: _cellWidth,
        color: Color(0xFFEEEEEE),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Center(
              child: Text(track.name),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: _myTrackWidthAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Opacity(
                    opacity: animationController.view.value,
                    child: Container(
                      height: _headerHeight,
                      width: _myTrackWidthAnimation.value,
                      color: Color(0xFFEEEEEE),
                      child: Center(
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                animationController.reverse();
                                widget.bloc.myTrackIsShown = false;
                              },
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Expanded(
                              child: Text(
                                "My Track",
                                style: Theme.of(context).textTheme.title,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ScaleTransition(
                    scale: _scaleTransition,
                    child: Opacity(
                      opacity: 1 - animationController.view.value,
                      child: Container(
                        height: _headerHeight,
                        color: Color(0xFFEEEEEE),
                        width: _myTrackWidthAnimation.value,
                        child: IconButton(
                          icon: Icon(Icons.person),
                          onPressed: () {
                            animationController.forward();
                            widget.bloc.myTrackIsShown = true;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
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
                  child: GestureDetector(
                    onTap: () {
                      if (!widget.bloc.myTrackIsShown) {
                        animationController.forward();
                      }
                    },
                    child: MyScheduleView(
                      day: widget.dayIndex,
                      height: _cellHeight,
                      myTrackWidth: _myTrackWidthAnimation.value,
                      scale: _scaleTransition,
                      scrollController: _myTrackScrollController,
                      bloc: ConferenceBlocProvider.of(context),
                    ),
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
                  child: TracksGrid(
                    day: widget.day,
                    dayIndex: widget.dayIndex,
                    cellHeight: _cellHeight,
                    cellWidth: _cellWidth,
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
