import 'dart:convert' as parser;

import 'package:commitconf/domain/domain.dart';

Map<String, dynamic> decode(String string) {
  return parser.jsonDecode(string);
}

Schedule parseSchedule(Map<String, dynamic> data) {
  final scheduleData = data['schedule'];
  final day1Data = scheduleData['2018-11-23'];
  final day2Data = scheduleData['2018-11-24'];
  final day1 = parseDay(day1Data, data);
  final day2 = parseDay(day2Data, data);
  return Schedule(
    day1: day1,
    day2: day2,
  );
}

Day parseDay(Map<String, dynamic> daydata, Map<String, dynamic> data) {
  final List<dynamic> timeslots = daydata['timeslots'];
  final List<dynamic> tracks = daydata['tracks'];

  final slotInfo = <SlotInfo>[];

  final List<List<Talk>> trackList =
      List.generate(tracks.length, (_) => <Talk>[]);

  for (final slot in timeslots) {
    final List<dynamic> sessions = slot['sessions'];
    var position = 0; // Position that defines a talk
    for (int t = 0; t < tracks.length; t++) {
      if (t < sessions.length && t == position) {
        final talk = sessions[t]['items'][0];
        if (talk == null || talk == "") {
          trackList[t].add(emptyTalk);
          continue;
        }
        final extendRight = sessions[t]['extendRight'] ?? 1;
        position = t + extendRight;
        final extendDown = sessions[t]['extendDown'] ?? 1;
        trackList[t].add(parseTalk(talk, data, extendRight, extendDown));
      } else {
        trackList[t].add(emptyTalk);
      }
    }
    slotInfo.add(SlotInfo(
      start: slot['startTime'],
      end: slot['endTime'],
    ));
  }

  List<Track> finalTracks = [];
  for (int i = 0; i < tracks.length; i++) {
    finalTracks
        .add(Track(talks: trackList[i], name: daydata['tracks'][0]['title']));
  }

  return Day(
    slotInfo: slotInfo,
    tracks: finalTracks,
  );
}

Talk parseTalk(id, Map<String, dynamic> data,
    [int extendRight = 1, int extendDown = 1]) {
  final talk = data['sessions'][id];

  return Talk(
    id: id,
    title: talk['title'],
    description: talk['description'],
    speakers: parseSpeakers(talk['speakers'], data),
    extendRight: extendRight,
    extendDown: extendDown,
  );
}

List<Speaker> parseSpeakers(List<dynamic> speakerIds, data) {
  final speakersData = data['speakers'];
  final List<Speaker> speakers = <Speaker>[];
  if (speakerIds == null) {
    return <Speaker>[];
  }
  for (String speakerId in speakerIds) {
    final speakerData = speakersData[speakerId];
    Speaker speaker = Speaker(
      id: speakerId,
      name: speakerData['name'],
      picture: speakerData['photoUrl'],
    );
    speakers.add(speaker);
  }
  return speakers;
}
