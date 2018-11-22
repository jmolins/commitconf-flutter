import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/services/conference_bloc.dart';
import 'package:commitconf/services/conference_bloc_provider.dart';
import 'package:commitconf/widgets/bidirectional_scrollview.dart';
import 'package:commitconf/widgets/my_schedule_view.dart';
import 'package:flutter/material.dart';

class DayScreen extends StatefulWidget {
  final Day day;

  final int dayIndex;

  DayScreen({key, this.day, this.dayIndex}) : assert(day != null), super(key: key);

  @override
  _DayScreenState createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  var _headerHeight = 40.0;
  var _myTrackWidth = 120.0;
  var _cellWidth = 100.0;
  var _cellHeight = 120.0;

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

  List<Widget> _buildTracksHeader() {
    return widget.day.tracks.map((track) {
      return Container(
        width: _cellWidth,
        child: Center(
          child: Text(track.name),
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
                  child: MyScheduleView(
                    day: widget.dayIndex,
                    height: _cellHeight,
                    width: _myTrackWidth,
                    scrollController: _myTrackScrollController,
                    bloc: ConferenceBlocProvider.of(context),
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

class TracksGrid extends StatefulWidget {
  final Day day;

  final double cellWidth;
  final double cellHeight;

  TracksGrid({key, this.day, this.cellWidth, this.cellHeight}) : super(key: key);

  @override
  _TracksGridState createState() => _TracksGridState();
}

class _TracksGridState extends State<TracksGrid> {
  ConferenceBloc _bloc;

  List<int> _allTracksSlots = [];

  List<Track> _tracks;
  List<SlotInfo> _slots;

  int _trackCount;
  int _slotCount;

  @override
  initState() {
    super.initState();
    _tracks = widget.day.tracks;
    _trackCount = _tracks.length;

    _slots = widget.day.slotInfo;
    _slotCount = _slots.length;

    var talks = widget.day.tracks[0].talks;

    for (int i = 0; i < talks.length; i++) {
      if (talks[i].extendRight == _trackCount) _allTracksSlots.add(i);
    }
  }

  List<Widget> _buildTracksRows() {
    List<Widget> rows = [];
    for (var slotIndex = 0; slotIndex < _slotCount;) {
      if (_tracks[0].talks[slotIndex].extendRight == _trackCount) {
        rows.add(TalkCard(
          talk: _tracks[0].talks[slotIndex],
          slotInfo: _slots[slotIndex],
          bloc: _bloc,
          height: widget.cellHeight,
          width: widget.cellWidth * _trackCount,
        ));
        slotIndex++;
      } else {
        // Check if any track for this slot occupies more than one slot
        // downward. If so store the maximum downward slots
        int maxExtendDown = 0;
        List<int> downWardTracks = [];
        for (var trackIndex = 0; trackIndex < _tracks.length; trackIndex++) {
          if (_tracks[trackIndex].talks[slotIndex].extendDown >=
              maxExtendDown) {
            maxExtendDown = _tracks[trackIndex].talks[slotIndex].extendDown;
            if (maxExtendDown > 1) downWardTracks.add(trackIndex);
          }
        }

        if (maxExtendDown > 1) {
          List<Widget> localColumnWidgets = [];

          for (var localSlotIndex = slotIndex;
              localSlotIndex < slotIndex + maxExtendDown;
              localSlotIndex++) {
            List<Widget> localRowWidgets = [];

            for (var trackIndex = 0;
                trackIndex < _tracks.length - downWardTracks.length;
                trackIndex++) {
              //print("trackIndex: $trackIndex");
              localRowWidgets.add(TalkCard(
                talk: _tracks[trackIndex].talks[localSlotIndex],
                slotInfo: _slots[localSlotIndex],
                bloc: _bloc,
                height: widget.cellHeight,
                width: widget.cellWidth,
              ));
            }
            localColumnWidgets.add(Row(children: localRowWidgets));
          }
          var tempRow = <Widget>[]..add(Column(children: localColumnWidgets));

          // Now the last downward columns
          downWardTracks.forEach((trackIndex) => tempRow.add(TalkCard(
                talk: _tracks[trackIndex].talks[slotIndex],
                slotInfo: _slots[slotIndex],
                bloc: _bloc,
                height: widget.cellHeight * maxExtendDown,
                width: widget.cellWidth,
              )));

          rows.add(Row(
            children: tempRow,
          ));

          slotIndex += maxExtendDown;
        } else {
          List<Widget> widgets = [];
          for (var trackIndex = 0; trackIndex < _tracks.length; trackIndex++) {
            widgets.add(TalkCard(
              talk: _tracks[trackIndex].talks[slotIndex],
              slotInfo: _slots[slotIndex],
              bloc: _bloc,
              height: widget.cellHeight,
              width: widget.cellWidth,
            ));
          }
          rows.add(Row(
            children: widgets,
          ));
          slotIndex++;
        }
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    _bloc = ConferenceBlocProvider.of(context);
    return Column(
      children: _buildTracksRows(),
    );
  }
}

class TalkCard extends StatelessWidget {
  final Talk talk;
  final SlotInfo slotInfo;
  final ConferenceBloc bloc;
  final double height;
  final double width;

  TalkCard({this.talk, this.slotInfo, this.bloc, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      height: height,
      width: width,
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: () {
            bloc.registerAttendance(talk, 0, slotInfo);
            /*Scaffold.of(context).showSnackBar(
                SnackBar(content: Text("${talk.title}, ${slotInfo.start}")));*/
          },
          child: Card(
            color: Colors.white,
            child: Center(
              child: Text(talk.title, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}
