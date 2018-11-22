import 'package:commitconf/services/conference_bloc.dart';
import 'package:commitconf/services/conference_bloc_provider.dart';
import 'package:commitconf/widgets/schedule_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bloc = ConferenceBloc();

    bloc.loadScheduleFromNetwork();

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
