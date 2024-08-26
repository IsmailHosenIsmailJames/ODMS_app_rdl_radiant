import 'dart:convert';

class DeliveryRemaing {
  bool? success;
  List<Result>? result;

  DeliveryRemaing({
    this.success,
    this.result,
  });

  DeliveryRemaing copyWith({
    bool? success,
    List<Result>? result,
  }) =>
      DeliveryRemaing(
        success: success ?? this.success,
        result: result ?? this.result,
      );

  factory DeliveryRemaing.fromJson(String str) =>
      DeliveryRemaing.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DeliveryRemaing.fromMap(Map<String, dynamic> json) => DeliveryRemaing(
        success: json["success"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"]!.map((x) => Result.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toMap())),
      };
}

class Result {
  DateTime? billingDate;
  String? routeCode;
  String? routeName;
  int? daCode;
  String? daName;
  String? partner;
  String? customerName;
  String? customerAddress;
  String? customerMobile;
  dynamic latitude;
  dynamic longitude;
  String? gatePassNo;
  List<InvoiceList>? invoiceList;

  Result({
    this.billingDate,
    this.routeCode,
    this.routeName,
    this.daCode,
    this.daName,
    this.partner,
    this.customerName,
    this.customerAddress,
    this.customerMobile,
    this.latitude,
    this.longitude,
    this.gatePassNo,
    this.invoiceList,
  });

  Result copyWith({
    DateTime? billingDate,
    String? routeCode,
    String? routeName,
    int? daCode,
    String? daName,
    String? partner,
    String? customerName,
    String? customerAddress,
    String? customerMobile,
    dynamic latitude,
    dynamic longitude,
    String? gatePassNo,
    List<InvoiceList>? invoiceList,
  }) =>
      Result(
        billingDate: billingDate ?? this.billingDate,
        routeCode: routeCode ?? this.routeCode,
        routeName: routeName ?? this.routeName,
        daCode: daCode ?? this.daCode,
        daName: daName ?? this.daName,
        partner: partner ?? this.partner,
        customerName: customerName ?? this.customerName,
        customerAddress: customerAddress ?? this.customerAddress,
        customerMobile: customerMobile ?? this.customerMobile,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        gatePassNo: gatePassNo ?? this.gatePassNo,
        invoiceList: invoiceList ?? this.invoiceList,
      );

  factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Result.fromMap(Map<String, dynamic> json) => Result(
        billingDate: json["billing_date"] == null
            ? null
            : DateTime.parse(json["billing_date"]),
        routeCode: json["route_code"],
        routeName: json["route_name"],
        daCode: json["da_code"],
        daName: json["da_name"],
        partner: json["partner"],
        customerName: json["customer_name"],
        customerAddress: json["customer_address"],
        customerMobile: json["customer_mobile"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        gatePassNo: json["gate_pass_no"],
        invoiceList: json["invoice_list"] == null
            ? []
            : List<InvoiceList>.from(
                json["invoice_list"]!.map((x) => InvoiceList.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "billing_date":
            "${billingDate!.year.toString().padLeft(4, '0')}-${billingDate!.month.toString().padLeft(2, '0')}-${billingDate!.day.toString().padLeft(2, '0')}",
        "route_code": routeCode,
        "route_name": routeName,
        "da_code": daCode,
        "da_name": daName,
        "partner": partner,
        "customer_name": customerName,
        "customer_address": customerAddress,
        "customer_mobile": customerMobile,
        "latitude": latitude,
        "longitude": longitude,
        "gate_pass_no": gatePassNo,
        "invoice_list": invoiceList == null
            ? []
            : List<dynamic>.from(invoiceList!.map((x) => x.toMap())),
      };
}

class InvoiceList {
  dynamic id;
  String? billingDocNo;
  DateTime? billingDate;
  String? routeCode;
  String? routeName;
  int? daCode;
  String? daName;
  String? partner;
  String? customerName;
  String? customerAddress;
  String? customerMobile;
  dynamic latitude;
  dynamic longitude;
  String? deliveryStatus;
  int? cashCollection;
  String? cashCollectionStatus;
  String? gatePassNo;
  String? vehicleNo;
  dynamic transportType;
  List<ProductList>? productList;

  InvoiceList({
    this.id,
    this.billingDocNo,
    this.billingDate,
    this.routeCode,
    this.routeName,
    this.daCode,
    this.daName,
    this.partner,
    this.customerName,
    this.customerAddress,
    this.customerMobile,
    this.latitude,
    this.longitude,
    this.deliveryStatus,
    this.cashCollection,
    this.cashCollectionStatus,
    this.gatePassNo,
    this.vehicleNo,
    this.transportType,
    this.productList,
  });

  InvoiceList copyWith({
    dynamic id,
    String? billingDocNo,
    DateTime? billingDate,
    String? routeCode,
    String? routeName,
    int? daCode,
    String? daName,
    String? partner,
    String? customerName,
    String? customerAddress,
    String? customerMobile,
    dynamic latitude,
    dynamic longitude,
    String? deliveryStatus,
    int? cashCollection,
    String? cashCollectionStatus,
    String? gatePassNo,
    String? vehicleNo,
    dynamic transportType,
    List<ProductList>? productList,
  }) =>
      InvoiceList(
        id: id ?? this.id,
        billingDocNo: billingDocNo ?? this.billingDocNo,
        billingDate: billingDate ?? this.billingDate,
        routeCode: routeCode ?? this.routeCode,
        routeName: routeName ?? this.routeName,
        daCode: daCode ?? this.daCode,
        daName: daName ?? this.daName,
        partner: partner ?? this.partner,
        customerName: customerName ?? this.customerName,
        customerAddress: customerAddress ?? this.customerAddress,
        customerMobile: customerMobile ?? this.customerMobile,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        deliveryStatus: deliveryStatus ?? this.deliveryStatus,
        cashCollection: cashCollection ?? this.cashCollection,
        cashCollectionStatus: cashCollectionStatus ?? this.cashCollectionStatus,
        gatePassNo: gatePassNo ?? this.gatePassNo,
        vehicleNo: vehicleNo ?? this.vehicleNo,
        transportType: transportType ?? this.transportType,
        productList: productList ?? this.productList,
      );

  factory InvoiceList.fromJson(String str) =>
      InvoiceList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InvoiceList.fromMap(Map<String, dynamic> json) => InvoiceList(
        id: json["id"],
        billingDocNo: json["billing_doc_no"],
        billingDate: json["billing_date"] == null
            ? null
            : DateTime.parse(json["billing_date"]),
        routeCode: json["route_code"],
        routeName: json["route_name"],
        daCode: json["da_code"],
        daName: json["da_name"],
        partner: json["partner"],
        customerName: json["customer_name"],
        customerAddress: json["customer_address"],
        customerMobile: json["customer_mobile"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        deliveryStatus: json["delivery_status"],
        cashCollection: json["cash_collection"],
        cashCollectionStatus: json["cash_collection_status"],
        gatePassNo: json["gate_pass_no"],
        vehicleNo: json["vehicle_no"],
        transportType: json["transport_type"],
        productList: json["product_list"] == null
            ? []
            : List<ProductList>.from(
                json["product_list"]!.map((x) => ProductList.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "billing_doc_no": billingDocNo,
        "billing_date":
            "${billingDate!.year.toString().padLeft(4, '0')}-${billingDate!.month.toString().padLeft(2, '0')}-${billingDate!.day.toString().padLeft(2, '0')}",
        "route_code": routeCode,
        "route_name": routeName,
        "da_code": daCode,
        "da_name": daName,
        "partner": partner,
        "customer_name": customerName,
        "customer_address": customerAddress,
        "customer_mobile": customerMobile,
        "latitude": latitude,
        "longitude": longitude,
        "delivery_status": deliveryStatus,
        "cash_collection": cashCollection,
        "cash_collection_status": cashCollectionStatus,
        "gate_pass_no": gatePassNo,
        "vehicle_no": vehicleNo,
        "transport_type": transportType,
        "product_list": productList == null
            ? []
            : List<dynamic>.from(productList!.map((x) => x.toMap())),
      };
}

class ProductList {
  dynamic id;
  String? matnr;
  int? quantity;
  double? tp;
  double? vat;
  double? netVal;
  String? batch;
  String? materialName;
  String? brandDescription;
  String? brandName;
  int? deliveryQuantity;
  int? deliveryNetVal;
  int? returnQuantity;
  int? returnNetVal;

  ProductList({
    this.id,
    this.matnr,
    this.quantity,
    this.tp,
    this.vat,
    this.netVal,
    this.batch,
    this.materialName,
    this.brandDescription,
    this.brandName,
    this.deliveryQuantity,
    this.deliveryNetVal,
    this.returnQuantity,
    this.returnNetVal,
  });

  ProductList copyWith({
    dynamic id,
    String? matnr,
    int? quantity,
    double? tp,
    double? vat,
    double? netVal,
    String? batch,
    String? materialName,
    String? brandDescription,
    String? brandName,
    int? deliveryQuantity,
    int? deliveryNetVal,
    int? returnQuantity,
    int? returnNetVal,
  }) =>
      ProductList(
        id: id ?? this.id,
        matnr: matnr ?? this.matnr,
        quantity: quantity ?? this.quantity,
        tp: tp ?? this.tp,
        vat: vat ?? this.vat,
        netVal: netVal ?? this.netVal,
        batch: batch ?? this.batch,
        materialName: materialName ?? this.materialName,
        brandDescription: brandDescription ?? this.brandDescription,
        brandName: brandName ?? this.brandName,
        deliveryQuantity: deliveryQuantity ?? this.deliveryQuantity,
        deliveryNetVal: deliveryNetVal ?? this.deliveryNetVal,
        returnQuantity: returnQuantity ?? this.returnQuantity,
        returnNetVal: returnNetVal ?? this.returnNetVal,
      );

  factory ProductList.fromJson(String str) =>
      ProductList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductList.fromMap(Map<String, dynamic> json) => ProductList(
        id: json["id"],
        matnr: json["matnr"],
        quantity: json["quantity"],
        tp: json["tp"]?.toDouble(),
        vat: json["vat"]?.toDouble(),
        netVal: json["net_val"]?.toDouble(),
        batch: json["batch"],
        materialName: json["material_name"],
        brandDescription: json["brand_description"],
        brandName: json["brand_name"],
        deliveryQuantity: json["delivery_quantity"],
        deliveryNetVal: json["delivery_net_val"],
        returnQuantity: json["return_quantity"],
        returnNetVal: json["return_net_val"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "matnr": matnr,
        "quantity": quantity,
        "tp": tp,
        "vat": vat,
        "net_val": netVal,
        "batch": batch,
        "material_name": materialName,
        "brand_description": brandDescription,
        "brand_name": brandName,
        "delivery_quantity": deliveryQuantity,
        "delivery_net_val": deliveryNetVal,
        "return_quantity": returnQuantity,
        "return_net_val": returnNetVal,
      };
}
