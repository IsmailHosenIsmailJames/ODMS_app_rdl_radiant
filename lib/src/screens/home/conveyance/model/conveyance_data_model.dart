import 'dart:convert';

class SavePharmaceuticalsLocationData {
  int? id;
  String? daCode;
  String? startJourneyLatitude;
  String? startJourneyLongitude;
  dynamic endJourneyLatitude;
  dynamic endJourneyLongitude;
  String? startJourneyDateTime;
  dynamic endJourneyDateTime;
  dynamic transportMode;
  dynamic transportCost;
  String? journeyStatus;
  String? distance;
  String? createdAt;
  String? updatedAt;

  SavePharmaceuticalsLocationData({
    this.id,
    this.daCode,
    this.startJourneyLatitude,
    this.startJourneyLongitude,
    this.endJourneyLatitude,
    this.endJourneyLongitude,
    this.startJourneyDateTime,
    this.endJourneyDateTime,
    this.transportMode,
    this.transportCost,
    this.journeyStatus,
    this.distance,
    this.createdAt,
    this.updatedAt,
  });

  SavePharmaceuticalsLocationData copyWith({
    int? id,
    String? daCode,
    String? startJourneyLatitude,
    String? startJourneyLongitude,
    dynamic endJourneyLatitude,
    dynamic endJourneyLongitude,
    String? startJourneyDateTime,
    dynamic endJourneyDateTime,
    dynamic transportMode,
    dynamic transportCost,
    String? journeyStatus,
    String? distance,
    String? createdAt,
    String? updatedAt,
  }) =>
      SavePharmaceuticalsLocationData(
        id: id ?? this.id,
        daCode: daCode ?? this.daCode,
        startJourneyLatitude: startJourneyLatitude ?? this.startJourneyLatitude,
        startJourneyLongitude:
            startJourneyLongitude ?? this.startJourneyLongitude,
        endJourneyLatitude: endJourneyLatitude ?? this.endJourneyLatitude,
        endJourneyLongitude: endJourneyLongitude ?? this.endJourneyLongitude,
        startJourneyDateTime: startJourneyDateTime ?? this.startJourneyDateTime,
        endJourneyDateTime: endJourneyDateTime ?? this.endJourneyDateTime,
        transportMode: transportMode ?? this.transportMode,
        transportCost: transportCost ?? this.transportCost,
        journeyStatus: journeyStatus ?? this.journeyStatus,
        distance: distance ?? this.distance,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory SavePharmaceuticalsLocationData.fromJson(String str) =>
      SavePharmaceuticalsLocationData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SavePharmaceuticalsLocationData.fromMap(Map<String, dynamic> json) =>
      SavePharmaceuticalsLocationData(
        id: json['id'],
        daCode: json['da_code'],
        startJourneyLatitude: json['start_journey_latitude'],
        startJourneyLongitude: json['start_journey_longitude'],
        endJourneyLatitude: json['end_journey_latitude'],
        endJourneyLongitude: json['end_journey_longitude'],
        startJourneyDateTime: json['start_journey_date_time'],
        endJourneyDateTime: json['end_journey_date_time'],
        transportMode: json['transport_mode'],
        transportCost: json['transport_cost'],
        journeyStatus: json['journey_status'],
        distance: json['distance'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'da_code': daCode,
        'start_journey_latitude': startJourneyLatitude,
        'start_journey_longitude': startJourneyLongitude,
        'end_journey_latitude': endJourneyLatitude,
        'end_journey_longitude': endJourneyLongitude,
        'start_journey_date_time': startJourneyDateTime,
        'end_journey_date_time': endJourneyDateTime,
        'transport_mode': transportMode,
        'transport_cost': transportCost,
        'journey_status': journeyStatus,
        'distance': distance,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
