import 'dart:convert';

class RouteInfo {
  String? routeId;
  String? routeName;
  int? totalGatePass;
  double? totalGatePassAmount;
  int? totalCustomer;

  RouteInfo({
    this.routeId,
    this.routeName,
    this.totalGatePass,
    this.totalGatePassAmount,
    this.totalCustomer,
  });

  RouteInfo copyWith({
    String? routeId,
    String? routeName,
    int? totalGatePass,
    double? totalGatePassAmount,
    int? totalCustomer,
  }) =>
      RouteInfo(
        routeId: routeId ?? this.routeId,
        routeName: routeName ?? this.routeName,
        totalGatePass: totalGatePass ?? this.totalGatePass,
        totalGatePassAmount: totalGatePassAmount ?? this.totalGatePassAmount,
        totalCustomer: totalCustomer ?? this.totalCustomer,
      );

  factory RouteInfo.fromJson(String str) => RouteInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RouteInfo.fromMap(Map<String, dynamic> json) => RouteInfo(
        routeId: json["route_id"],
        routeName: json["route_name"],
        totalGatePass: json["total_gate_pass"],
        totalGatePassAmount: json["total_gate_pass_amount"],
        totalCustomer: json["total_customer"],
      );

  Map<String, dynamic> toMap() => {
        "route_id": routeId,
        "route_name": routeName,
        "total_gate_pass": totalGatePass,
        "total_gate_pass_amount": totalGatePassAmount,
        "total_customer": totalCustomer,
      };
}
