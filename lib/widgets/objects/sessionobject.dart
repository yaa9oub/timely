class Session {
  final String sessionNumber, time, label, type, classroom, regime;

  Session(
      {required this.sessionNumber,
      required this.time,
      required this.label,
      required this.type,
      required this.classroom,
      required this.regime});

  Map<String, dynamic> toJson() => {
        'sessionNumber': sessionNumber,
        'time': time,
        'label': label,
        'type': type,
        'classroom': classroom,
        'regime': regime,
      };

  Session.fromJson(Map<String, dynamic> json)
      : sessionNumber = json['sessionNumber'],
        time = json['time'],
        label = json['label'],
        type = json['type'],
        classroom = json['classroom'],
        regime = json['regime'];
}
