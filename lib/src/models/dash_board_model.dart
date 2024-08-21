import 'dart:convert';

class DashBoardModel {
  DashBoardModel({
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

  factory DashBoardModel.fromJson(String str) => DashBoardModel.fromMap(
        Map<String, dynamic>.from(json.decode(str) as Map),
      );

  factory DashBoardModel.fromMap(Map<String, dynamic> json) => DashBoardModel(
        deliveryDone: json['delivery_done'] as double,
        cashRemaining: json['cash_remaining'] as double,
        cashDone: json['cash_done'] as double,
        sapId: json['sap_id'] as double,
        totalGatePassAmount:
            // ignore: avoid_dynamic_calls
            json['total_gate_pass_amount']?.toDouble() as double,
        totalCollectionAmount: json['total_collection_amount'] as double,
        totalReturnAmount: json['total_return_amount'] as double,
        totalReturnQuantity: json['total_return_quantity'] as double,
        dueAmountTotal: json['due_amount_total'] as double,
        previousDayDue: json['previous_day_due'] as double,
        deliveryRemaining: json['delivery_remaining'] as double,
      );
  final double? deliveryRemaining;
  final double? deliveryDone;
  final double? cashRemaining;
  final double? cashDone;
  final double? sapId;
  final double? totalGatePassAmount;
  final double? totalCollectionAmount;
  final double? totalReturnAmount;
  final double? totalReturnQuantity;
  final double? dueAmountTotal;
  final double? previousDayDue;

  DashBoardModel copyWith({
    double? deliveryDone,
    double? cashRemaining,
    double? cashDone,
    double? sapId,
    double? totalGatePassAmount,
    double? totalCollectionAmount,
    double? totalReturnAmount,
    double? totalReturnQuantity,
    double? dueAmountTotal,
    double? previousDayDue,
    double? deliveryRemaining,
  }) =>
      DashBoardModel(
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
        deliveryRemaining: deliveryRemaining ?? this.deliveryRemaining,
      );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
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
        'delivery_remaining': deliveryRemaining,
      };
}
