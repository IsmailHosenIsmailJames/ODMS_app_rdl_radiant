import 'dart:convert';

class CustomPositionModel {
  double latitude;
  double longitude;
  DateTime timestamp;

  CustomPositionModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  CustomPositionModel copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) =>
      CustomPositionModel(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        timestamp: timestamp ?? this.timestamp,
      );

  factory CustomPositionModel.fromJson(String str) =>
      CustomPositionModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomPositionModel.fromMap(Map<String, dynamic> json) =>
      CustomPositionModel(
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      );

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };
}

/*
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "timestamp": 1748683465000
}

*/
