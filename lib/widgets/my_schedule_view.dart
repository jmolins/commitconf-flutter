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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.bloc.mySchedule,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.data != null) {
            List<Attendance> daySchedule = snapshot.data[widget.day];

            return ListView.builder(
              scrollDirection: Axis.vertical,
              controller: widget.scrollController,
              itemBuilder: (context, index) => Container(
                    height: widget.height,
                    width: widget.width,
                    child: Column(
                      children: <Widget>[
                        Text(daySchedule[index].slotInfo.start),
                        daySchedule[index].talk != null
                            ? Text(daySchedule[index].talk.title)
                            : Container(),
                      ],
                    ),
                  ),
              itemCount: daySchedule.length,
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
