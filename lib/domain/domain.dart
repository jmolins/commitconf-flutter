class Schedule {
  final List<Day> days;
  final Map<String, Talk> talks;

  Schedule({
    this.days,
    this.talks,
  });
}

class SlotInfo {
  final int position;
  final String start;
  final String end;
  final String type;

  SlotInfo({
    this.position,
    this.start,
    this.end,
    this.type,
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
  extendRight: 1,
  extendDown: 1,
);

class Talk {
  final String id;
  final String title;
  final String description;
  final List<Speaker> speakers;
  final int extendRight;
  final int extendDown;
  final bool allTracks;

  Talk({
    this.id,
    this.title,
    this.description,
    this.speakers,
    this.extendRight = 1,
    this.extendDown = 1,
    this.allTracks = false,
  });

  Talk.fromJson(Map<String, dynamic> json)
      : this.id = json['id'],
        this.title = json['title'],
        this.description = json['description'],
        this.speakers = json['speakers'],
        this.extendRight = json['extendRight'],
        this.extendDown = json['extendDown'],
        this.allTracks = json['allTracks'];

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

  Attendance({
    this.talk,
    this.slotInfo,
  });

  Attendance copyWith({Talk talk, SlotInfo slotInfo}) {
    return Attendance(
      talk: talk ?? this.talk,
      slotInfo: slotInfo ?? this.slotInfo,
    );
  }
}
