import 'package:intl/intl.dart';

class Earthquake {
  final double magnitude;
  final String locationDescription;
  final DateTime occurredAt;
  final double depth;
  final double latitude;
  final double longitude;

  Earthquake({
    required this.magnitude,
    required this.locationDescription,
    required this.occurredAt,
    required this.depth,
    required this.latitude,
    required this.longitude,
  });

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'];
    final coordinates = json['geometry']['coordinates'];

    return Earthquake(
      magnitude: (properties['mag'] as num?)?.toDouble() ?? 0.0,
      locationDescription: properties['place']?.toString() ?? 'Unknown location',
      occurredAt: DateTime.fromMillisecondsSinceEpoch(properties['time'] as int),
      depth: (properties['depth'] as num?)?.toDouble() ?? 0.0,
      latitude: (coordinates[1] as num?)?.toDouble() ?? 0.0,
      longitude: (coordinates[0] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get formattedTime {
    return DateFormat('h:mm a, yyyy-MM-dd').format(occurredAt.toLocal());
  }
}