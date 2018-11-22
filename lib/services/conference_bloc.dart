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
    print("initBlod");
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
    print("_setSchedule");
    _schedule = schedule;
    initMySchedule();
    _scheduleController.add(_schedule);
    _myScheduleController.add(_mySchedule);
  }

  void loadScheduleFromNetwork() async {
    try {
      setSchedule(await getNetworkSchedule());
    } catch (error) {
      print("Network Error :-(");
      print(error);
    }
  }

  /// Saves active sources to localstorage
  void saveMySchedule() {
    List<List<String>> talkIds = _mySchedule.map((attendances) {
      return attendances.map((attendance) {
        return attendance.talk.id;
      }).toList();
    }).toList();
    prefs.setString(_kMyScheduleKey, jsonEncode(talkIds));
    print(prefs.getString(_kMyScheduleKey));
  }

/*  /// Loads active sources from localstorage
  void loadMySchedule() {
    String myScheduleString = prefs.getString(_kMyScheduleKey);
    if (myScheduleString != null) {
      activeSources = json.decode(myScheduleString).cast<String>();
      if (activeSources.isNotEmpty) {
        return;
      }
    }
    // Getting here means we were not able to get valid sources
    activeSources = ['cnn', 'bbc-news'];
    saveSources();
    return;
  }*/

  void initMySchedule() {
    assert(_schedule != null);
    if (_mySchedule == null) {
      _mySchedule = _schedule.days.map((day) {
        print(day.id);
        return day.slotInfo.map((slotInfo) {
          print(slotInfo.start);
          return Attendance(talk: emptyTalk, slotInfo: slotInfo);
        }).toList();
      }).toList();
    }
  }

  void registerAttendance(Talk talk, int day, SlotInfo slotInfo) {
    if (_mySchedule == null) {
      print("isNull");
    }
    List<Attendance> daySchedule = _mySchedule[day];
    bool registered = false;
    int extension = 1;
    int extendedIndex = -1;
    for (int i = 0; i < daySchedule.length; i++) {
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
          print(
              "${i + 1 - extension} TALK: ${daySchedule[i + 1 - extension].talk.title}");
          daySchedule[i + 1 - extension].copyWith(talk: emptyTalk);
          print(
              "${i + 1 - extension} TALK: ${daySchedule[i + 1 - extension].talk.title}");
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
