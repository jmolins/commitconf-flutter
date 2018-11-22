import 'dart:async';

import 'package:commitconf/domain/domain.dart';
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
    _subscription = widget.bloc.schedule.listen((schedule) {
      setState(() {
        _schedule = schedule;
      });
    });
  }

  @override
  void dispose() {
    if (_subscription != null) _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Padding(
          padding: EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Image.asset('assets/logo.png'),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => selectDate(0),
              child: Column(
                children: [
                  Icon(Icons.today, color: Colors.black45),
                  Text("November 23"),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => selectDate(1),
              child: Column(
                children: [
                  Icon(Icons.today, color: Colors.black45),
                  Text("November 24"),
                ],
              ),
            ),
          ),
          SizedBox(width: 15.0)
        ],
      ),
      body: _schedule == null
          ? Center(child: CircularProgressIndicator())
          : DayScreen(
              key: keys[_currentIndex],
              day: _schedule.days[_currentIndex],
              dayIndex: _currentIndex,
            ),
    );
  }

  void selectDate(int dateIndex) {
    setState(() {
      _currentIndex = dateIndex;
    });
  }
}
