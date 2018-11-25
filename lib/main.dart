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

  final ThemeData base = ThemeData.light();

  @override
  void initState() {
    super.initState();
    //bloc.loadScheduleFromNetwork();
  }

  @override
  Widget build(BuildContext context) {
    return ConferenceBlocProvider(
      bloc: bloc,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CommitConf app',
        theme: base.copyWith(
          primaryColor: Colors.grey[200],
          scaffoldBackgroundColor: Colors.white,
          primaryTextTheme:
              base.primaryTextTheme.apply(bodyColor: Colors.grey[700]),
          iconTheme: base.iconTheme.copyWith(color: Colors.black54),
        ),
        home: ScheduleScreen(
          bloc: bloc,
        ),
      ),
    );
  }
}
