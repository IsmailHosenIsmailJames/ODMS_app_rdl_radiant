import 'dart:convert';

class ToSendCashDataModel {
  String billingDocNo;
  String lastStatus;
  String type;
  int cashCollection;
  String cashCollectionLatitude;
  String cashCollectionLongitude;
  String cashCollectionStatus;
  List<DeliveryCash> deliverys;

  ToSendCashDataModel({
    required this.billingDocNo,
    required this.lastStatus,
    required this.type,
    required this.cashCollection,
    required this.cashCollectionLatitude,
    required this.cashCollectionLongitude,
    required this.cashCollectionStatus,
    required this.deliverys,
  });

  ToSendCashDataModel copyWith({
    String? billingDocNo,
    String? lastStatus,
    String? type,
    int? cashCollection,
    String? cashCollectionLatitude,
    String? cashCollectionLongitude,
    String? cashCollectionStatus,
    List<DeliveryCash>? deliverys,
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
        deliverys: deliverys ?? this.deliverys,
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
        deliverys: List<DeliveryCash>.from(
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
        "deliverys": List<dynamic>.from(deliverys.map((x) => x.toMap())),
      };
}

class DeliveryCash {
  int returnQuantity;
  int returnNetVal;
  int vat;
  int id;

  DeliveryCash({
    required this.returnQuantity,
    required this.returnNetVal,
    required this.vat,
    required this.id,
  });

  DeliveryCash copyWith({
    int? returnQuantity,
    int? returnNetVal,
    int? vat,
    int? id,
  }) =>
      DeliveryCash(
        returnQuantity: returnQuantity ?? this.returnQuantity,
        returnNetVal: returnNetVal ?? this.returnNetVal,
        vat: vat ?? this.vat,
        id: id ?? this.id,
      );

  factory DeliveryCash.fromJson(String str) =>
      DeliveryCash.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DeliveryCash.fromMap(Map<String, dynamic> json) => DeliveryCash(
        returnQuantity: json["return_quantity"],
        returnNetVal: json["return_net_val"],
        vat: json["vat"],
        id: json["id"],
      );

  Map<String, dynamic> toMap() => {
        "return_quantity": returnQuantity,
        "return_net_val": returnNetVal,
        "vat": vat,
        "id": id,
      };
}
