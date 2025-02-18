import 'dart:convert';

class RoutesInfo {
  int? totalGatePass;
  double? totalGatePassAmount;
  int? totalCustomer;
  List<RouteModel>? routes;

  RoutesInfo({
    this.totalGatePass,
    this.totalGatePassAmount,
    this.totalCustomer,
    this.routes,
  });

  RoutesInfo copyWith({
    int? totalGatePass,
    double? totalGatePassAmount,
    int? totalCustomer,
    List<RouteModel>? routes,
  }) =>
      RoutesInfo(
        totalGatePass: totalGatePass ?? this.totalGatePass,
        totalGatePassAmount: totalGatePassAmount ?? this.totalGatePassAmount,
        totalCustomer: totalCustomer ?? this.totalCustomer,
        routes: routes ?? this.routes,
      );

  factory RoutesInfo.fromJson(String str) =>
      RoutesInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RoutesInfo.fromMap(Map<String, dynamic> json) => RoutesInfo(
        totalGatePass: json["total_gate_pass"],
        totalGatePassAmount: json["total_gate_pass_amount"],
        totalCustomer: json["total_customer"],
        routes: json["routes"] == null
            ? []
            : List<RouteModel>.from(
                json["routes"]!.map((x) => RouteModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "total_gate_pass": totalGatePass,
        "total_gate_pass_amount": totalGatePassAmount,
        "total_customer": totalCustomer,
        "routes": routes == null
            ? []
            : List<dynamic>.from(routes!.map((x) => x.toMap())),
      };
}

class RouteModel {
  String? route;
  String? routeName;

  RouteModel({
    this.route,
    this.routeName,
  });

  RouteModel copyWith({
    String? route,
    String? routeName,
  }) =>
      RouteModel(
        route: route ?? this.route,
        routeName: routeName ?? this.routeName,
      );

  factory RouteModel.fromJson(String str) =>
      RouteModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RouteModel.fromMap(Map<String, dynamic> json) => RouteModel(
        route: json["route"],
        routeName: json["route_name"],
      );

  Map<String, dynamic> toMap() => {
        "route": route,
        "route_name": routeName,
      };
}
