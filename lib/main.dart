import 'package:commitconf/services/conference_bloc.dart';
import 'package:commitconf/services/conference_bloc_provider.dart';
import 'package:commitconf/widgets/schedule_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
}

// Make it stateful so ConferenceBloc is not recreated in hot-reload
class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  var bloc = ConferenceBloc();

  @override
  void initState() {
    super.initState();
    bloc.loadScheduleFromNetwork();
  }

  @override
  Widget build(BuildContext context) {
    return ConferenceBlocProvider(
      bloc: bloc,
      child: MaterialApp(
        title: 'CommitConf app',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ScheduleScreen(
          bloc: bloc,
        ),
      ),
    );
  }
}
