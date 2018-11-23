import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/services/conference_bloc.dart';
import 'package:commitconf/utils/constants.dart';
import 'package:flutter/material.dart';

class MyScheduleView extends StatefulWidget {
  final int day;
  final double height;
  final double myTrackWidth;
  final Animation<double> scale;
  final ScrollController scrollController;
  final ConferenceBloc bloc;

  MyScheduleView(
      {this.day,
      this.height,
      this.myTrackWidth,
      this.scale,
      this.scrollController,
      this.bloc});

  @override
  _MyScheduleViewState createState() => _MyScheduleViewState();
}

class _MyScheduleViewState extends State<MyScheduleView> {
  Stream<List<List<Attendance>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = widget.bloc.mySchedule;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFEEEEEE),
      child: StreamBuilder(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.data != null) {
              int accumulatedExtend = 0;
              List<Attendance> daySchedule = snapshot.data[widget.day];

              return ListView.builder(
                scrollDirection: Axis.vertical,
                controller: widget.scrollController,
                itemBuilder: (context, index) {
                  Attendance att = daySchedule[index];
                  double height = 0.0;
                  if (accumulatedExtend == 0) {
                    accumulatedExtend = att.talk.extendDown;
                    height = widget.height * accumulatedExtend;
                  }
                  accumulatedExtend--;
                  bool isDivider = "divider" == att.slotInfo.type;
                  if (isDivider) {
                    height = kDividerSlotHeight;
                  }

                  return height != 0.0
                      ? Container(
                          height: height,
                          width: widget.myTrackWidth,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: isDivider
                                    ? Color(0xFFEEEEEE)
                                    : Colors.transparent,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(att.slotInfo.start,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black54)),
                                    SizedBox(
                                      height: isDivider ? 3.0 : 5.0,
                                    ),
                                    Expanded(
                                      child: ScaleTransition(
                                        scale: widget.scale
                                            .drive(Tween(begin: 1.0, end: 0.0)),
                                        child: att.talk != null
                                            ? Column(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.0),
                                                      child: Text(
                                                        att.talk.title,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                    ),
                                                  ),
                                                  isDivider
                                                      ? SizedBox()
                                                      : Text(att.talk.track,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black26)),
                                                ],
                                              )
                                            : Container(),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox();
                },
                itemCount: daySchedule.length,
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
