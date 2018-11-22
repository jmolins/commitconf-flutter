import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/services/conference_bloc.dart';
import 'package:flutter/material.dart';

class MyScheduleView extends StatefulWidget {
  final int day;
  final double height;
  final double width;
  final ScrollController scrollController;
  final ConferenceBloc bloc;

  MyScheduleView(
      {this.day, this.height, this.width, this.scrollController, this.bloc});

  @override
  _MyScheduleViewState createState() => _MyScheduleViewState();
}

class _MyScheduleViewState extends State<MyScheduleView> {
  Stream<List<List<Attendance>>> _stream;

  @override
  void initState() {
    super.initState();
    //_stream = widget.bloc.mySchedule;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.bloc.mySchedule,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.data != null) {
            int accumulatedExtend = 0;
            List<Attendance> daySchedule = snapshot.data[widget.day];

            return ListView.builder(
              scrollDirection: Axis.vertical,
              controller: widget.scrollController,
              itemBuilder: (context, index) {
                double height = 0.0;
                if (accumulatedExtend == 0) {
                  accumulatedExtend = daySchedule[index].talk.extendDown;
                  height = widget.height * accumulatedExtend;
                }
                accumulatedExtend--;

                return height != 0.0
                    ? Container(
                        height: height,
                        width: widget.width,
                        child: Column(
                          children: <Widget>[
                            Text(daySchedule[index].slotInfo.start),
                            daySchedule[index].talk != null
                                ? Text(daySchedule[index].talk.title)
                                : Container(),
                          ],
                        ),
                      )
                    : SizedBox();
              },
              itemCount: daySchedule.length,
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
