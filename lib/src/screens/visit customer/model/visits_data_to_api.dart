import 'dart:convert';

class VisitsDataToApiModel {
  String? daCode;
  String? routeCode;
  String? partner;
  String? visitType;
  dynamic visitLatitude;
  dynamic visitLongitude;
  String? comment;

  VisitsDataToApiModel({
    this.daCode,
    this.routeCode,
    this.partner,
    this.visitType,
    this.visitLatitude,
    this.visitLongitude,
    this.comment,
  });

  VisitsDataToApiModel copyWith({
    String? daCode,
    String? routeCode,
    String? partner,
    String? visitType,
    dynamic visitLatitude,
    dynamic visitLongitude,
    String? comment,
  }) =>
      VisitsDataToApiModel(
        daCode: daCode ?? this.daCode,
        routeCode: routeCode ?? this.routeCode,
        partner: partner ?? this.partner,
        visitType: visitType ?? this.visitType,
        visitLatitude: visitLatitude ?? this.visitLatitude,
        visitLongitude: visitLongitude ?? this.visitLongitude,
        comment: comment ?? this.comment,
      );

  factory VisitsDataToApiModel.fromJson(String str) =>
      VisitsDataToApiModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VisitsDataToApiModel.fromMap(Map<String, dynamic> json) =>
      VisitsDataToApiModel(
        daCode: json['da_code'],
        routeCode: json['route_code'],
        partner: json['partner'],
        visitType: json['visit_type'],
        visitLatitude: json['visit_latitude'],
        visitLongitude: json['visit_longitude'],
        comment: json['comment'],
      );

  Map<String, dynamic> toMap() => {
        'da_code': daCode,
        'route_code': routeCode,
        'partner': partner,
        'visit_type': visitType,
        'visit_latitude': visitLatitude,
        'visit_longitude': visitLongitude,
        'comment': comment,
      };
}
