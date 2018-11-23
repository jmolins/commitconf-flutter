import 'dart:convert' as parser;

import 'package:commitconf/domain/domain.dart';

Map<String, dynamic> decode(String string) {
  return parser.jsonDecode(string);
}

Schedule parseSchedule(Map<String, dynamic> data) {
  Map<String, Talk> talks = {};

  return Schedule(
    talks: talks,
    days: [
      parseDay('2018-11-23', data, talks),
      parseDay('2018-11-24', data, talks),
    ],
  );
}

Day parseDay(String dayId, Map<String, dynamic> data, Map<String, Talk> talks) {
  final daydata = data['schedule'][dayId];

  final List<dynamic> timeslots = daydata['timeslots'];
  final List<dynamic> tracks = daydata['tracks'];

  final slotInfo = <SlotInfo>[];

  final List<List<Talk>> trackList =
      List.generate(tracks.length, (_) => <Talk>[]);

  for (int slotIndex = 0; slotIndex < timeslots.length; slotIndex++) {
    final slot = timeslots[slotIndex];
    final List<dynamic> sessions = slot['sessions'];
    var position = 0; // Position that defines a talk
    for (int t = 0; t < tracks.length; t++) {
      if (t < sessions.length && t == position) {
        final talkData = sessions[t]['items'][0];
        if (talkData == null || talkData == "") {
          trackList[t].add(emptyTalk);
          continue;
        }
        final extendRight = sessions[t]['extendRight'] ?? 1;
        position = t + extendRight;
        final extendDown = sessions[t]['extendDown'] ?? 1;
        Talk talk = parseTalk(
          talkData,
          data,
          extendRight == trackList.length,
          extendRight,
          extendDown,
        );
        trackList[t].add(talk);
        talks[talk.id] = talk;
      } else {
        trackList[t].add(emptyTalk);
      }
    }
    slotInfo.add(SlotInfo(
      position: slotIndex,
      start: slot['startTime'],
      end: slot['endTime'],
      type: slot['type'],
    ));
  }

  List<Track> finalTracks = [];
  for (int i = 0; i < tracks.length; i++) {
    finalTracks
        .add(Track(talks: trackList[i], name: daydata['tracks'][i]['title']));
  }

  return Day(
    id: dayId,
    slotInfo: slotInfo,
    tracks: finalTracks,
  );
}

Talk parseTalk(id, Map<String, dynamic> data, bool allTracks,
    [int extendRight = 1, int extendDown = 1]) {
  final talk = data['sessions'][id];

  return Talk(
    id: id,
    title: talk['title'],
    description: talk['description'],
    speakers: parseSpeakers(talk['speakers'], data),
    extendRight: extendRight,
    extendDown: extendDown,
    allTracks: allTracks,
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
