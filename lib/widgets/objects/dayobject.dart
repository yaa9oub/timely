import 'package:timely/widgets/objects/sessionobject.dart';

class TheDay {
  final String day;
  final List<Session> sessions;

  TheDay({required this.day, required this.sessions});

  Map<String, dynamic> toJson() => {
        'day': day,
        'sessions': sessions,
      };

  TheDay.fromJson(Map<String, dynamic> json)
      : day = json['day'],
        sessions = json['sessions'];
}
