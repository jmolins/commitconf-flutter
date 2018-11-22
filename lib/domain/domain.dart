class Schedule {
  final List<Day> days;

  Schedule({
    this.days,
  });
}

class SlotInfo {
  final int position;
  final String start;
  final String end;

  SlotInfo({
    this.position,
    this.start,
    this.end,
  });
}

class Day {
  final String id;
  final List<Track> tracks;
  final List<SlotInfo> slotInfo;

  Day({
    this.id,
    this.tracks,
    this.slotInfo,
  });
}

class Track {
  final List<Talk> talks;
  final String name;

  Track({
    this.talks,
    this.name,
  });
}

final emptyTalk = Talk(
  id: "",
  title: "",
  speakers: [],
);

class Talk {
  final String id;
  final String title;
  final String description;
  final List<Speaker> speakers;
  final int extendRight;
  final int extendDown;

  Talk({
    this.id,
    this.title,
    this.description,
    this.speakers,
    this.extendRight = 1,
    this.extendDown = 1,
  });

  @override
  String toString() {
    return 'Talk: $title';
  }
}

class Speaker {
  final id;
  final String name;
  final String picture;

  Speaker({
    this.id,
    this.name,
    this.picture,
  });
}

/// Talk the user is attending
class Attendance {
  final Talk talk;
  final SlotInfo slotInfo;

  Attendance({this.talk, this.slotInfo});
}
