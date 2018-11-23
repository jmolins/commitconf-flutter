import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/services/conference_bloc.dart';
import 'package:commitconf/services/conference_bloc_provider.dart';
import 'package:commitconf/widgets/talk_card.dart';
import 'package:flutter/material.dart';

class TracksGrid extends StatefulWidget {
  final Day day;
  final int dayIndex;

  final double cellWidth;
  final double cellHeight;

  TracksGrid({key, this.day, this.dayIndex, this.cellWidth, this.cellHeight})
      : super(key: key);

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
          dayIndex: widget.dayIndex,
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
                dayIndex: widget.dayIndex,
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
                dayIndex: widget.dayIndex,
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
              dayIndex: widget.dayIndex,
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
