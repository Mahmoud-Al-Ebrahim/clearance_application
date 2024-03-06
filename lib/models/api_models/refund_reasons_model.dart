// To parse this JSON data, do
//
//     final refundResonsModel = refundResonsModelFromJson(jsonString);

import 'dart:convert';

RefundReasonsModel refundReasonsModelFromJson(String str) => RefundReasonsModel.fromJson(json.decode(str));

String refundReasonsModelToJson(RefundReasonsModel data) => json.encode(data.toJson());

class RefundReasonsModel {
  String? message;
  Data? data;

  RefundReasonsModel({
    this.message,
    this.data,
  });

  factory RefundReasonsModel.fromJson(Map<String, dynamic> json) => RefundReasonsModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<Reason>? returnReasons;
  List<Reason>? exchangeReasons;

  Data({
    this.returnReasons,
    this.exchangeReasons,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    returnReasons: json["return_reasons"] == null ? [] : List<Reason>.from(json["return_reasons"]!.map((x) => Reason.fromJson(x))),
    exchangeReasons: json["exchange_reasons"] == null ? [] : List<Reason>.from(json["exchange_reasons"]!.map((x) => Reason.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "return_reasons": returnReasons == null ? [] : List<dynamic>.from(returnReasons!.map((x) => x.toJson())),
    "exchange_reasons": exchangeReasons == null ? [] : List<dynamic>.from(exchangeReasons!.map((x) => x.toJson())),
  };
}

class Reason {
  int? id;
  String? reasonEnglish;
  String? reasonArabic;
  double? cost;
  int? isCostBySystem;
  int? isForExchange;
  DateTime? createdAt;
  DateTime? updatedAt;

  Reason({
    this.id,
    this.reasonArabic,
    this.reasonEnglish,
    this.cost,
    this.isCostBySystem,
    this.isForExchange,
    this.createdAt,
    this.updatedAt,
  });

  factory Reason.fromJson(Map<String, dynamic> json) => Reason(
    id: json["id"],
    reasonArabic: json["reason_ae"],
    reasonEnglish: json["reason_ae_en"],
    cost: json["cost"]?.toDouble(),
    isCostBySystem: json["is_cost_by_system"],
    isForExchange: json["is_for_exchange"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cost": cost,
    "is_cost_by_system": isCostBySystem,
    "is_for_exchange": isForExchange,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
