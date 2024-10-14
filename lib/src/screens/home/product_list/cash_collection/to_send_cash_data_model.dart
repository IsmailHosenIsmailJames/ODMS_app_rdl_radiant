import 'dart:convert';

class ToSendCashDataModel {
  String? billingDocNo;
  String? lastStatus;
  String? type;
  double? cashCollection;
  String? cashCollectionLatitude;
  String? cashCollectionLongitude;
  String? cashCollectionStatus;
  List<DeliveryCash> delivers;
  dynamic billingDate;
  String? partner;
  String? gatePassNo;
  String? daCode;
  String? routeCode;

  // "billing_date":"2024-10-06",
  //   "partner":"11044314",
  //   "gate_pass_no":"2426005431",
  //   "da_code":"50010",
  //   "route_code":"400551",

  ToSendCashDataModel({
    this.billingDocNo,
    this.lastStatus,
    this.type,
    this.cashCollection,
    this.cashCollectionLatitude,
    this.cashCollectionLongitude,
    this.cashCollectionStatus,
    this.billingDate,
    this.partner,
    this.gatePassNo,
    this.daCode,
    this.routeCode,
    required this.delivers,
  });

  ToSendCashDataModel copyWith({
    String? billingDocNo,
    String? lastStatus,
    String? type,
    double? cashCollection,
    String? cashCollectionLatitude,
    String? cashCollectionLongitude,
    String? cashCollectionStatus,
    dynamic billingDate,
    String? partner,
    String? gatePassNo,
    String? daCode,
    String? routeCode,
    List<DeliveryCash>? delivers,
  }) =>
      ToSendCashDataModel(
        billingDocNo: billingDocNo ?? this.billingDocNo,
        lastStatus: lastStatus ?? this.lastStatus,
        type: type ?? this.type,
        cashCollection: cashCollection ?? this.cashCollection,
        cashCollectionLatitude:
            cashCollectionLatitude ?? this.cashCollectionLatitude,
        cashCollectionLongitude:
            cashCollectionLongitude ?? this.cashCollectionLongitude,
        cashCollectionStatus: cashCollectionStatus ?? this.cashCollectionStatus,
        billingDate: billingDate ?? this.billingDate,
        partner: partner ?? this.partner,
        gatePassNo: gatePassNo ?? this.gatePassNo,
        daCode: daCode ?? this.daCode,
        routeCode: routeCode ?? this.routeCode,
        delivers: delivers ?? this.delivers,
      );

  factory ToSendCashDataModel.fromJson(String str) =>
      ToSendCashDataModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ToSendCashDataModel.fromMap(Map<String, dynamic> json) =>
      ToSendCashDataModel(
        billingDocNo: json["billing_doc_no"],
        lastStatus: json["last_status"],
        type: json["type"],
        cashCollection: json["cash_collection"],
        cashCollectionLatitude: json["cash_collection_latitude"],
        cashCollectionLongitude: json["cash_collection_longitude"],
        cashCollectionStatus: json["cash_collection_status"],
        billingDate: json["billing_date"],
        partner: json["partner"],
        gatePassNo: json['gate_pass_no'],
        daCode: json["da_code"],
        routeCode: json["route_code"],
        delivers: List<DeliveryCash>.from(
            json["deliverys"].map((x) => DeliveryCash.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "billing_doc_no": billingDocNo,
        "last_status": lastStatus,
        "type": type,
        "cash_collection": cashCollection,
        "cash_collection_latitude": cashCollectionLatitude,
        "cash_collection_longitude": cashCollectionLongitude,
        "cash_collection_status": cashCollectionStatus,
        "billing_date": billingDate,
        "partner": partner,
        "gate_pass_no": gatePassNo,
        "da_code": daCode,
        "route_code": routeCode,
        "deliverys": List<dynamic>.from(delivers.map((x) => x.toMap())),
      };
}

//01521713619

class DeliveryCash {
  int? returnQuantity;
  // String? returnNetVal;
  // double? vat;
  String? batch;
  String? id;

  DeliveryCash({
    this.returnQuantity,
    // this.returnNetVal,
    // this.vat,
    this.batch,
    this.id,
  });

  DeliveryCash copyWith({
    int? returnQuantity,
    String? returnNetVal,
    double? vat,
    String? batch,
    String? id,
  }) =>
      DeliveryCash(
        returnQuantity: returnQuantity ?? this.returnQuantity,
        // returnNetVal: returnNetVal ?? this.returnNetVal,
        // vat: vat ?? this.vat,
        batch: batch ?? this.batch,
        id: id ?? this.id,
      );

  factory DeliveryCash.fromJson(String str) =>
      DeliveryCash.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DeliveryCash.fromMap(Map<String, dynamic> json) => DeliveryCash(
        returnQuantity: json["return_quantity"],
        // returnNetVal: json["return_net_val"],
        // vat: json["vat"],
        batch: json['batch'],
        id: json["id"],
      );

  Map<String, dynamic> toMap() => {
        "return_quantity": returnQuantity,
        // "return_net_val": returnNetVal,
        // "vat": vat,
        "batch": batch,
        "id": id,
      };
}
