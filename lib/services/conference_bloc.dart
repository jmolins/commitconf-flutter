import 'dart:async';
import 'dart:convert';

import 'package:commitconf/domain/domain.dart';
import 'package:commitconf/domain/network_data.dart';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConferenceBloc {
  static const String _kMyScheduleKey = "my_schedule_key";

  SharedPreferences prefs;
  Schedule _schedule;

  List<List<Attendance>> _mySchedule;

  final _scheduleController = PublishSubject<Schedule>();
  final _myScheduleController = BehaviorSubject<List<List<Attendance>>>();

  ConferenceBloc() {
    init();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  void close() {
    _scheduleController.close();
    _myScheduleController.close();
  }

  // Outputs
  Stream<Schedule> get schedule => _scheduleController.stream;

  Stream<List<List<Attendance>>> get mySchedule => _myScheduleController.stream;

  Stream<List<List<Attendance>>> get attendances =>
      _myScheduleController.stream;

  void setSchedule(Schedule schedule) {
    _schedule = schedule;
    initMySchedule();
    _scheduleController.add(_schedule);
    _myScheduleController.add(_mySchedule);
  }

  void loadScheduleFromNetwork() async {
    setSchedule(await getNetworkSchedule());
  }

  /// Saves active sources to localstorage
  void saveMySchedule() {
    List<List<String>> talkIds = _mySchedule.map((attendances) {
      return attendances.map((attendance) {
        return attendance.talk.id;
      }).toList();
    }).toList();
    prefs.setString(_kMyScheduleKey, jsonEncode(talkIds));
    //prefs.remove(_kMyScheduleKey);
  }

  /// Loads personal schedule from localstorage
  void initMySchedule() {
    assert(_schedule != null);
    if (_mySchedule == null) {
      _mySchedule = List.generate(2, (_) => <Attendance>[]);
      String myScheduleString = prefs.getString(_kMyScheduleKey);
      List<List<String>> talkIds;
      // If there are stored values
      if (myScheduleString != null) {
        talkIds = [];
        List<dynamic> list = jsonDecode(myScheduleString);
        for (int i = 0; i < list.length; i++) {
          List<String> subList = list[i].cast<String>();
          talkIds.add(subList);
        }
      }
      // Otherwise create an empty array
      for (int dayIndex = 0; dayIndex < _schedule.days.length; dayIndex++) {
        Day day = _schedule.days[dayIndex];
        for (int slot = 0; slot < day.slotInfo.length; slot++) {
          Talk talk;
          // talksIds will be not null if there was something stored previously
          if (talkIds != null && slot < talkIds[dayIndex].length) {
            var talkId = talkIds[dayIndex][slot];
            talk = _schedule.talks.containsKey(talkId)
                ? _schedule.talks[talkId]
                : emptyTalk;
          }
          // If a talk occupies all the tracks in the global schedule, we
          // automatically add it to the user agenda since it does not have the
          // option to choose
          if (talk == null) {
            if (_schedule.days[dayIndex].tracks[0].talks[slot].extendRight ==
                _schedule.days[dayIndex].tracks.length) {
              talk = _schedule.days[dayIndex].tracks[0].talks[slot];
            }
          }
          _mySchedule[dayIndex].add(
            Attendance(
              talk: talk ?? emptyTalk,
              slotInfo: day.slotInfo[slot],
            ),
          );
        }
      }
    }
  }

  void registerAttendance(Talk talk, int day, SlotInfo slotInfo) {
    List<Attendance> daySchedule = _mySchedule[day];
    bool registered = false;
    int extension = 1;
    int extendedIndex = -1;
    for (int i = 0; i < daySchedule.length; i++) {
      // If we have a talk that extends more than one slot, we need to unregister this talk
      // when other talks are registered in the following slots
      // In this case we assign an empty talk to the first slot that was occupied by the longer talk
      if (daySchedule[i].talk.extendDown > 1) {
        extension = daySchedule[i].talk.extendDown;
        extendedIndex = i;
      }
      if (slotInfo.position == daySchedule[i].slotInfo.position) {
        if (daySchedule[i].talk == null || daySchedule[i].talk.id != talk.id) {
          // There is another talk
          daySchedule[i] = Attendance(talk: talk, slotInfo: slotInfo);
        } else {
          // The talk already exists. Don't do anything
        }
        registered = true;
        if (extendedIndex > -1 && i < extendedIndex + extension) {
          daySchedule[i + 1 - extension] =
              daySchedule[i + 1 - extension].copyWith(talk: emptyTalk);
        }
        break;
      }
    }
    if (!registered) {
      daySchedule.add(Attendance(talk: talk, slotInfo: slotInfo));
    }
    saveMySchedule();
    _myScheduleController.add(_mySchedule);
  }
}
