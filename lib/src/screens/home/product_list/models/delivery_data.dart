import 'dart:convert';

class DeliveryData {
  String? billingDocNo;
  String? billingDate;
  String? routeCode;
  String? partner;
  String? gatePassNo;
  String? daCode;
  String? vehicleNo;
  String? deliveryLatitude;
  String? deliveryLongitude;
  String? transportType;
  String? deliveryStatus;
  String? lastStatus;
  String? type;
  double? cashCollection;
  String? cashCollectionLatitude;
  String? cashCollectionLongitude;
  String? cashCollectionStatus;
  List<Delivery> delivers;

  DeliveryData({
    this.billingDocNo,
    this.billingDate,
    this.routeCode,
    this.partner,
    this.gatePassNo,
    this.daCode,
    this.vehicleNo,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.transportType,
    this.deliveryStatus,
    this.lastStatus,
    this.type,
    this.cashCollection,
    this.cashCollectionLatitude,
    this.cashCollectionLongitude,
    this.cashCollectionStatus,
    required this.delivers,
  });

  DeliveryData copyWith({
    String? billingDocNo,
    String? billingDate,
    String? routeCode,
    String? partner,
    String? gatePassNo,
    String? daCode,
    String? vehicleNo,
    String? deliveryLatitude,
    String? deliveryLongitude,
    String? transportType,
    String? deliveryStatus,
    String? lastStatus,
    String? type,
    double? cashCollection,
    String? cashCollectionLatitude,
    String? cashCollectionLongitude,
    String? cashCollectionStatus,
    List<Delivery>? delivers,
  }) =>
      DeliveryData(
        billingDocNo: billingDocNo ?? this.billingDocNo,
        billingDate: billingDate ?? this.billingDate,
        routeCode: routeCode ?? this.routeCode,
        partner: partner ?? this.partner,
        gatePassNo: gatePassNo ?? this.gatePassNo,
        daCode: daCode ?? this.daCode,
        vehicleNo: vehicleNo ?? this.vehicleNo,
        deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
        deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
        transportType: transportType ?? this.transportType,
        deliveryStatus: deliveryStatus ?? this.deliveryStatus,
        lastStatus: lastStatus ?? this.lastStatus,
        type: type ?? this.type,
        cashCollection: cashCollection ?? this.cashCollection,
        cashCollectionLatitude:
            cashCollectionLatitude ?? this.cashCollectionLatitude,
        cashCollectionLongitude:
            cashCollectionLongitude ?? this.cashCollectionLongitude,
        cashCollectionStatus: cashCollectionStatus ?? this.cashCollectionStatus,
        delivers: delivers ?? this.delivers,
      );

  factory DeliveryData.fromJson(String str) =>
      DeliveryData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DeliveryData.fromMap(Map<String, dynamic> json) => DeliveryData(
        billingDocNo: json["billing_doc_no"],
        billingDate: json["billing_date"],
        routeCode: json["route_code"],
        partner: json["partner"],
        gatePassNo: json["gate_pass_no"],
        daCode: json["da_code"],
        vehicleNo: json["vehicle_no"],
        deliveryLatitude: json["delivery_latitude"],
        deliveryLongitude: json["delivery_longitude"],
        transportType: json["transport_type"],
        deliveryStatus: json["delivery_status"],
        lastStatus: json["last_status"],
        type: json["type"],
        cashCollection: json["cash_collection"],
        cashCollectionLatitude: json["cash_collection_latitude"],
        cashCollectionLongitude: json["cash_collection_longitude"],
        cashCollectionStatus: json["cash_collection_status"],
        delivers: List<Delivery>.from(
            json["deliverys"].map((x) => Delivery.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "billing_doc_no": billingDocNo,
        "billing_date": billingDate,
        "route_code": routeCode,
        "partner": partner,
        "gate_pass_no": gatePassNo,
        "da_code": daCode,
        "vehicle_no": vehicleNo,
        "delivery_latitude": deliveryLatitude,
        "delivery_longitude": deliveryLongitude,
        "transport_type": transportType,
        "delivery_status": deliveryStatus,
        "last_status": lastStatus,
        "type": type,
        "cash_collection": cashCollection,
        "cash_collection_latitude": cashCollectionLatitude,
        "cash_collection_longitude": cashCollectionLongitude,
        "cash_collection_status": cashCollectionStatus,
        "deliverys": List<dynamic>.from(delivers.map((x) => x.toMap())),
      };
}

class Delivery {
  String? matnr;
  String? batch;
  int? quantity;
  double? tp;
  double? vat;
  double? netVal;
  int? deliveryQuantity;
  double? deliveryNetVal;
  int? returnQuantity;
  double? returnNetVal;
  int? id;

  Delivery({
    this.matnr,
    this.batch,
    this.quantity,
    this.tp,
    this.vat,
    this.netVal,
    this.deliveryQuantity,
    this.deliveryNetVal,
    this.returnQuantity,
    this.returnNetVal,
    this.id,
  });

  Delivery copyWith({
    String? matnr,
    String? batch,
    int? quantity,
    double? tp,
    double? vat,
    double? netVal,
    int? deliveryQuantity,
    double? deliveryNetVal,
    int? returnQuantity,
    double? returnNetVal,
    int? id,
  }) =>
      Delivery(
        matnr: matnr ?? this.matnr,
        batch: batch ?? this.batch,
        quantity: quantity ?? this.quantity,
        tp: tp ?? this.tp,
        vat: vat ?? this.vat,
        netVal: netVal ?? this.netVal,
        deliveryQuantity: deliveryQuantity ?? this.deliveryQuantity,
        deliveryNetVal: deliveryNetVal ?? this.deliveryNetVal,
        returnQuantity: returnQuantity ?? this.returnQuantity,
        returnNetVal: returnNetVal ?? this.returnNetVal,
        id: id ?? this.id,
      );

  factory Delivery.fromJson(String str) => Delivery.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Delivery.fromMap(Map<String, dynamic> json) => Delivery(
        matnr: json["matnr"],
        batch: json["batch"],
        quantity: json["quantity"],
        tp: json["tp"],
        vat: json["vat"],
        netVal: json["net_val"],
        deliveryQuantity: json["delivery_quantity"],
        deliveryNetVal: json["delivery_net_val"],
        returnQuantity: json["return_quantity"],
        returnNetVal: json["return_net_val"],
        id: json["id"],
      );

  Map<String, dynamic> toMap() => {
        "matnr": matnr,
        "batch": batch,
        "quantity": quantity,
        "tp": tp,
        "vat": vat,
        "net_val": netVal,
        "delivery_quantity": deliveryQuantity,
        "delivery_net_val": deliveryNetVal,
        "return_quantity": returnQuantity,
        "return_net_val": returnNetVal,
        "id": id,
      };
}
