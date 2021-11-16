import 'dart:convert';

class Abscence {
  String subject;
  int number;

  Abscence({required this.subject, required this.number});

  static Map<String, dynamic> toMap(Abscence abscence) => {
        'subject': abscence.subject,
        'number': abscence.number,
      };

  static String encode(List<Abscence> abscences) => json.encode(
        abscences
            .map<Map<String, dynamic>>((abscence) => Abscence.toMap(abscence))
            .toList(),
      );

  factory Abscence.fromJson(Map<String, dynamic> jsonData) {
    return Abscence(subject: jsonData['subject'], number: jsonData['number']);
  }

  static List<Abscence> decode(String abscences) =>
      (json.decode(abscences) as List<dynamic>)
          .map<Abscence>((item) => Abscence.fromJson(item))
          .toList();
}
