import 'dart:convert';

class OverdueResponseModel {
  bool success;
  List<Result>? result;

  OverdueResponseModel({
    required this.success,
    this.result,
  });

  OverdueResponseModel copyWith({
    bool? success,
    List<Result>? result,
  }) =>
      OverdueResponseModel(
        success: success ?? this.success,
        result: result ?? this.result,
      );

  factory OverdueResponseModel.fromJson(String str) =>
      OverdueResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OverdueResponseModel.fromMap(Map<String, dynamic> json) =>
      OverdueResponseModel(
        success: json["success"],
        result: json["result"] == null
            ? null
            : List<Result>.from(json["result"].map((x) => Result.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "result": result == null
            ? null
            : List<dynamic>.from(result!.map((x) => x.toMap())),
      };
}

class Result {
  String partnerId;
  String? customerName;
  String? customerAddress;
  String? customerMobile;
  String daFullName;
  String daMobileNo;
  List<BillingDoc>? billingDocs;

  Result({
    required this.partnerId,
    required this.customerName,
    required this.customerAddress,
    required this.customerMobile,
    required this.daFullName,
    required this.daMobileNo,
    this.billingDocs,
  });

  Result copyWith({
    String? partnerId,
    String? customerName,
    String? customerAddress,
    String? customerMobile,
    String? daFullName,
    String? daMobileNo,
    List<BillingDoc>? billingDocs,
  }) =>
      Result(
        partnerId: partnerId ?? this.partnerId,
        customerName: customerName ?? this.customerName,
        customerAddress: customerAddress ?? this.customerAddress,
        customerMobile: customerMobile ?? this.customerMobile,
        daFullName: daFullName ?? this.daFullName,
        daMobileNo: daMobileNo ?? this.daMobileNo,
        billingDocs: billingDocs ?? this.billingDocs,
      );

  factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Result.fromMap(Map<String, dynamic> json) => Result(
        partnerId: json["partner_id"],
        customerName: json["customer_name"],
        customerAddress: json["customer_address"],
        customerMobile: json["customer_mobile"],
        daFullName: json["da_full_name"],
        daMobileNo: json["da_mobile_no"],
        billingDocs: List<BillingDoc>.from(
            json["billing_docs"].map((x) => BillingDoc.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "partner_id": partnerId,
        "customer_name": customerName,
        "customer_address": customerAddress,
        "customer_mobile": customerMobile,
        "da_full_name": daFullName,
        "da_mobile_no": daMobileNo,
        "billing_docs": billingDocs == null
            ? null
            : List<dynamic>.from(billingDocs!.map((x) => x.toMap())),
      };
}

class BillingDoc {
  String billingDocNo;
  DateTime billingDate;
  String gatePassNo;
  String daCode;
  double? dueAmount;
  double? netVal;
  double? returnAmount;
  List<MaterialModel>? materials;

  BillingDoc({
    required this.billingDocNo,
    required this.billingDate,
    required this.gatePassNo,
    required this.daCode,
    required this.dueAmount,
    required this.netVal,
    required this.returnAmount,
    this.materials,
  });

  BillingDoc copyWith({
    String? billingDocNo,
    DateTime? billingDate,
    String? gatePassNo,
    String? daCode,
    double? dueAmount,
    double? netVal,
    double? returnAmount,
    List<MaterialModel>? materials,
  }) =>
      BillingDoc(
        billingDocNo: billingDocNo ?? this.billingDocNo,
        billingDate: billingDate ?? this.billingDate,
        gatePassNo: gatePassNo ?? this.gatePassNo,
        daCode: daCode ?? this.daCode,
        dueAmount: dueAmount ?? this.dueAmount,
        netVal: netVal ?? this.netVal,
        returnAmount: returnAmount ?? this.returnAmount,
        materials: materials ?? this.materials,
      );

  factory BillingDoc.fromJson(String str) =>
      BillingDoc.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BillingDoc.fromMap(Map<String, dynamic> json) => BillingDoc(
        billingDocNo: json["billing_doc_no"],
        billingDate: DateTime.parse(json["billing_date"]),
        gatePassNo: json["gate_pass_no"],
        daCode: json["da_code"],
        dueAmount: json["due_amount"],
        netVal: json["net_val"],
        returnAmount: json["return_amount"],
        materials: List<MaterialModel>.from(
            json["materials"].map((x) => MaterialModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "billing_doc_no": billingDocNo,
        "billing_date":
            "${billingDate.year.toString().padLeft(4, '0')}-${billingDate.month.toString().padLeft(2, '0')}-${billingDate.day.toString().padLeft(2, '0')}",
        "gate_pass_no": gatePassNo,
        "da_code": daCode,
        "due_amount": dueAmount,
        "net_val": netVal,
        "return_amount": returnAmount,
        "materials": materials == null
            ? null
            : List<dynamic>.from(materials!.map((x) => x.toMap())),
      };
}

class MaterialModel {
  String matnr;
  String batch;
  double deliveryQuantity;
  double deliveryNetVal;
  double returnQuantity;
  double returnNetVal;

  MaterialModel({
    required this.matnr,
    required this.batch,
    required this.deliveryQuantity,
    required this.deliveryNetVal,
    required this.returnQuantity,
    required this.returnNetVal,
  });

  MaterialModel copyWith({
    String? matnr,
    String? batch,
    double? deliveryQuantity,
    double? deliveryNetVal,
    double? returnQuantity,
    double? returnNetVal,
  }) =>
      MaterialModel(
        matnr: matnr ?? this.matnr,
        batch: batch ?? this.batch,
        deliveryQuantity: deliveryQuantity ?? this.deliveryQuantity,
        deliveryNetVal: deliveryNetVal ?? this.deliveryNetVal,
        returnQuantity: returnQuantity ?? this.returnQuantity,
        returnNetVal: returnNetVal ?? this.returnNetVal,
      );

  factory MaterialModel.fromJson(String str) =>
      MaterialModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MaterialModel.fromMap(Map<String, dynamic> json) => MaterialModel(
        matnr: json["matnr"],
        batch: json["batch"],
        deliveryQuantity: json["delivery_quantity"],
        deliveryNetVal: json["delivery_net_val"],
        returnQuantity: json["return_quantity"],
        returnNetVal: json["return_net_val"]?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "matnr": matnr,
        "batch": batch,
        "delivery_quantity": deliveryQuantity,
        "delivery_net_val": deliveryNetVal,
        "return_quantity": returnQuantity,
        "return_net_val": returnNetVal,
      };
}
