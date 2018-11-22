import 'package:commitconf/services/conference_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConferenceBlocProvider extends StatefulWidget {
  final Widget child;
  final ConferenceBloc bloc;

  ConferenceBlocProvider({Key key, @required this.child, @required this.bloc})
      : super(key: key);

  @override
  _ConferenceBlocProviderState createState() => _ConferenceBlocProviderState();

  static ConferenceBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_ConferenceBlocProvider)
            as _ConferenceBlocProvider)
        .bloc;
  }
}

class _ConferenceBlocProviderState extends State<ConferenceBlocProvider> {
  @override
  Widget build(BuildContext context) {
    return _ConferenceBlocProvider(bloc: widget.bloc, child: widget.child);
  }

  @override
  void dispose() {
    widget.bloc.close();
    super.dispose();
  }
}

class _ConferenceBlocProvider extends InheritedWidget {
  final ConferenceBloc bloc;

  _ConferenceBlocProvider({
    Key key,
    @required this.bloc,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_ConferenceBlocProvider old) => bloc != old.bloc;
}
