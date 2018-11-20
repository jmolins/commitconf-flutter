import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/domain/local_data.dart';
import 'package:commitconf/domain/network_data.dart';
import 'package:commitconf/widgets/day_screen.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  ScheduleScreen();

  @override
  ScheduleScreenState createState() {
    return new ScheduleScreenState();
  }
}

class ScheduleScreenState extends State<ScheduleScreen> {
  int _currentIndex = 0;

  Schedule _schedule;

  var _currentScreen;

  @override
  void initState() {
    super.initState();
    loadScheduleFromLocal();
  }

  void loadScheduleFromLocal() {
    getSchedule(context).then((schedule) {
      setState(() {
        _schedule = schedule;
        _currentScreen = DayScreen(_schedule.day1);
        print("Loaded from local");
      });
    }).then((_) {
      //loadScheduleFromNetwork();
    });
  }

  void loadScheduleFromNetwork() {
    getNetworkSchedule().then((schedule) {
      setState(() {
        _schedule = schedule;
        print("Loaded from network");
      });
    }).catchError((error) {
      print("Network Error :-(");
      print(error);
    });
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
            switch (index) {
              case 0:
                _currentScreen = DayScreen(_schedule.day1);
                break;
              case 1:
                _currentScreen = DayScreen(_schedule.day2);
                break;
            }
          });
        },
      ),
      body: Container(
        child: _currentScreen,
      ),
    );
  }
}
