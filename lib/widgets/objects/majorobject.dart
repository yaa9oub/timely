import 'dart:convert';

class Major {
  final String majorId, label;

  Major({
    required this.majorId,
    required this.label,
  });

  static Map<String, dynamic> toMap(Major major) => {
        'majorId': major.majorId,
        'majorLbl': major.label,
      };

  static String encode(List<Major> majors) => json.encode(
        majors
            .map<Map<String, dynamic>>((major) => Major.toMap(major))
            .toList(),
      );

  factory Major.fromJson(Map<String, dynamic> jsonData) {
    return Major(majorId: jsonData['majorId'], label: jsonData['majorLbl']);
  }

  static List<Major> decode(String majors) =>
      (json.decode(majors) as List<dynamic>)
          .map<Major>((item) => Major.fromJson(item))
          .toList();
}
