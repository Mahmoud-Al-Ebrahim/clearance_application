// To parse this JSON data, do
//
//     final paymentDestinationsModel = paymentDestinationsModelFromJson(jsonString);

import 'dart:convert';

PaymentDestinationsModel paymentDestinationsModelFromJson(String str) => PaymentDestinationsModel.fromJson(json.decode(str));

String paymentDestinationsModelToJson(PaymentDestinationsModel data) => json.encode(data.toJson());

class PaymentDestinationsModel {
  String? message;
  Data? data;

  PaymentDestinationsModel({
    this.message,
    this.data,
  });

  factory PaymentDestinationsModel.fromJson(Map<String, dynamic> json) => PaymentDestinationsModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<Destination>? destinations;

  Data({
    this.destinations,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    destinations: json["destinations"] == null ? [] : List<Destination>.from(json["destinations"]!.map((x) => Destination.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "destinations": destinations == null ? [] : List<dynamic>.from(destinations!.map((x) => x.toJson())),
  };
}

class Destination {
  int? id;
  String? englishName;
  String? arabicName;
  String? icon;
  String? details;
  dynamic createdAt;
  dynamic updatedAt;

  Destination({
    this.id,
    this.englishName,
    this.arabicName,
    this.icon,
    this.details,
    this.createdAt,
    this.updatedAt,
  });

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    id: json["id"],
    arabicName: json["name_ae"],
    englishName: json["name_ae_en"],
    icon: json["icon_url"],
    details: json["details"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "icon": icon,
    "details": details,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
