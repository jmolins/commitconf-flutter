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
  int _currentIndex = 0;

  var _currentScreen;

  Schedule _schedule;

  StreamSubscription<Schedule> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.bloc.schedule.listen((schedule) {
      setState(() {
        _schedule = schedule;
        _currentScreen = DayScreen(schedule.days[0], 0);
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
        title: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/logo.png',
              ),
              SizedBox(
                width: 15.0,
              ),
              Text("Commit Conf")
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            title: Text("November 23"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            title: Text("November 24"),
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _currentScreen = DayScreen(_schedule.days[index], index);
          });
        },
      ),
      body: _schedule == null
          ? Center(child: CircularProgressIndicator())
          : _currentScreen,
    );
  }
}
