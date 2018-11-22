import 'dart:async';

import 'package:commitconf/domain/domain.dart';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConferenceBloc {
  SharedPreferences prefs;
  Schedule _schedule;

  List<List<Attendance>> _mySchedule;

  final _scheduleController = PublishSubject<Schedule>();
  final _myScheduleController = BehaviorSubject<List<List<Attendance>>>();

  ConferenceBloc();

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

  void initMySchedule() {
    assert(_schedule != null);
    if (_mySchedule == null) {
      _mySchedule = _schedule.days.map((day) {
        print(day.id);
        return day.slotInfo.map((slotInfo) {
          print(slotInfo.start);
          return Attendance(slotInfo: slotInfo);
        }).toList();
      }).toList();
    }
  }

  void registerAttendance(Talk talk, int day, SlotInfo slotInfo) {
    List<Attendance> daySchedule = _mySchedule[day];
    bool registered = false;
    for (int i = 0; i < daySchedule.length; i++) {
      if (slotInfo.position < daySchedule[i].slotInfo.position) {
        // The slot is empty
        daySchedule.insert(i, Attendance(talk: talk, slotInfo: slotInfo));
        registered = true;
        break;
      } else if (slotInfo.position == daySchedule[i].slotInfo.position) {
        if (daySchedule[i].talk == null || daySchedule[i].talk.id != talk.id) {
          // There is another talk
          daySchedule[i] = Attendance(talk: talk, slotInfo: slotInfo);
        } else {
          // The talk already exists. Don't do anything
        }
        registered = true;
        break;
      }
    }
    if (!registered) {
      daySchedule.add(Attendance(talk: talk, slotInfo: slotInfo));
    }
    _myScheduleController.add(_mySchedule);
  }
}
