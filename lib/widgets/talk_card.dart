import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/services/conference_bloc.dart';
import 'package:commitconf/utils/constants.dart';
import 'package:flutter/material.dart';

class TalkCard extends StatelessWidget {
  final int dayIndex;
  final Talk talk;
  final SlotInfo slotInfo;
  final ConferenceBloc bloc;
  final double height;
  final double width;

  TalkCard(
      {this.dayIndex,
        this.talk,
        this.slotInfo,
        this.bloc,
        this.height,
        this.width});

  @override
  Widget build(BuildContext context) {
    bool isDivider = "divider" == slotInfo.type;

    return Container(
      //color: Colors.grey,
      height: isDivider ? kDividerSlotHeight : height,
      width: width,
      child: talk.id == ""
          ? SizedBox()
          : Padding(
        padding: EdgeInsets.all(3.0),
        child: GestureDetector(
          onTap: null,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: isDivider ? Color(0xFFEEEEEE) : Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isDivider
                  ? Center(
                child: Text(talk.title),
              )
                  : Stack(
                children: <Widget>[
                  Center(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        talk.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.lightBlue),
                      ),
                    ),
                  ),
                  talk.allTracks
                      ? SizedBox()
                      : Align(
                    alignment: Alignment.bottomLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: 35.0, maxHeight: 35.0),
                      child: OverflowBox(
                        child: IconButton(
                          icon: Icon(Icons.playlist_add,
                              color: Colors.black38),
                          onPressed: () {
                            bloc.registerAttendance(
                                talk, dayIndex, slotInfo);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}