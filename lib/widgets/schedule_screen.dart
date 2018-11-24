import 'dart:async';

import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/domain/local_data.dart';
import 'package:commitconf/services/conference_bloc.dart';
import 'package:commitconf/widgets/day_screen.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  final ConferenceBloc bloc;

  ScheduleScreen({this.bloc});

  @override
  ScheduleScreenState createState() {
    return new ScheduleScreenState();
  }
}

class ScheduleScreenState extends State<ScheduleScreen> {
  var keys = [UniqueKey(), UniqueKey()];

  int _currentIndex = 0;

  Schedule _schedule;

  StreamSubscription<Schedule> _subscription;

  @override
  void initState() {
    super.initState();
    //loadScheduleFromLocal();
    _subscription = widget.bloc.schedule.listen((schedule) {
      setState(() {
        _schedule = schedule;
      });
    });
  }

  void loadScheduleFromLocal() {
    getSchedule(context).then((schedule) {
      widget.bloc.setSchedule(schedule);
      print("Loaded from local");
    }).then((_) {
      //loadScheduleFromNetwork();
    });
  }

  @override
  void dispose() {
    if (_subscription != null) _subscription.cancel();
    super.dispose();
  }

  _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 25.0,
                ),
                Text("Built with Flutter",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 25.0,
                ),
                Text("by Chema Molins"),
                Text("@jmolins"),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: Padding(
          padding: EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Image.asset('assets/logo.png'),
          ),
        ),
        actions: [
          // This buttons could be extracted to a widget
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => selectDate(0),
              child: Column(
                children: [
                  Icon(
                    Icons.today,
                    color: _currentIndex == 0 ? Colors.black87 : Colors.black26,
                  ),
                  Text(
                    "November 23",
                    style: TextStyle(
                      color: _currentIndex == 0 ? Colors.black : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => selectDate(1),
              child: Column(
                children: [
                  Icon(
                    Icons.today,
                    color: _currentIndex == 0 ? Colors.black26 : Colors.black87,
                  ),
                  Text(
                    "November 24",
                    style: TextStyle(
                      color: _currentIndex == 0 ? Colors.black38 : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 3.0),
          IconButton(
            icon: Icon(Icons.info),
            color: Colors.black54,
            onPressed: () {
              _showDialog(context);
            },
          ),
        ],
      ),
      body: _schedule == null
          ? Center(child: CircularProgressIndicator())
          : DayScreen(
              key: keys[_currentIndex],
              day: _schedule.days[_currentIndex],
              dayIndex: _currentIndex,
              bloc: widget.bloc,
            ),
    );
  }

  void selectDate(int dateIndex) {
    setState(() {
      _currentIndex = dateIndex;
    });
  }
}
