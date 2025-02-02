import 'dart:convert';

class DashBoardModel {
  bool? success;
  List<DashBoardResult>? result;

  DashBoardModel({
    this.success,
    this.result,
  });

  DashBoardModel copyWith({
    bool? success,
    List<DashBoardResult>? result,
  }) =>
      DashBoardModel(
        success: success ?? this.success,
        result: result ?? this.result,
      );

  factory DashBoardModel.fromJson(String str) =>
      DashBoardModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DashBoardModel.fromMap(Map<String, dynamic> json) => DashBoardModel(
        success: json['success'],
        result: json['result'] == null
            ? []
            : List<DashBoardResult>.from(
                json['result']!.map((x) => DashBoardResult.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        'success': success,
        'result': result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toMap())),
      };
}

class DashBoardResult {
  dynamic deliveryRemaining;
  dynamic deliveryDone;
  dynamic cashRemaining;
  dynamic cashDone;
  dynamic sapId;
  dynamic totalGatePassAmount;
  dynamic totalCollectionAmount;
  dynamic totalReturnAmount;
  dynamic totalReturnQuantity;
  dynamic dueAmountTotal;
  dynamic previousDayDue;

  DashBoardResult({
    this.deliveryRemaining,
    this.deliveryDone,
    this.cashRemaining,
    this.cashDone,
    this.sapId,
    this.totalGatePassAmount,
    this.totalCollectionAmount,
    this.totalReturnAmount,
    this.totalReturnQuantity,
    this.dueAmountTotal,
    this.previousDayDue,
  });

  DashBoardResult copyWith({
    dynamic deliveryRemaining,
    dynamic deliveryDone,
    dynamic cashRemaining,
    dynamic cashDone,
    dynamic sapId,
    dynamic totalGatePassAmount,
    dynamic totalCollectionAmount,
    dynamic totalReturnAmount,
    dynamic totalReturnQuantity,
    dynamic dueAmountTotal,
    dynamic previousDayDue,
  }) =>
      DashBoardResult(
        deliveryRemaining: deliveryRemaining ?? this.deliveryRemaining,
        deliveryDone: deliveryDone ?? this.deliveryDone,
        cashRemaining: cashRemaining ?? this.cashRemaining,
        cashDone: cashDone ?? this.cashDone,
        sapId: sapId ?? this.sapId,
        totalGatePassAmount: totalGatePassAmount ?? this.totalGatePassAmount,
        totalCollectionAmount:
            totalCollectionAmount ?? this.totalCollectionAmount,
        totalReturnAmount: totalReturnAmount ?? this.totalReturnAmount,
        totalReturnQuantity: totalReturnQuantity ?? this.totalReturnQuantity,
        dueAmountTotal: dueAmountTotal ?? this.dueAmountTotal,
        previousDayDue: previousDayDue ?? this.previousDayDue,
      );

  factory DashBoardResult.fromJson(String str) =>
      DashBoardResult.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DashBoardResult.fromMap(Map<String, dynamic> json) => DashBoardResult(
        deliveryRemaining: json['delivery_remaining'],
        deliveryDone: json['delivery_done'],
        cashRemaining: json['cash_remaining'],
        cashDone: json['cash_done'],
        sapId: json['sap_id'],
        totalGatePassAmount: json['total_gate_pass_amount'],
        totalCollectionAmount: json['total_collection_amount'],
        totalReturnAmount: json['total_return_amount'],
        totalReturnQuantity: json['total_return_quantity'],
        dueAmountTotal: json['due_amount_total'],
        previousDayDue: json['previous_day_due'],
      );

  Map<String, dynamic> toMap() => {
        'delivery_remaining': deliveryRemaining,
        'delivery_done': deliveryDone,
        'cash_remaining': cashRemaining,
        'cash_done': cashDone,
        'sap_id': sapId,
        'total_gate_pass_amount': totalGatePassAmount,
        'total_collection_amount': totalCollectionAmount,
        'total_return_amount': totalReturnAmount,
        'total_return_quantity': totalReturnQuantity,
        'due_amount_total': dueAmountTotal,
        'previous_day_due': previousDayDue,
      };
}
